#!/usr/bin/env python3
# Copyright 2020-2022 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import odb

import os
import sys
import click
import subprocess

from reader import OdbReader, click_odb


@click.group()
def cli():
    pass


@click.command("write_powered_def")
@click.option(
    "-v",
    "--power-port",
    required=True,
    help="Name of the power port of the design. The power pin of the subcells will be connected to it by default",
)
@click.option(
    "-g",
    "--ground-port",
    required=True,
    help="Name of the ground port of the design. The ground pin of the subcells will be connected to it by default",
)
@click.option(
    "-n",
    "--powered-netlist",
    required=True,
    help="A structural verilog netlist, readable by openroad, that includes extra power connections that are to be applied after connecting to the default power-port and ground-port specified.",
)
@click.option("-q", "--ignore-missing-pins", default=False, is_flag=True)
@click.option("-o", "--output", required=True, help="Output DEF file")
@click.option("-l", "--input-lef", required=True, help="Merged LEF file")
@click.argument("input_def")
# And the award for worst-written function goes to:
def write_powered_def(
    output,
    input_lef,
    input_def,
    power_port,
    ground_port,
    powered_netlist,
    ignore_missing_pins,
):
    """
    Connects every cell with a power pin to the power/ground port of the design.
    """
    reader = OdbReader(input_lef, input_def)

    def get_power_ground_ports(ports):
        vdd_ports = []
        gnd_ports = []
        for port in ports:
            if port.getSigType() == "POWER" or port.getName() == power_port:
                vdd_ports.append(port)
            elif port.getSigType() == "GROUND" or port.getName() == ground_port:
                gnd_ports.append(port)
        return (vdd_ports, gnd_ports)

    def find_power_ground_port(port_name, ports):
        for port in ports:
            if port.getName() == port_name:
                return port
        return None

    print(f"Top-level design name: {reader.name}")

    VDD_PORTS, GND_PORTS = get_power_ground_ports(reader.block.getBTerms())
    if len(VDD_PORTS) == 0 or len(GND_PORTS) == 0:
        print(
            "No power ports found at the top-level. Make sure that they exist and have the USE POWER|GROUND property or they match the arguments specified with --power-port and --ground-port.",
            file=sys.stderr,
        )
        exit(os.EX_DATAERR)

    vdd_net = None
    gnd_net = None
    for port in VDD_PORTS + GND_PORTS:
        if port.getNet().getName() == power_port:
            vdd_net = port.getNet()
        elif port.getNet().getName() == ground_port:
            gnd_net = port.getNet()

    nets_not_found = False
    if vdd_net is None:
        print(f"Power port {power_port} not found in design.", file=sys.stderr)
        nets_not_found = True
    if gnd_net is None:
        print(f"Ground port {ground_port} not found in design.", file=sys.stderr)
        nets_not_found = True
    if nets_not_found:
        exit(os.EX_DATAERR)

    print(f"Found default power net '{vdd_net.getName()}'")
    print(f"Found default ground net '{gnd_net.getName()}'")

    print(f"Found {len(VDD_PORTS)} power ports.")
    print(f"Found {len(GND_PORTS)} ground ports.")

    modified_cells = 0
    cells = reader.block.getInsts()
    for cell in cells:
        iterms = cell.getITerms()
        cell_name = cell.getName()
        if len(iterms) == 0:
            continue

        VDD_ITERMS = []
        GND_ITERMS = []
        VDD_ITERM_BY_NAME = None
        GND_ITERM_BY_NAME = None
        for iterm in iterms:
            if iterm.getSigType() == "POWER":
                VDD_ITERMS.append(iterm)
            elif iterm.getSigType() == "GROUND":
                GND_ITERMS.append(iterm)
            elif iterm.getMTerm().getName() == power_port:
                VDD_ITERM_BY_NAME = iterm
            elif iterm.getMTerm().getName() == ground_port:  # note **PORT**
                GND_ITERM_BY_NAME = iterm

        if len(VDD_ITERMS) == 0:
            print(
                f"[WARN] No pins in the LEF view of {cell_name} marked for use as power."
            )
            print(
                f"[WARN] Attempting to match power pin by name (using top-level port name) for {cell_name}."
            )
            if VDD_ITERM_BY_NAME is not None:  # note **PORT**
                print(f"Found '{power_port}', using it as a power pin...")
                VDD_ITERMS.append(VDD_ITERM_BY_NAME)

        if len(GND_ITERMS) == 0:
            print(
                f"[WARN] No pins in the LEF view of {cell_name} marked for use as ground."
            )
            print(
                f"[WARN] Attempting to match power pin by name (using top-level port name) for {cell_name}."
            )
            if GND_ITERM_BY_NAME is not None:  # note **PORT**
                print(f"Found '{ground_port}', using it as a ground pin...")
                GND_ITERMS.append(GND_ITERM_BY_NAME)

        if len(VDD_ITERMS) == 0 or len(GND_ITERMS) == 0:
            err_msg = (
                f"Either power or ground (or both) pins not found for {cell_name}."
            )
            if ignore_missing_pins:
                print(f"[WARN] {err_msg} Ignoring...")
            else:
                print(
                    err_msg,
                    file=sys.stderr,
                )
                exit(os.EX_DATAERR)

        if len(VDD_ITERMS) > 2:
            print(f"[WARN] {cell_name} has {len(VDD_ITERMS)} power pins.")

        if len(GND_ITERMS) > 2:
            print(f"[WARN] {cell_name} has {len(GND_ITERMS)} power pins.")

        for VDD_ITERM in VDD_ITERMS:
            if VDD_ITERM.isConnected():
                pin_name = VDD_ITERM.getMTerm().getName()
                cell_name = cell_name
                print(
                    f"[WARN] {cell_name}/{pin_name} appears to already be connected. Ignoring..."
                )
            else:
                VDD_ITERM.connect(vdd_net)

        for GND_ITERM in GND_ITERMS:
            if GND_ITERM.isConnected():
                pin_name = GND_ITERM.getMTerm().getName()
                cell_name = cell_name
                print(
                    f"[WARN] {cell_name}/{pin_name} appears to already be connected. Ignoring..."
                )
            else:
                GND_ITERM.connect(gnd_net)

        modified_cells += 1

    print(f"Modified power connections of {modified_cells}/{len(cells)} cells.")

    # apply extra special connections taken from another netlist:
    ### ^ Literally what in God's name does this mean?
    if powered_netlist is not None and os.path.exists(powered_netlist):
        tmp_def_file = f"{os.path.splitext(powered_netlist)[0]}.intermediate.def"

        openroad_script = f"""
        read_lef {input_lef}
        read_verilog {powered_netlist}
        link_design {reader.name}
        write_def {tmp_def_file}
        exit
        """

        subprocess.run(["openroad"], check=True, input=openroad_script.encode("utf8"))

        power = OdbReader(input_lef, tmp_def_file)

        assert power.name == reader.name

        # using get_power_ground_ports doesn't work since the pins weren't
        # created using pdngen
        pg_port_names = [port.getName() for port in VDD_PORTS + GND_PORTS]
        pg_ports = [
            port for port in power.block.getBTerms() if port.getName() in pg_port_names
        ]

        for port in pg_ports:
            net = port.getNet()
            iterms = net.getITerms()
            for iterm in iterms:
                inst_name = iterm.getInst().getName()
                pin_name = iterm.getMTerm().getName()
                port_name = port.getName()

                original_inst = reader.block.findInst(inst_name)
                if original_inst is None:
                    print(
                        f"Instance {inst_name} was not found in the original netlist.",
                        file=sys.stderr,
                    )
                    exit(os.EX_DATAERR)

                original_iterm = original_inst.findITerm(pin_name)
                if original_iterm is None:
                    print(
                        f"Pin {inst_name}/{pin_name} not found in the original netlist."
                    )
                    exit(os.EX_DATAERR)

                original_port = find_power_ground_port(port_name, VDD_PORTS + GND_PORTS)
                if original_port is None:
                    print(f"Port {original_port} not found in the original netlist.")
                    exit(os.EX_DATAERR)

                original_iterm.connect(original_port.getNet())
                print(f"Connected {port_name} to {inst_name}/{pin_name}.")

    odb.write_def(reader.block, output)


cli.add_command(write_powered_def)


@click.command("power_route")
@click.option(
    "-v",
    "--core-vdd-pin",
    required=True,
    help="Name of the power pin of core macro (exposed as its core ring)",
)
@click.option(
    "-g",
    "--core-gnd-pin",
    required=True,
    help="Name of the ground pin of core macro (exposed as its core ring)",
)
@click.option(
    "-V",
    "--vdd-pad-pin-map",
    default=None,
    multiple=True,
    help="Name of the power pin of core macro (exposed as its core ring)",
)
@click.option(
    "-G",
    "--gnd-pad-pin-map",
    default=None,
    multiple=True,
    help="Name of the ground pin of core macro (exposed as its core ring)",
)
@click_odb
def power_route(
    output,
    reader,
    core_vdd_pin,
    core_gnd_pin,
    vdd_pad_pin_map,
    gnd_pad_pin_map,
):
    """
    Takes a pre-routed top-level layout, produces a DEF file with VDD and GND special nets\
    where the power pads are connected to the core ring
    """

    # TODO: expose through arguments
    ORIENT_LOC_MAP = {"R0": "N", "R90": "W", "R180": "S", "R270": "E"}

    # TODO: allow control
    VDD_NET_NAME = "VDD"
    GND_NET_NAME = "GND"

    # SKY130 DEFAULT
    SPECIAL_NETS = {
        VDD_NET_NAME: {"core_pin": core_vdd_pin, "covered": False, "map": []},
        GND_NET_NAME: {"core_pin": core_gnd_pin, "covered": False, "map": []},
    }

    if vdd_pad_pin_map is None:
        vdd_pad_pin_map = [{"pad_pin": "vccd", "pad_name_substr": "vccd"}]
    else:
        vdd_pad_pin_map = [
            {"pad_pin": mapping[0], "pad_name_substr": mapping[1]}
            for mapping in vdd_pad_pin_map
        ]

    if gnd_pad_pin_map is None:
        gnd_pad_pin_map = [
            {"pad_pin": "vssd", "pad_name_substr": "vssd"},
            {"pad_pin": "vssa", "pad_name_substr": "vssa"},
            {"pad_pin": "vssio", "pad_name_substr": "vssio"},
        ]
    else:
        gnd_pad_pin_map = [
            {"pad_pin": mapping[0], "pad_name_substr": mapping[1]}
            for mapping in gnd_pad_pin_map
        ]

    SPECIAL_NETS[VDD_NET_NAME]["map"] = vdd_pad_pin_map
    SPECIAL_NETS[GND_NET_NAME]["map"] = gnd_pad_pin_map

    ##################

    via_rules = reader.tech.getViaGenerateRules()
    print("Found", len(via_rules), "VIA GENERATE rules")

    # build dictionary of basic custom vias (ROW = COL = 1)
    custom_vias = {}
    for rule in via_rules:
        lower_rules = rule.getViaLayerRule(0)
        upper_rules = rule.getViaLayerRule(1)
        cut_rules = rule.getViaLayerRule(2)

        lower_layer = lower_rules.getLayer()
        upper_layer = upper_rules.getLayer()
        cut_layer = cut_rules.getLayer()

        if lower_layer.getName() in custom_vias:
            print("Skipping", rule.getName())
            continue

        via_params = odb.dbViaParams()

        via_params.setBottomLayer(lower_layer)
        via_params.setTopLayer(upper_layer)
        via_params.setCutLayer(cut_layer)

        cut_rect = cut_rules.getRect()
        via_params.setXCutSize(cut_rect.dx())
        via_params.setYCutSize(cut_rect.dy())

        cut_spacing = cut_rules.getSpacing()
        via_params.setXCutSpacing(cut_spacing[0] - cut_rect.dx())
        via_params.setYCutSpacing(cut_spacing[1] - cut_rect.dy())

        lower_enclosure = lower_rules.getEnclosure()
        upper_enclosure = upper_rules.getEnclosure()
        if "M1M2" in rule.getName():
            print(lower_enclosure)
        via_params.setXBottomEnclosure(lower_enclosure[0])
        via_params.setYBottomEnclosure(lower_enclosure[1])
        via_params.setXTopEnclosure(upper_enclosure[0])
        via_params.setYTopEnclosure(upper_enclosure[1])

        custom_vias[lower_layer.getName()] = {}
        custom_vias[lower_layer.getName()][upper_layer.getName()] = {
            "rule": rule,
            "params": via_params,
        }
        print("Added", rule.getName())

    def create_custom_via(layer1, layer2, width, height, reorient="R0"):
        assert width > 0 and height > 0

        if layer1.getRoutingLevel() < layer2.getRoutingLevel():
            lower_layer_name = layer1.getName()
            upper_layer_name = layer2.getName()
        elif layer1.getRoutingLevel() > layer2.getRoutingLevel():
            lower_layer_name = layer2.getName()
            upper_layer_name = layer1.getName()
        else:
            raise Exception("Cannot create a custom via between two identical layers")

        if reorient in ["R90", "R270"]:
            width, height = height, width

        via_name = "via_%s_%s_%dx%d" % (
            lower_layer_name,
            upper_layer_name,
            width,
            height,
        )

        custom_via = reader.block.findVia(via_name)
        if not custom_via:
            print("Creating", via_name)

            via_params = custom_vias[lower_layer_name][upper_layer_name]["params"]
            via_rule = custom_vias[lower_layer_name][upper_layer_name]["rule"]

            cut_width = via_params.getXCutSize()
            cut_height = via_params.getYCutSize()
            cut_spacing_x = via_params.getXCutSpacing()
            cut_spacing_y = via_params.getXCutSpacing()
            lower_enclosure_x = via_params.getXBottomEnclosure()
            lower_enclosure_y = via_params.getYBottomEnclosure()
            upper_enclosure_x = via_params.getXTopEnclosure()
            upper_enclosure_y = via_params.getYTopEnclosure()

            custom_via = odb.dbVia_create(reader.block, via_name)
            custom_via.setViaGenerateRule(via_rule)

            array_width = width - 2 * max(lower_enclosure_x, upper_enclosure_x)
            array_height = height - 2 * max(lower_enclosure_y, upper_enclosure_y)

            # set ROWCOL
            rows = 1 + (array_height - cut_height) // (cut_spacing_y + cut_height)
            cols = 1 + (array_width - cut_width) // (cut_spacing_x + cut_width)
            via_params.setNumCutRows(rows)
            via_params.setNumCutCols(cols)

            custom_via.setViaParams(via_params)

        return custom_via

    def boxes2Rects(boxes, transform):
        rects = []
        for box in boxes:
            ur = odb.Point(box.xMin(), box.yMin())
            ll = odb.Point(box.xMax(), box.yMax())
            transform.apply(ll)
            transform.apply(ur)
            pin_layer = box.getTechLayer()

            rects.append({"layer": pin_layer, "rect": odb.Rect(ll, ur)})
        return rects

    def getInstObs(inst):
        master = inst.getMaster()
        master_ox, master_oy = master.getOrigin()
        inst_ox, inst_oy = inst.getOrigin()
        px, py = master_ox + inst_ox, master_oy + inst_oy
        orient = inst.getOrient()
        transform = odb.dbTransform(orient, odb.Point(px, py))

        obstructions = master.getObstructions()
        rects = boxes2Rects(obstructions, transform)
        for rect in rects:
            rect["type"] = "obstruction"
        return rects

    def getITermBoxes(iterm):
        iterm_boxes = []
        inst = iterm.getInst()
        mterm = iterm.getMTerm()
        master_ox, master_oy = inst.getMaster().getOrigin()
        inst_ox, inst_oy = inst.getOrigin()
        px, py = master_ox + inst_ox, master_oy + inst_oy
        orient = inst.getOrient()
        transform = odb.dbTransform(orient, odb.Point(px, py))
        mpins = mterm.getMPins()
        if len(mpins) > 1:
            print(
                "Warning:",
                len(mpins),
                "mpins for iterm",
                inst.getName(),
                mterm.getName(),
            )
        for i in range(len(mpins)):
            mpin = mpins[i]
            boxes = mpin.getGeometry()
            iterm_boxes += boxes2Rects(boxes, transform)

        # filter duplications
        # TODO: OpenDB bug? duplicate mpins for some reason
        iterm_boxes_set = set()
        iterm_boxes_uniq = []
        for box in iterm_boxes:
            rect = box["rect"]
            llx, lly = rect.ll()
            urx, ury = rect.ur()
            set_item = (box["layer"].getName(), llx, lly, urx, ury)
            if set_item not in iterm_boxes_set:
                iterm_boxes_set.add(set_item)
                iterm_boxes_uniq.append(box)

        return iterm_boxes_uniq

    def getBiggestBoxAndIndex(boxes):
        biggest_area = -1
        biggest_box = None
        biggest_i = -1
        for i in range(len(boxes)):
            box = boxes[i]
            rect = box["rect"]
            area = rect.area()
            if area > biggest_area:
                biggest_area = area
                biggest_box = box
                biggest_i = i

        return biggest_box, biggest_i

    def rectOverlaps(rect1, rect2):
        return not (
            rect1.xMax() <= rect2.xMin()
            or rect1.xMin() >= rect2.xMax()
            or rect1.yMax() <= rect2.yMin()
            or rect1.yMin() >= rect2.yMax()
        )

    def rectMerge(rect1, rect2):
        rect = odb.Rect(
            min(rect1.xMin(), rect2.xMin()),
            min(rect1.yMin(), rect2.yMin()),
            max(rect1.xMax(), rect2.xMax()),
            max(rect1.yMax(), rect2.yMax()),
        )

        return rect

    def getShapesOverlappingBBox(llx, lly, urx, ury, layers=[], ext_orient="R0"):
        shapes_overlapping = []
        rect_bbox = odb.Rect(llx, lly, urx, ury)

        for box in ALL_BOXES:
            box_layer = box["layer"]
            ignore_box = len(layers) != 0
            for layer in layers:
                if equalLayers(layer, box_layer):
                    ignore_box = False
                    break
            if not ignore_box:
                rect_box = transformRect(box["rect"], ext_orient)
                if rectOverlaps(rect_box, rect_bbox):
                    shapes_overlapping.append(box)

        return shapes_overlapping

    def rectIntersection(rect1, rect2):
        rect = odb.Rect()
        if rectOverlaps(rect1, rect2):
            rect.set_xlo(max(rect1.xMin(), rect2.xMin()))
            rect.set_ylo(max(rect1.yMin(), rect2.yMin()))
            rect.set_xhi(min(rect1.xMax(), rect2.xMax()))
            rect.set_yhi(min(rect1.yMax(), rect2.yMax()))

        return rect

    def manhattanDistance(x1, y1, x2, y2):
        return odb.Point.manhattanDistance(odb.Point(x1, y1), odb.Point(x2, y2))

    def center(x1, y1, x2, y2):
        return (x1 + x2) // 2, (y1 + y2) // 2

    def gridify(rect):
        x1, y1 = rect.ll()
        x2, y2 = rect.ur()
        if (x2 - x1) % 2 != 0:
            x1 += 5  # 0.005 microns !
        return odb.Rect(x1, y1, x2, y2)

    def forward(point, orient, distance):
        x, y = point.x(), point.y()
        if orient == "R0":
            point_forward = odb.Point(x, y - distance)
        elif orient == "R90":
            point_forward = odb.Point(x + distance, y)
        elif orient == "R180":
            point_forward = odb.Point(x, y + distance)
        elif orient == "R270":
            point_forward = odb.Point(x - distance, y)
        else:
            print("Unknown orientation")
            sys.exit(1)
        return point_forward

    def transformRect(rect, orient):
        transform = odb.dbTransform(orient)
        rect_ll = odb.Point(*rect.ll())
        rect_ur = odb.Point(*rect.ur())
        transform.apply(rect_ll)
        transform.apply(rect_ur)
        rect = odb.Rect(rect_ll, rect_ur)
        return rect

    def isObstruction(box):
        return box["type"] == "obstruction"

    def isCorePin(box):
        return box["type"] == "core_pin"

    def isStripe(box):
        return isCorePin(box) and box["stripe_flag"]

    def isPadPin(box):
        return box["type"] == "pad_pin"

    def isHighestRoutingLayer(layer):
        return layer.getRoutingLevel() == reader.tech.getRoutingLayerCount()

    def isLowestRoutingLayer(layer):
        return layer.getRoutingLevel() == 1

    def isRoutingLayer(layer):
        return isinstance(layer, odb.dbTechLayer) and layer.getRoutingLevel() != 0

    def getUpperRoutingLayer(layer):
        if not isRoutingLayer(layer):
            raise Exception(
                "Attempting to get upper routing layer of a non-routing layer"
            )

        if isHighestRoutingLayer(layer):
            raise Exception(
                "Attempting to get upper routing layer of the highest routing layer"
            )

        return layer.getUpperLayer().getUpperLayer()

    def getLowerRoutingLayer(layer):
        if not isRoutingLayer(layer):
            raise Exception(
                "Attempting to get lower routing layer of a non-routing layer"
            )

        if isLowestRoutingLayer(layer):
            raise Exception(
                "Attempting to get lower routing layer of the lowest routing layer"
            )

        return layer.getLowerLayer().getLowerLayer()

    def equalLayers(layer1, layer2):
        return layer1.getName() == layer2.getName()

    def layersBetween(layer1, layer2):
        # Inclusive
        layers_between = [layer1]

        if not equalLayers(layer1, layer2):
            if layer1.getRoutingLevel() < layer2.getRoutingLevel():
                layer1 = getUpperRoutingLayer(layer1)
                while not equalLayers(layer1, layer2):
                    layers_between.append(layer1)
                    layer1 = getUpperRoutingLayer(layer1)
            else:
                layer1 = getLowerRoutingLayer(layer1)
                while not equalLayers(layer1, layer2):
                    layers_between.append(layer1)
                    layer1 = getLowerRoutingLayer(layer1)
            layers_between.append(layer2)

        return layers_between

    def createWireBox(
        rect_width, rect_height, rect_x, rect_y, layer, net, reorient="R0"
    ):
        rect = odb.Rect(0, 0, rect_width, rect_height)
        rect.moveTo(rect_x, rect_y)
        rect = transformRect(rect, reorient)

        box = {"rect": rect, "layer": layer, "net": net}

        return box

    def getTechMaxSpacing(layers=reader.tech.getLayers()):
        max_spacing = -1
        for layer in layers:
            max_spacing = max(max_spacing, layer.getSpacing())
        # print("Max spacing for", layers, "is", max_spacing)
        return max_spacing

    print("Top-level design name:", reader.name)

    # create special nets
    for special_net_name in SPECIAL_NETS:
        net = odb.dbNet_create(reader.block, special_net_name)
        net.setSpecial()
        net.setWildConnected()

        wire = odb.dbSWire_create(net, "ROUTED")

        SPECIAL_NETS[special_net_name]["net"] = net
        SPECIAL_NETS[special_net_name]["wire"] = wire

    ALL_BOXES = []

    # disconnect all iterms from anywhere else !!! (is this even needed?)
    for inst in reader.block.getInsts():
        iterms = inst.getITerms()
        ALL_BOXES += getInstObs(inst)
        for iterm in iterms:
            master_name = inst.getMaster().getName()
            pin_name = iterm.getMTerm().getName()
            matched_special_net_name = None
            for special_net_name in SPECIAL_NETS:
                net = SPECIAL_NETS[special_net_name]["net"]

                for mapping in SPECIAL_NETS[special_net_name]["map"]:
                    core_pin = SPECIAL_NETS[special_net_name]["core_pin"]
                    pad_pin = mapping["pad_pin"]
                    pad_name_substr = mapping["pad_name_substr"]

                    if (
                        pin_name == pad_pin and pad_name_substr in master_name
                    ):  # pad pin
                        matched_special_net_name = special_net_name
                        print(inst.getName(), "connected to", net.getName())
                        # iterm.connect(net)
                        # iterm.setSpecial()

                        # get the pin shapes
                        iterm_boxes = getITermBoxes(iterm)
                        pad_orient = iterm.getInst().getOrient()
                        for box in iterm_boxes:
                            box["net"] = special_net_name
                            box["type"] = "pad_pin"
                            box["orient"] = pad_orient
                        ALL_BOXES += iterm_boxes
                    elif pin_name == core_pin:  # macro ring
                        matched_special_net_name = special_net_name
                        print(
                            inst.getName(),
                            "will be connected to",
                            master_name,
                            "/",
                            pin_name,
                        )
                        # iterm.connect(net)
                        # iterm.setSpecial()

                        iterm_boxes = getITermBoxes(iterm)
                        for box in iterm_boxes:
                            box["net"] = special_net_name
                            box["type"] = "core_pin"
                            box["stripe_flag"] = False

                        h_stripes = []
                        v_stripes = []
                        for i in range(4):  # ASSUMPTION: 4 CORE RING-STRIPES
                            biggest_pin_box, biggest_pin_box_i = getBiggestBoxAndIndex(
                                iterm_boxes
                            )
                            if biggest_pin_box is None:
                                continue

                            del iterm_boxes[biggest_pin_box_i]

                            biggest_pin_box["stripe_flag"] = True

                            rect = biggest_pin_box["rect"]
                            if rect.dx() > rect.dy():  # horizontal stripe
                                biggest_pin_box["orient"] = "R90"
                                h_stripes.append(biggest_pin_box)
                            else:
                                biggest_pin_box["orient"] = "R0"
                                v_stripes.append(biggest_pin_box)

                        if len(h_stripes) >= 2:
                            if (
                                h_stripes[0]["rect"].yMin()
                                < h_stripes[1]["rect"].yMin()
                            ):
                                h_stripes[0]["side"] = "S"
                                h_stripes[1]["side"] = "N"
                            else:
                                h_stripes[0]["side"] = "N"
                                h_stripes[1]["side"] = "S"
                        elif len(h_stripes) == 1:
                            print(
                                "Warning: only one horizontal stripe found for",
                                core_pin,
                            )
                            if (
                                reader.block.getBBox().yMax()
                                - h_stripes[0]["rect"].yMin()
                                > reader.block.getBBox().yMin()
                                - h_stripes[0]["rect"].yMin()
                            ):
                                h_stripes[0]["side"] = "S"
                            else:
                                h_stripes[0]["side"] = "N"
                        else:
                            print("Warning: No horizontal stripes in the design!")

                        if len(v_stripes) >= 2:
                            if (
                                v_stripes[0]["rect"].xMin()
                                < v_stripes[1]["rect"].xMin()
                            ):
                                v_stripes[0]["side"] = "W"
                                v_stripes[1]["side"] = "E"
                            else:
                                v_stripes[0]["side"] = "E"
                                v_stripes[1]["side"] = "W"
                        elif len(v_stripes) == 1:
                            print(
                                "Warning: only one vertical stripe found for", core_pin
                            )
                            if (
                                reader.block.getBBox().xMax()
                                - v_stripes[0]["rect"].xMin()
                                > reader.block.getBBox().xMin()
                                - v_stripes[0]["rect"].xMin()
                            ):
                                v_stripes[0]["side"] = "W"
                            else:
                                v_stripes[0]["side"] = "E"
                        else:
                            print("Warning: No vertical stripes in the design!")

                        ALL_BOXES += iterm_boxes + v_stripes + h_stripes
            if (
                matched_special_net_name is None
            ):  # other pins are obstructions for our purposes
                new_obstructions = getITermBoxes(iterm)
                for obs in new_obstructions:
                    obs["type"] = "obstruction"
                ALL_BOXES += new_obstructions

    # only types are: obstruction, core_pin, pad_pin
    assert len({box["type"]: None for box in ALL_BOXES}) == 3

    wire_boxes = []

    PAD_PINS = [box for box in ALL_BOXES if isPadPin(box)]
    CORE_STRIPES = [box for box in ALL_BOXES if isStripe(box)]

    # Go over power pad pins, find the nearest ring-stripe,
    # check how to connect to it
    connections_count = 0
    for box in PAD_PINS:
        pad_pin_orient = box["orient"]
        pad_pin_rect = box["rect"]

        ##
        # if connections_count > 29:
        #     pprint(wire_boxes)
        #     break
        ##

        nearest_stripe_box = None
        for stripe in CORE_STRIPES:
            if (
                box["net"] == stripe["net"]
                and stripe["side"] == ORIENT_LOC_MAP[pad_pin_orient]
            ):
                nearest_stripe_box = stripe

        if nearest_stripe_box is None:
            print(
                "Pad pin at",
                box["rect"].ll(),
                box["rect"].ur(),
                "doesn't have a facing stripe. Skipping.",
            )
            continue

        stripe_rect = nearest_stripe_box["rect"]

        # TRANSFORM TO R0 ORIENTATION
        pad_pin_orient_inv = "R" + str((360 - int(pad_pin_orient[1:])) % 360)
        assert pad_pin_orient_inv in ORIENT_LOC_MAP

        pad_pin_rect = transformRect(pad_pin_rect, pad_pin_orient_inv)
        stripe_rect = transformRect(stripe_rect, pad_pin_orient_inv)

        projection_x_min, projection_x_max = max(
            pad_pin_rect.xMin(), stripe_rect.xMin()
        ), min(stripe_rect.xMax(), pad_pin_rect.xMax())

        MIN_WIDTH = 5000
        if projection_x_max - projection_x_min < MIN_WIDTH:
            continue

        # account for obstructions

        from_layer = box["layer"]
        to_layer = nearest_stripe_box["layer"]

        # prefer the highest possible connecting layer (antenna reasons)
        connecting_layer = from_layer
        if not isHighestRoutingLayer(to_layer):
            connecting_layer = getUpperRoutingLayer(to_layer)
        elif not isLowestRoutingLayer(to_layer):
            connecting_layer = getLowerRoutingLayer(to_layer)

        print("Connecting with", connecting_layer.getName(), "to", to_layer.getName())

        wire_rect = odb.Rect(
            projection_x_min, pad_pin_rect.yMin(), projection_x_max, stripe_rect.yMin()
        )

        # adjust width
        MAX_SPACING = getTechMaxSpacing(
            (
                set(layersBetween(from_layer, connecting_layer)).union(
                    layersBetween(connecting_layer, to_layer)
                )
            )
        )
        # note that the box is move away from the pad to evade interactions with
        # nearby pads
        overlapping_boxes = getShapesOverlappingBBox(
            wire_rect.xMin() - MAX_SPACING,
            wire_rect.yMin(),
            wire_rect.xMax() + MAX_SPACING,
            wire_rect.yMax() - MAX_SPACING,
            ext_orient=pad_pin_orient_inv,
            layers=list(
                set(layersBetween(connecting_layer, to_layer)) - set([to_layer])
            ),
        )

        # find the new possible wire_rect width after subtracting the obstructions
        skip = False
        obs_boundaries = []
        for ov_box in overlapping_boxes:
            obs_rect = transformRect(ov_box["rect"], pad_pin_orient_inv)
            # if it is completely contained in an obstruction

            if (
                obs_rect.xMin()
                <= wire_rect.xMin()
                < wire_rect.xMax()
                <= obs_rect.xMax()
            ):
                skip = True
                break

            if (
                wire_rect.xMin() - MAX_SPACING
                <= obs_rect.xMin()
                <= wire_rect.xMax() + MAX_SPACING
            ):
                obs_boundaries.append(obs_rect.xMin())

            if (
                wire_rect.xMin() - MAX_SPACING
                <= obs_rect.xMax()
                <= wire_rect.xMax() + MAX_SPACING
            ):
                obs_boundaries.append(obs_rect.xMax())

        obs_boundaries.sort()

        if len(obs_boundaries) > 0:
            obs_min_x = obs_boundaries[0]
            obs_max_x = obs_boundaries[-1]

            print("Adjusting", wire_rect.ll(), wire_rect.ur())
            print(obs_max_x - obs_min_x)
            print(obs_min_x, obs_max_x)
            if (
                obs_min_x - (wire_rect.xMin() - MAX_SPACING)
                > (wire_rect.xMax() + MAX_SPACING) - obs_max_x
            ):
                wire_rect.set_xhi(obs_min_x - MAX_SPACING)
            else:
                wire_rect.set_xlo(obs_max_x + MAX_SPACING)
            print("To", wire_rect.ll(), wire_rect.ur())

        # leave some space for routing
        from_layer_space = 2 * from_layer.getSpacing() + from_layer.getWidth()
        wire_width = wire_rect.dx() - from_layer_space
        wire_x = wire_rect.xMin() + from_layer_space
        wire_y = wire_rect.yMax()

        if wire_width < MIN_WIDTH:
            skip = True

        if skip:
            continue

        basic_rect = rectIntersection(wire_rect, stripe_rect)

        # 1. extend outside by half of the size of the "basic rectangle"
        wire_y -= basic_rect.dy() // 2
        wire_boxes.append(
            createWireBox(
                wire_width,
                basic_rect.dy() // 2,
                wire_x,
                wire_y,
                from_layer,
                box["net"],
                reorient=pad_pin_orient,
            )
        )

        # 2. vias up till the connecting_layer on the next basic rect
        wire_y -= basic_rect.dy()
        prev_layer = None
        for layer in layersBetween(from_layer, connecting_layer):
            if prev_layer is not None:
                via = create_custom_via(
                    prev_layer,
                    layer,
                    wire_width,
                    basic_rect.dy(),
                    reorient=pad_pin_orient,
                )

                wire_boxes.append(
                    createWireBox(
                        wire_width,
                        basic_rect.dy(),
                        wire_x,
                        wire_y,
                        via,
                        box["net"],
                        reorient=pad_pin_orient,
                    )
                )

            wire_boxes.append(
                createWireBox(
                    wire_width,
                    basic_rect.dy(),
                    wire_x,
                    wire_y,
                    layer,
                    box["net"],
                    reorient=pad_pin_orient,
                )
            )
            prev_layer = layer

        # 3. use the connecting layer to connect to the stripe
        wire_height = wire_y - wire_rect.yMin()
        wire_y = wire_rect.yMin()
        wire_boxes.append(
            createWireBox(
                wire_width,
                wire_height,
                wire_x,
                wire_y,
                connecting_layer,
                box["net"],
                reorient=pad_pin_orient,
            )
        )

        # 4. vias down from the connecting_layer to the to_layer (stripe layer)
        prev_layer = None
        for layer in layersBetween(connecting_layer, to_layer):
            if prev_layer is not None:
                via = create_custom_via(
                    prev_layer,
                    layer,
                    wire_width,
                    basic_rect.dy(),
                    reorient=pad_pin_orient,
                )

                wire_boxes.append(
                    createWireBox(
                        wire_width,
                        basic_rect.dy(),
                        wire_x,
                        wire_y,
                        via,
                        box["net"],
                        reorient=pad_pin_orient,
                    )
                )
            wire_boxes.append(
                createWireBox(
                    wire_width,
                    basic_rect.dy(),
                    wire_x,
                    wire_y,
                    layer,
                    box["net"],
                    reorient=pad_pin_orient,
                )
            )
            prev_layer = layer
        connections_count += 1

    # ROUTING
    print("creating", len(wire_boxes), "wires")
    for box in wire_boxes:
        net_name = box["net"]
        print(net_name, ": drawing a special wire on layer", box["layer"].getName())
        rect = gridify(box["rect"])
        if isRoutingLayer(box["layer"]):
            odb.dbSBox_create(
                SPECIAL_NETS[net_name]["wire"],
                box["layer"],
                *rect.ll(),
                *rect.ur(),
                "COREWIRE",
                odb.dbSBox.UNDEFINED,
            )
        else:
            odb.dbSBox_create(
                SPECIAL_NETS[net_name]["wire"],
                box["layer"],
                (rect.xMin() + rect.xMax()) // 2,
                (rect.yMin() + rect.yMax()) // 2,
                "COREWIRE",
            )

        SPECIAL_NETS[net_name]["covered"] = True

    uncovered_nets = [
        net_name for net_name in SPECIAL_NETS if not SPECIAL_NETS[net_name]["covered"]
    ]
    if len(uncovered_nets) > 0:
        print("No routes created on the following nets:")
        print(uncovered_nets)
        print("Make sure the pads to be connected are facing the core rings")
        sys.exit(1)

    # OUTPUT
    odb.write_lef(odb.dbLib_getLib(reader.db, 1), f"{output}.lef")


cli.add_command(power_route)

if __name__ == "__main__":
    cli()

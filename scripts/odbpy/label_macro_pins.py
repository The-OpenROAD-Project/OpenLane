#!/usr/bin/env python3
# Copyright 2020 Efabless Corporation
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

import click

from reader import OdbReader, click_odb


@click.command()
@click.option(
    "-n",
    "--netlist-def",
    required=True,
    help="DEF view of the design that has the connectivity information",
)
@click.option("-v", "--verbose", default=False, is_flag=True)
@click.option("-a", "--all-shapes", default=False, is_flag=True)
@click.option(
    "-N",
    "--pad-pin-name",
    default="PAD",
    help="Name of the pin of the pad as it appears in the netlist def.",
)
@click.option(
    "-m",
    "--map",
    default="",
    help="Semicolon;delimited extra mappings that are hard to infer from the netlist def. Format: -extra pad_instance_name pad_pin block_pin (INPUT|OUTPUT|INOUT)",
)
@click_odb
def label_macro_pins(
    netlist_def,
    verbose,
    all_shapes,
    pad_pin_name,
    map,
    input_lef,
    reader,
):
    """
    Takes a DEF file with no PINS section, a LEF file that has the shapes of all
    i/o ports that need to labeled, and a netlist where i/o ports are connected
    to single macro pin given also as an input -> writes a PINS section with shapes
    generated over those macro pins, "labels".
    """
    top = reader

    extra_mappings = []
    extra_mappings_pin_names = []
    if map != "":
        extra_mappings = [tuple(m.split()) for m in map.split(";")]
        extra_mappings_pin_names = [tup[2] for tup in extra_mappings]

    def getBiggestBox(iterm):
        inst = iterm.getInst()
        px, py = inst.getOrigin()
        orient = inst.getOrient()
        transform = odb.dbTransform(orient, odb.Point(px, py))

        mterm = iterm.getMTerm()
        mpins = mterm.getMPins()

        # label biggest mpin
        biggest_mpin = None
        biggest_size = -1
        for i in range(len(mpins)):
            mpin = mpins[i]
            box = mpin.getGeometry()[
                0
            ]  # assumes there's only one; to extend and get biggest

            llx, lly = box.xMin(), box.yMin()
            urx, ury = box.xMax(), box.yMax()
            area = (urx - llx) * (ury - lly)
            if area > biggest_size:
                biggest_size = area
                biggest_mpin = mpin

        main_mpin = biggest_mpin
        box = main_mpin.getGeometry()[0]
        ll = odb.Point(box.xMin(), box.yMin())
        ur = odb.Point(box.xMax(), box.yMax())
        # x = (ll.getX() + ur.getX())//2
        # y = (ll.getY() + ur.getY())//2
        # if VERBOSE: print(x, y)
        transform.apply(ll)
        transform.apply(ur)

        layer = box.getTechLayer()

        return [(layer, ll, ur)]

    def getAllBoxes(iterm):
        inst = iterm.getInst()
        px, py = inst.getOrigin()
        orient = inst.getOrient()
        transform = odb.dbTransform(orient, odb.Point(px, py))

        mterm = iterm.getMTerm()
        mpins = mterm.getMPins()

        boxes = []

        for i in range(len(mpins)):
            mpin = mpins[i]
            geometries = mpin.getGeometry()
            for box in geometries:
                # llx, lly = box.xMin(), box.yMin()
                # urx, ury = box.xMax(), box.yMax()
                ll = odb.Point(box.xMin(), box.yMin())
                ur = odb.Point(box.xMax(), box.yMax())
                transform.apply(ll)
                transform.apply(ur)
                layer = box.getTechLayer()
                boxes.append((layer, ll, ur))

        return boxes

    def labelITerm(top, pad_iterm, pin_name, iotype, all_shapes_flag=False):
        net_name = pin_name
        net = top.block.findNet(net_name)
        if net is None:
            net = odb.dbNet_create(top.block, net_name)

        pin_bterm = top.block.findBTerm(pin_name)
        if pin_bterm is None:
            pin_bterm = odb.dbBTerm_create(net, pin_name)

        assert pin_bterm is not None, "Failed to create or find " + pin_name

        pin_bterm.setIoType(iotype)

        pin_bpin = odb.dbBPin_create(pin_bterm)
        pin_bpin.setPlacementStatus("PLACED")

        if not all_shapes_flag:
            boxes = getBiggestBox(pad_iterm)
        else:
            boxes = getAllBoxes(pad_iterm)

        for box in boxes:
            layer, ll, ur = box
            odb.dbBox_create(
                pin_bpin, layer, ll.getX(), ll.getY(), ur.getX(), ur.getY()
            )

        pad_iterm.connect(net)
        pin_bterm.connect(net)

    mapping = OdbReader(input_lef, netlist_def)

    pad_pin_map = {}
    for net in mapping.block.getNets():
        iterms = net.getITerms()
        bterms = net.getBTerms()
        if len(iterms) >= 1 and len(bterms) == 1:
            pin_name = bterms[0].getName()
            if pin_name in extra_mappings_pin_names:
                if verbose:
                    print(pin_name, "handled by an external mapping; skipping...")
                continue

            pad_name = None
            pad_pin_name = None
            for iterm in iterms:
                iterm_pin_name = iterm.getMTerm().getName()
                if iterm_pin_name == pad_pin_name:
                    pad_name = iterm.getInst().getName()
                    pad_pin_name = iterm_pin_name
                    break

            # '\[' and '\]' are common DEF names

            if pad_name is None:
                print(
                    "Warning: net",
                    net.getName(),
                    "has a BTerm but no ITerms that match PAD_PIN_NAME",
                )

                print("Warning: will label the first ITerm on the net!!!!!!!")

                pad_name = iterms[0].getInst().getName()
                pad_pin_name = iterms[0].getMTerm().getName()

            if verbose:
                print(
                    "Labeling ",
                    net.getName(),
                    "(",
                    pin_name,
                    "-",
                    pad_name,
                    "/",
                    pad_pin_name,
                    ")",
                )

            pad_pin_map.setdefault(pad_name, [])
            pad_pin_map[pad_name].append(
                (pad_pin_name, pin_name, bterms[0].getIoType())
            )

    for mapping in extra_mappings:
        pad_pin_map.setdefault(mapping[0], [])
        pad_pin_map[mapping[0]].append((mapping[1], mapping[2], mapping[3]))

    pad_pins_to_label_count = len(
        [
            mapping
            for sublist in [pair[1] for pair in pad_pin_map.items()]
            for mapping in sublist
        ]
    )
    bterms = mapping.block.getBTerms()
    print(
        set([bterm.getName() for bterm in bterms])
        - set(
            [
                mapping[1]
                for sublist in [pair[1] for pair in pad_pin_map.items()]
                for mapping in sublist
            ]
        )
    )
    assert pad_pins_to_label_count == len(
        bterms
    ), "Some pins were not going to be labeled %d/%d" % (
        pad_pins_to_label_count,
        len(bterms),
    )
    print("Labeling", len(pad_pin_map), "pads")
    print("Labeling", pad_pins_to_label_count, "pad pins")
    if verbose:
        print(pad_pin_map)

    ##############

    labeled_count = 0
    labeled = []
    for inst in top.block.getInsts():
        inst_name = inst.getName()
        if inst_name in pad_pin_map:
            for mapping in pad_pin_map[inst_name]:
                labeled_count += 1
                pad_pin_name = mapping[0]
                pin_name = mapping[1]
                iotype = mapping[2]
                if verbose:
                    print("Found: ", inst_name, pad_pin_name, pin_name)

                pad_iterm = inst.findITerm(pad_pin_name)

                labelITerm(top, pad_iterm, pin_name, iotype, all_shapes_flag=all_shapes)

                labeled.append(inst_name)

    assert labeled_count == pad_pins_to_label_count, (
        "Didn't label what I set out to label %d/%d"
        % (labeled_count, pad_pins_to_label_count),
        set(pad_pin_map.keys()) - set(labeled),
    )


if __name__ == "__main__":
    label_macro_pins()

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

"""
Takes a DEF file with no PINS section, a LEF file that has the shapes of all
i/o ports that need to labeled, and a netlist where i/o ports are connected
to single macro pin given also as an input -> writes a PINS section with shapes
generated over those macro pins, "labels".
"""
import argparse
import opendbpy as odb

parser = argparse.ArgumentParser(
    description='Labels pins of macros according to netlist')

parser.add_argument('--netlist-def', '-nd', required=True,
                    help='DEF view of the design that has the connectivity information')

parser.add_argument('--lef', '-l', required=True,
                    help='LEF file needed to have a proper view of the netlist AND the input DEF')

parser.add_argument('--input-def', '-id', required=True,
                    help='DEF view of the design that needs to be labeled')

# parser.add_argument('--input-lef', '-il', required=True,
#                     help='LEF file needed to have a proper view of the input DEF')

parser.add_argument('--output', '-o', required=False,
                    help='Output labeled def file. Defaults to the input def')

parser.add_argument('--verbose', '-v', action='store_true', required=False)

parser.add_argument('--pad-pin-name', '-ppn', required=False,
                    default='pad',
                    help='Name of the pin of the pad as it appears in the netlist def')

parser.add_argument('--pin-size', '-ps', required=False, type=int,
                    default=1,
                    help='Size of the block pin created in um')

parser.add_argument('--db-microns', '-dbum', required=False, type=int,
                    default=1000,
                    help='DEF units per micron')

parser.add_argument('--map', '-m', action='append',
                    nargs=4,
                    required=False,
                    default=[],
                    help='Extra mappins that are hard to infer from the netlist def. Format: -extra pad_instance_name pad_pin block_pin (INPUT|OUTPUT|INOUT)')

args = parser.parse_args()

VERBOSE = args.verbose
PAD_PIN_NAME = args.pad_pin_name
BLOCK_PIN_SIZE = args.pin_size
DEF_UNITS_PER_MICRON = args.db_microns

netlist_def_file_name = args.netlist_def
netlist_lef_file_name = args.lef
input_def_file_name = args.input_def
input_lef_file_name = args.lef

extra_mappings = args.map

if args.output is not None:
    output_def_file_name = args.output
else:
    print("Warning: The input DEF file will be overwritten")
    output_def_file_name = input_def_file_name

mapping_db = odb.dbDatabase.create()
# odb.read_lef(mapping_db, "/home/xrex/usr/devel/openlane_dev/designs/strive2/openlane/runs/striVe2_connectivity/tmp/merged_unpadded.lef")
# odb.read_def(mapping_db, "/home/xrex/usr/devel/openlane_dev/designs/strive2/openlane/runs/striVe2_connectivity/tmp/floorplan/verilog2def_openroad.def")
odb.read_lef(mapping_db, netlist_lef_file_name)
odb.read_def(mapping_db, netlist_def_file_name)

# for later
chip_db = odb.dbDatabase.create()
odb.read_lef(chip_db, input_lef_file_name)
odb.read_def(chip_db, input_def_file_name)

mapping_chip = mapping_db.getChip()
mapping_block = mapping_chip.getBlock()
mapping_nets = mapping_block.getNets()

pad_pin_map = {}
for net in mapping_nets:
    iterms = net.getITerms()
    bterms = net.getBTerms()
    if len(iterms) >= 1 and len(bterms) == 1:
        pad_name = None
        for iterm in iterms:
            if iterm.getMTerm().getName() == PAD_PIN_NAME:
                pad_name = iterm.getInst().getName()
                break

        if pad_name is None:
            print ("Warning: net", net.getName(), "has a BTerm but no ITerms that match PAD_PIN_NAME")
            continue

        pin_name = bterms[0].getName()

        # warning: no \ in names
        pad_name = pad_name.replace("\\", "")
        pin_name = pin_name.replace("\\", "")

        if VERBOSE:
            print("Labeling ", net.getName(), "(", pin_name,"-", pad_name, ")")

        pad_pin_map[pad_name] = (PAD_PIN_NAME, pin_name, bterms[0].getIoType())

for mapping in extra_mappings:
    pad_pin_map.update({
        mapping[0] : (mapping[1], mapping[2], mapping[3])
    })

# pad_pin_map.update({
#     "vdd3v3hclamp[0]": ("vdda", "vdd", "INOUT"),
#     "vdd1v8hclamp[0]": ("vccd", "vdd1v8", "INOUT"),
#     "vsshclamp[0]"   : ("vssa", "vss", "INOUT")
# })

print("Labeling", len(pad_pin_map), "pins")
if VERBOSE: print(pad_pin_map)

##############

# odb.read_lef(chip_db, "/home/xrex/usr/devel/openlane_dev/designs/strive2/openlane/runs/striVe2_connectivity/tmp/merged_unpadded.lef")
# odb.read_def(chip_db, "/home/xrex/usr/devel/openlane_dev/designs/strive2/def/striVe2.def")

chip_chip = chip_db.getChip()
chip_block = chip_chip.getBlock()
chip_insts = chip_block.getInsts()
chip_tech = chip_db.getTech()

for inst in chip_insts:
    inst_name = inst.getName()
    if inst_name in pad_pin_map:
        pad_pin_name = pad_pin_map[inst_name][0]
        pin_name = pad_pin_map[inst_name][1]
        iotype = pad_pin_map[inst_name][2]
        net_name = pin_name
        if VERBOSE: print("Found: ", inst_name, pad_pin_name, pin_name)

        pad_iterm = inst.findITerm(pad_pin_name)
        pad_mterm = pad_iterm.getMTerm()
        px, py = inst.getOrigin()
        orient = inst.getOrient()
        transform = odb.dbTransform(orient, odb.Point(px, py))
        mpins = pad_mterm.getMPins()
        biggest_mpin = None
        biggest_size = -1
        for i in range(len(mpins)):
            mpin = mpins[i]
            box = mpin.getGeometry()[0] #assumes there's only one; to extend and get biggest

            llx, lly = box.xMin(), box.yMin()
            urx, ury = box.xMax(), box.yMax()
            area = (urx-llx)*(ury-lly)
            if area > biggest_size:
                biggest_size = area
                biggest_mpin = mpin

        main_mpin = biggest_mpin
        box = main_mpin.getGeometry()[0]
        ll = odb.Point(box.xMin(), box.yMin())
        ur = odb.Point(box.xMax(), box.yMax())
        transform.apply(ll)
        transform.apply(ur)
        x = (ll.getX() + ur.getX())//2
        y = (ll.getY() + ur.getY())//2
        pad_pin_layer = box.getTechLayer()

        if VERBOSE: print(x, y)

        net = chip_block.findNet(net_name)
        if net is None:
            net = odb.dbNet_create(chip_block, net_name)

        pin_bterm = odb.dbBTerm_create(net, pin_name)
        if pin_bterm is None:
            print(pin_name, " not created; skipping...")
            continue
        pin_bterm.setIoType(iotype)

        # x = odb.new_intp(); y = odb.new_intp()
        # pad_iterm.getAvgXY(x, y); # crashes with clamps
        # x = odb.intp_value(x); y = odb.intp_value(y)

        pin_bpin = odb.dbBPin_create(pin_bterm)
        pin_bpin.setPlacementStatus("PLACED")
        odb.dbBox_create(pin_bpin,
                         pad_pin_layer,
                         x-BLOCK_PIN_SIZE*DEF_UNITS_PER_MICRON,
                         y-BLOCK_PIN_SIZE*DEF_UNITS_PER_MICRON,
                         x+BLOCK_PIN_SIZE*DEF_UNITS_PER_MICRON,
                         y+BLOCK_PIN_SIZE*DEF_UNITS_PER_MICRON)

        odb.dbITerm_connect(pad_iterm, net)
        pin_bterm.connect(net)

print("Writing", output_def_file_name)
odb.write_def(chip_block, output_def_file_name)

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


parser.add_argument('--lef', '-l',
                    nargs='+',
                    type=str,
                    default=None,
                    required=True,
                    help='LEF file needed to have a proper view of the netlist AND the input DEF')

parser.add_argument('--input-def', '-id', required=True,
                    help='DEF view of the design that needs to be labeled')

parser.add_argument('--output', '-o', required=False,
                    help='Output labeled def file. Defaults to the input def')

parser.add_argument('--verbose', '-v', action='store_true', required=False)

parser.add_argument('--all-shapes-flag', '-all', action='store_true', required=False)

parser.add_argument('--pad-pin-name', '-ppn', required=False,
                    default='PAD',
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
                    help='Extra mappings that are hard to infer from the netlist def. Format: -extra pad_instance_name pad_pin block_pin (INPUT|OUTPUT|INOUT)')

args = parser.parse_args()

VERBOSE = args.verbose
PAD_PIN_NAME = args.pad_pin_name
BLOCK_PIN_SIZE = args.pin_size
DEF_UNITS_PER_MICRON = args.db_microns

all_shapes_flag = args.all_shapes_flag
netlist_def_file_name = args.netlist_def
netlist_lef_file_names = args.lef
input_def_file_name = args.input_def
input_lef_file_names = args.lef

extra_mappings = args.map
extra_mappings_pin_names = [tup[2] for tup in extra_mappings]

if args.output is not None:
    output_def_file_name = args.output
else:
    print("Warning: The input DEF file will be overwritten")
    output_def_file_name = input_def_file_name

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
            llx, lly = box.xMin(), box.yMin()
            urx, ury = box.xMax(), box.yMax()
            ll = odb.Point(box.xMin(), box.yMin())
            ur = odb.Point(box.xMax(), box.yMax())
            transform.apply(ll)
            transform.apply(ur)
            layer = box.getTechLayer()
            boxes.append((layer, ll, ur))

    return boxes


def labelITerm(iterm, pin_name, iotype, all_shapes_flag=False):
    net_name = pin_name
    net = chip_block.findNet(net_name)
    if net is None:
        net = odb.dbNet_create(chip_block, net_name)

    pin_bterm = chip_block.findBTerm(pin_name)
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
        odb.dbBox_create(pin_bpin,
                         layer,
                         ll.getX(),
                         ll.getY(),
                         ur.getX(),
                         ur.getY())


    odb.dbITerm_connect(pad_iterm, net)
    pin_bterm.connect(net)


mapping_db = odb.dbDatabase.create()
for lef in netlist_lef_file_names:
    odb.read_lef(mapping_db, lef)
odb.read_def(mapping_db, netlist_def_file_name)

# for later
chip_db = odb.dbDatabase.create()
for lef in input_lef_file_names:
    print(lef)
    odb.read_lef(chip_db, lef)
odb.read_def(chip_db, input_def_file_name)

mapping_chip = mapping_db.getChip()
mapping_block = mapping_chip.getBlock()
mapping_nets = mapping_block.getNets()

pad_pin_map = {}
for net in mapping_nets:
    iterms = net.getITerms()
    bterms = net.getBTerms()
    if len(iterms) >= 1 and len(bterms) == 1:
        pin_name = bterms[0].getName()
        if pin_name in extra_mappings_pin_names:
            if VERBOSE: print(pin_name, "handled by an external mapping; skipping...")
            continue

        pad_name = None
        pad_pin_name = None
        for iterm in iterms:
            iterm_pin_name = iterm.getMTerm().getName()
            if iterm_pin_name == PAD_PIN_NAME:
                pad_name = iterm.getInst().getName()
                pad_pin_name = iterm_pin_name
                break

        # '\[' and '\]' are common DEF names

        if pad_name is None:
            print ("Warning: net", net.getName(), "has a BTerm but no ITerms that match PAD_PIN_NAME")

            print ("Warning: will label the first ITerm on the net!!!!!!!")

            pad_name = iterms[0].getInst().getName()
            pad_pin_name = iterms[0].getMTerm().getName()

        if VERBOSE:
            print("Labeling ", net.getName(), "(", pin_name,"-", pad_name, "/", pad_pin_name, ")")

        pad_pin_map.setdefault(pad_name, [])
        pad_pin_map[pad_name].append((pad_pin_name, pin_name, bterms[0].getIoType()))

for mapping in extra_mappings:
    pad_pin_map.setdefault(mapping[0], [])
    pad_pin_map[mapping[0]].append((mapping[1], mapping[2], mapping[3]))

pad_pins_to_label_count = len([mapping for sublist in [pair[1] for pair in pad_pin_map.items()] for mapping in sublist])
bterms = mapping_block.getBTerms()
print(set([bterm.getName() for bterm in bterms]) - set([mapping[1] for sublist in [pair[1] for pair in pad_pin_map.items()] for mapping in sublist]))
assert pad_pins_to_label_count == len(bterms), "Some pins were not going to be labeled %d/%d" % (pad_pins_to_label_count, len(bterms))
print("Labeling", len(pad_pin_map), "pads")
print("Labeling", pad_pins_to_label_count, "pad pins")
if VERBOSE: print(pad_pin_map)

##############

chip_chip = chip_db.getChip()
chip_block = chip_chip.getBlock()
chip_insts = chip_block.getInsts()
chip_tech = chip_db.getTech()

labeled_count = 0
labeled = []
for inst in chip_insts:
    inst_name = inst.getName()
    if inst_name in pad_pin_map:
        for mapping in pad_pin_map[inst_name]:
            labeled_count += 1
            pad_pin_name = mapping[0]
            pin_name = mapping[1]
            iotype = mapping[2]
            if VERBOSE: print("Found: ", inst_name, pad_pin_name, pin_name)

            pad_iterm = inst.findITerm(pad_pin_name)

            labelITerm(pad_iterm, pin_name, iotype, all_shapes_flag=all_shapes_flag)

            labeled.append(inst_name)

assert labeled_count == pad_pins_to_label_count, ("Didn't label what I set out to label %d/%d" % (labeled_count, pad_pins_to_label_count),
                                                  set(pad_pin_map.keys())-set(labeled))

print("Writing", output_def_file_name)
odb.write_def(chip_block, output_def_file_name)

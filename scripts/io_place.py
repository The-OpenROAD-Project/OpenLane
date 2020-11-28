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
Places the IOs according to an input file. Supports regexes.
File format:
#N|#S|#E|#W
pin1_regex
pin2_regex
...

#S|#N|#E|#W
...
...
"""

import re
import sys
import argparse
import random
import opendbpy as odb

parser = argparse.ArgumentParser(description='''
Places the IOs according to an input file. Supports regexes.
File format:
#N|#S|#E|#W
pin1_regex (low co-ordinates to high co-ordinates; e.g., bot to top and left to right)
pin2_regex
...

#S|#N|#E|#W
...
...
''')

parser.add_argument('--input-def', '-d', required=True,
                    help='Input DEF')

parser.add_argument('--input-lef', '-l', required=True,
                    help='Input LEF')

parser.add_argument('--output-def', '-o',
                    default='output.def', help='Output DEF with new pin placements')

parser.add_argument('--config', '-cfg',
                    help='Configuration file. See -h for format')

parser.add_argument('--ver-layer', '-vl',
                    default=3,
                    help='Number of metal layer to place the vertical pins on. Defaults to SKY130 metal layer names. 1-based.')

parser.add_argument('--hor-layer', '-hl',
                    default=4,
                    help='Number of metal layer to place the horizontal pins on. Defaults to SKY130 metal layer names. 1-based.')

parser.add_argument('--hor-width-mult', '-hwm',
                    default=2,
                    help='')

parser.add_argument('--ver-width-mult', '-vwm',
                    default=2,
                    help='')

parser.add_argument('--length', '-len', type=float,
                    default=2,
                    help='')

parser.add_argument('--hor-extension', '-hext', type=float,
                    default=0.0,
                    help='')

parser.add_argument('--ver-extension', '-vext', type=float,
                    default=0.0,
                    help='')

parser.add_argument('--reverse', '-rev',
                    choices=['N', 'E', 'S', 'W'],
                    nargs='+',
                    required=False,
                    default=[],
                    help='')

parser.add_argument('--bus-sort', '-bsort', action='store_true',
                    default=False,
                    help='Sort pins so that bus bits with the same index are grouped'
                    'together. e.g., a[0] b[0] c[0] a[1] b[1] c[1]')
# TODO
# width, length, and extension multipliers

args = parser.parse_args()

def_file_name = args.input_def
lef_file_name = args.input_lef
output_def_file_name = args.output_def
config_file_name = args.config
bus_sort_flag = args.bus_sort

h_layer_index = int(args.hor_layer)
v_layer_index = int(args.ver_layer)

h_width_mult = int(args.hor_width_mult)
v_width_mult = int(args.ver_width_mult)

LENGTH = int(1000*args.length)

H_EXTENSION = int(1000*args.hor_extension)
V_EXTENSION = int(1000*args.ver_extension)

if H_EXTENSION < 0:
    H_EXTENSION = 0

if V_EXTENSION < 0:
    V_EXTENSION = 0

reverse_arr = args.reverse
reverse_arr = ["#"+rev for rev in reverse_arr]

def getGrid(origin, count, step):
    tracks = []
    pos = origin
    for i in range(count):
        tracks.append(pos)
        pos += step
    assert len(tracks) > 0
    tracks.sort()

    return tracks

def equallySpacedSeq(m, arr):
    seq = []
    n = len(arr)
    # Bresenham
    indices = [i*n//m + n//(2*m) for i in range(m)]
    for i in indices:
        seq.append(arr[i])
    return seq

# HUMAN SORTING: https://stackoverflow.com/questions/5967500/how-to-correctly-sort-a-string-with-a-number-inside
def atof(text):
    try:
        retval = float(text)
    except ValueError:
        retval = text
    return retval

def natural_keys(enum):
    text = enum[0]
    text = re.sub("(\[|\]|\.|\$)", "", text)
    '''
    alist.sort(key=natural_keys) sorts in human order
    http://nedbatchelder.com/blog/200712/human_sorting.html
    (see toothy's implementation in the comments)
    float regex comes from https://stackoverflow.com/a/12643073/190597
    '''
    return [atof(c) for c in re.split(r'[+-]?([0-9]+(?:[.][0-9]*)?|[.][0-9]+)', text)]

def bus_keys(enum):
    text = enum[0]
    m = re.match("^.*\[(\d+)\]$", text)
    if not m:
        return -1
    else:
        return int(m.group(1))

# read config

pin_placement_cfg = {"#N": [], "#E": [], "#S": [], "#W": []}
cur_side = None
if config_file_name is not None and config_file_name != "":
    with open(config_file_name, 'r') as config_file:
        for line in config_file:
            line = line.split()
            if len(line) == 0:
                continue

            if len(line) > 1:
                print("Only one entry allowed per line.")
                sys.exit(1)

            token = line[0]

            if cur_side is not None and token[0] != "#":
                pin_placement_cfg[cur_side].append(token)
            elif token not in ["#N", "#E", "#S", "#W", "#NR", "#ER", "#SR", "#WR", "#BUS_SORT"]:
                print("Valid directives are #N, #E, #S, or #W. Append R for reversing the default order.",
                      "Use #BUS_SORT to group 'bus bits' by index.",
                      "Please make sure you have set a valid side first before listing pins")
                sys.exit(1)
            elif token == "#BUS_SORT":
                bus_sort_flag = True
            else:
                if len(token) == 3:
                    token = token[0:2]
                    reverse_arr.append(token)
                cur_side = token

# build a list of pins

db_top = odb.dbDatabase.create()
odb.read_lef(db_top, lef_file_name)
odb.read_def(db_top, def_file_name)

chip_top = db_top.getChip()
block_top = chip_top.getBlock()
top_design_name = block_top.getName()
tech = db_top.getTech()

H_LAYER = tech.findRoutingLayer(h_layer_index)
V_LAYER = tech.findRoutingLayer(v_layer_index)

H_WIDTH = h_width_mult * H_LAYER.getWidth()
V_WIDTH = v_width_mult * V_LAYER.getWidth()

print("Top-level design name:", top_design_name)

bterms = block_top.getBTerms()
bterms_enum = []
for bterm in bterms:
    pin_name = bterm.getName()
    bterms_enum.append((pin_name, bterm))

# sort them "humanly"
bterms_enum.sort(key=natural_keys)
if bus_sort_flag:
    bterms_enum.sort(key=bus_keys)
bterms = [bterm[1] for bterm in bterms_enum]

pin_placement = {"#N": [], "#E": [], "#S": [], "#W": []}
bterm_regex_map = {}
for side in pin_placement_cfg:
    for regex in pin_placement_cfg[side]:  # going through them in order
        regex += "$"  # anchor
        for bterm in bterms:
            # if a pin name matches multiple regexes, their order will be
            # arbitrary. More refinement requires more strict regexes (or just
            # the exact pin name).
            pin_name = bterm.getName()
            if re.match(regex, pin_name) is not None:
                if bterm in bterm_regex_map:
                    print("Warning: Multiple regexes matched", pin_name,
                          ". Those are", bterm_regex_map[bterm], "and", regex)
                    print("Only the first one is taken into consideration.")
                    continue
                    # sys.exit(1)
                bterm_regex_map[bterm] = regex
                pin_placement[side].append(bterm)  # to maintain the order

unmatched_bterms = [bterm for bterm in bterms if bterm not in bterm_regex_map]

if len(unmatched_bterms) > 0:
    print("Warning: Some pins weren't matched by the config file")
    print("Those are:", [bterm.getName() for bterm in unmatched_bterms])
    if True:
        print("Assigning random sides to the above pins")
        for bterm in unmatched_bterms:
            random_side = random.choice(list(pin_placement.keys()))
            pin_placement[random_side].append(bterm)
    else:
        sys.exit(1)


assert len(block_top.getBTerms()) == len(pin_placement["#N"] + pin_placement["#E"] + pin_placement["#S"] + pin_placement["#W"])

# generate slots


DIE_AREA = block_top.getDieArea()
BLOCK_LL_X = DIE_AREA.xMin()
BLOCK_LL_Y = DIE_AREA.yMin()
BLOCK_UR_X = DIE_AREA.xMax()
BLOCK_UR_Y = DIE_AREA.yMax()

print("Block boundaries:", BLOCK_LL_X, BLOCK_LL_Y, BLOCK_UR_X, BLOCK_UR_Y)


origin, count, step = odb.new_int(0), odb.new_int(0), odb.new_int(0)
block_top.findTrackGrid(H_LAYER).getGridPatternY(0, origin, count, step)
origin, count, step = odb.get_int(origin),  odb.get_int(count), odb.get_int(step)

h_tracks = getGrid(origin, count, step)

origin, count, step = odb.new_int(0), odb.new_int(0), odb.new_int(0)
block_top.findTrackGrid(V_LAYER).getGridPatternX(0, origin, count, step)
origin, count, step = odb.get_int(origin),  odb.get_int(count), odb.get_int(step)

v_tracks = getGrid(origin, count, step)

for rev in reverse_arr:
    pin_placement[rev].reverse()

# create the pins
for side in pin_placement:
    start = 0
    if side in ["#N", "#S"]:
        slots = equallySpacedSeq(len(pin_placement[side]), v_tracks)
    else:
        slots = equallySpacedSeq(len(pin_placement[side]), h_tracks)

    assert len(slots) == len(pin_placement[side])

    for i in range(len(pin_placement[side])):
        bterm = pin_placement[side][i]
        slot = slots[i]

        pin_name = bterm.getName()
        pins = bterm.getBPins()
        if len(pins) > 0:
            print("Warning:", pin_name, "already has shapes. Modifying them")
            assert len(pins) == 1
            pin_bpin = pins[0]
        else:
            pin_bpin = odb.dbBPin_create(bterm)

        pin_bpin.setPlacementStatus("PLACED")

        if side in ["#N", "#S"]:
            rect = odb.Rect(0, 0, V_WIDTH, LENGTH+V_EXTENSION)
            if side == "#N":
                y = BLOCK_UR_Y-LENGTH
            else:
                y = BLOCK_LL_Y-V_EXTENSION
            rect.moveTo(slot-V_WIDTH//2, y)
            odb.dbBox_create(pin_bpin, V_LAYER, *rect.ll(), *rect.ur())
        else:
            rect = odb.Rect(0, 0, LENGTH+H_EXTENSION, H_WIDTH)
            if side == "#E":
                x = BLOCK_UR_X-LENGTH
            else:
                x = BLOCK_LL_X-H_EXTENSION
            rect.moveTo(x, slot-H_WIDTH//2)
            odb.dbBox_create(pin_bpin, H_LAYER, *rect.ll(), *rect.ur())

print("Writing", output_def_file_name)
odb.write_def(block_top, output_def_file_name)

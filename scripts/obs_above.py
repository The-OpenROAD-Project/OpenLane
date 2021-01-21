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
takes a lef file and a y position => obstructs everything above
"""
import re
import sys

ARGV = sys.argv
if len(ARGV) < 4:
    print("Usage " + ARGV[0] + " threshold_y_pos extra_width_left extra_width_right [macro_names]")
    sys.exit(-1)
MAX_Y = float(ARGV[1])
EXTRA_WIDTH_LEFT = float(ARGV[2])
EXTRA_WIDTH_RIGHT = float(ARGV[3])
macro_names = None
if len(ARGV) > 4:
    macro_names = ARGV[4:]
SIZE_X, SIZE_Y = -1, -1
ORIGIN_X, ORIGIN_Y = -1, -1
LAYER_LIST = ["li1", "met1", "met2", "met3", "met4", "met5"]
SIZE_REGEX = r"^\s*SIZE\s+(-?\d+\.?\d*)\s+BY\s+(-?\d+\.?\d*)\s+;$"
ORIGIN_REGEX = r"^\s*ORIGIN\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+;$"



enable = macro_names is None
obs_section = False
for line in sys.stdin:
    if line.isspace():
        print(line, end='')
        continue

    origin_match = re.search(ORIGIN_REGEX, line)
    if origin_match:
        ORIGIN_X, ORIGIN_Y = float(origin_match.group(1)), float(origin_match.group(2))

    if line.startswith("MACRO"):
        tokens = line.split()
        assert len(tokens) == 2, line
        if macro_names and tokens[1] in macro_names:
            enable = True
        LAYERS = {layer:False for layer in LAYER_LIST}

    if macro_names and line.startswith("END"):
        tokens = line.split()
        if len(tokens) > 1:
            assert len(tokens) == 2, line
            if tokens[1] in macro_names:
                enable = False

    size_match = re.search(SIZE_REGEX, line)
    if size_match:
        SIZE_X, SIZE_Y = float(size_match.group(1)), float(size_match.group(2))
    elif line.find("OBS") != -1:
        obs_section = True
    elif obs_section and line.find("END") != -1:
        obs_section = False
        if enable:
            for layer in LAYERS:  # draw remaining obs on layers that didn't appear
                if not LAYERS[layer]:
                    print("     LAYER %s ;" % (layer))
                    print("       RECT %.3f %.3f %.3f %.3f ;" % (-ORIGIN_X-EXTRA_WIDTH_LEFT, MAX_Y, SIZE_X-ORIGIN_X+EXTRA_WIDTH_RIGHT, SIZE_Y-ORIGIN_Y))

    print(line, end='')
    if obs_section and line.find("LAYER") != -1:
        line = line.split()
        if enable:
            LAYERS[line[1]] = True
            print("       RECT %.3f %.3f %.3f %.3f ;" % (-ORIGIN_X-EXTRA_WIDTH_LEFT, MAX_Y, SIZE_X-ORIGIN_X+EXTRA_WIDTH_RIGHT, SIZE_Y-ORIGIN_Y))


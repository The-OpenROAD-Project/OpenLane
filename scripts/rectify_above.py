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

# takes a lef file and a y position => trims all RECT statements above the
# threshold
import re
import os
import sys

ARGV = sys.argv
if len(ARGV) < 2:
    print("Usage " + ARGV[0] + " threshold_y_pos [macro_names]")
    sys.exit(-1)
MAX_Y = float(ARGV[1])
macro_name = None
if len(ARGV) > 2:
    macro_name = ARGV[2:]
LAYERS = ["li1", "met1", "met2", "met3", "met4", "met5"]
RECT_REGEX = r"^\s*RECT\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+;$"

def is_0_area(llx, lly, urx, ury):
    return (llx == urx) or (lly == ury)

def rectify(llx, lly, urx, ury, enable=True):
    if not enable:
        return (llx, lly, urx, ury)
    if lly > MAX_Y:
        return (None, None, None, None)
    ury = min(MAX_Y, ury)
    return (llx, lly, urx, ury)

layer = ""
enable = macro_name is None
for line in sys.stdin:
    if line.isspace():
        print(line, end='')
        continue
    # skip POLYGONS
    if line.strip().startswith("POLYGON"):
        continue

    if macro_name and line.startswith("MACRO"):
        tokens = line.split()
        assert len(tokens) == 2, line
        if tokens[1] in macro_name:
            enable = True

    if macro_name and line.startswith("END"):
        tokens = line.split()
        if len(tokens) > 1:
            assert len(tokens) == 2, line
            if tokens[1] in macro_name:
                enable = False

    rect_match = re.search(RECT_REGEX, line)
    if rect_match:
        llx, lly, urx, ury = rect_match.group(1), rect_match.group(2), rect_match.group(3), rect_match.group(4)
        llx, lly, urx, ury = rectify(float(llx), float(lly), float(urx), float(ury), enable)
        if llx is not None and not is_0_area(llx, lly, urx, ury):
            print(layer + line[:line.find('R')] + "RECT %.3f %.3f %.3f %.3f ;" % (llx, lly, urx, ury))
            if layer != "": # LAYER printed, clear it
                layer = ""
    else:
        if line.find("LAYER") != -1: # print it only if there're RECTs
            layer = line
        else:
            print(line, end='')

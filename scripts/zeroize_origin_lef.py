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
takes a lef file and a rectangle => trims all RECT statements within the area
"""
import re
import sys

RECT_REGEX = r"^\s*RECT\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+;$"
ORIGIN_REGEX = r"^\s*ORIGIN\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+;$"

OFFSET_X = OFFSET_Y = 0
for line in sys.stdin:
    if line.isspace():
        continue
    origin_match = re.search(ORIGIN_REGEX, line)
    if origin_match:
        OFFSET_X, OFFSET_Y = float(origin_match.group(1)), float(origin_match.group(2))
        print(line[:line.find('O')] + "ORIGIN %.3f %.3f ;" %(0, 0))
    else:
        rect_match = re.search(RECT_REGEX, line)
        if rect_match:
            llx, lly, urx, ury = float(rect_match.group(1)), float(rect_match.group(2)), float(rect_match.group(3)), float(rect_match.group(4))
            print(line[:line.find('R')] + "RECT %.3f %.3f %.3f %.3f ;" % (llx+OFFSET_X,
                                                                          lly+OFFSET_Y,
                                                                          urx+OFFSET_X,
                                                                          ury+OFFSET_Y))
        else:
            print(line,end='')

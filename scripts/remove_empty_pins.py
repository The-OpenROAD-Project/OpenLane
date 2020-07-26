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
removes empty PINs from a lef file (to be extended into a full LEF clean-up)
"""

import sys
import re

PIN_REGEX = r"^\s*PIN\s+(\S+)$"
RECT_REGEX = r"^\s*RECT\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+;$"

current_pin = None
for line in sys.stdin:
    pin_match = re.search(PIN_REGEX, line)
    if pin_match is not None:
        current_pin = pin_match.group(1)
        empty = True
        pin_content = line
    else:
        if current_pin is not None:
            pin_content += line
            rect_match = re.search(RECT_REGEX, line)
            if rect_match is not None:
                empty = False
                # print("LOL RECT" +  str(current_pin))
        else:
            print(line, end='')

    if re.search(r"END\s+"+re.escape(str(current_pin)), line) is not None:
        # print("FOUND THE END OF " + str(current_pin))
        current_pin = None
        if not empty:
            # print("PRINTING IT AS WELL")
            print(pin_content)


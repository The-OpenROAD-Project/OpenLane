#!/usr/bin/env python3
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


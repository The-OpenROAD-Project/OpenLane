#!/usr/bin/env python3
import re
import sys

PLACED_STRIPE_REGEX = r"(PLACED|STRIPE)\s+\(\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+\)"
STRIPE_REGEX = r"(STRIPE|FOLLOWPIN)\s+\(\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+\)\s+\(\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+\)"
DIEAREA_REGEX = r"^DIEAREA\s+\(\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+\)\s+\(\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+\)\s+;$"
ROW_REGEX = r"^ROW.+\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*).*DO.*;$"

OFFSET_X = OFFSET_Y = 0
for line in sys.stdin:
    if line.isspace():
        continue
    diearea_match = re.search(DIEAREA_REGEX, line)
    if diearea_match:
        OFFSET_X, OFFSET_Y = int(diearea_match.group(1)), int(diearea_match.group(2))
        UR_X, UR_Y = int(diearea_match.group(3)), float(diearea_match.group(4))
        print("DIEAREA ( 0 0 ) ( %d %d ) ;" %(UR_X-OFFSET_X, UR_Y-OFFSET_Y))
        continue
    row_match = re.search(ROW_REGEX, line)
    if row_match:
        x, y = int(row_match.group(1)), int(row_match.group(2))
        line = re.sub(str(x), str(x-OFFSET_X), line)
        line = re.sub(str(y), str(y-OFFSET_Y), line)
        print(line, end='')
        continue
    stripe_match = re.search(STRIPE_REGEX, line)
    if stripe_match:
        x1, y1 = int(stripe_match.group(2)), int(stripe_match.group(3))
        x2, y2 = int(stripe_match.group(4)), int(stripe_match.group(5))
        line = re.sub(str(x1), str(x1-OFFSET_X), line)
        line = re.sub(str(y1), str(y1-OFFSET_Y), line)
        line = re.sub(str(x2), str(x2-OFFSET_X), line)
        line = re.sub(str(y2), str(y2-OFFSET_Y), line)
        print(line, end='')
        continue
    placed_stripe_match = re.search(PLACED_STRIPE_REGEX, line)
    if placed_stripe_match:
        x, y = int(placed_stripe_match.group(2)), int(placed_stripe_match.group(3))
        line = re.sub(str(x), str(x-OFFSET_X), line)
        line = re.sub(str(y), str(y-OFFSET_Y), line)
        print(line, end='')
        continue
    print(line, end='')


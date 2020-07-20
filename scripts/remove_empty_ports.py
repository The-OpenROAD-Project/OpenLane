#!/usr/bin/env python3

import re
import sys

lef_data = sys.stdin.read()
lef_data = re.sub(r"\s*PORT\s+END", "", lef_data)
print(lef_data)

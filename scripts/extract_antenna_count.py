#!/usr/bin/env python3
import re
import sys

in_data = sys.stdin.read()
print(re.findall(r"[Aa]ntenna violations:\s*(\d+)", in_data)[-1], end="")

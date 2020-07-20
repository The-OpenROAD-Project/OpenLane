#!/usr/bin/env python3
"""
Assumptions: DBum = 1000
rounds all (high accuracy) numbers in a LEF file
"""

import re
import sys

ARGV = sys.argv
if len(ARGV) < 2:
    print("Usage " + ARGV[0] + " MANUFACTURINGGRID")
    sys.exit(-1)

MANUFACTURINGGRID = float(ARGV[1])

PRECISE_NUM_REGEX = r"-?\d+\.\d\d\d+"

def gridify(n, f):
    """
    e.g., (1.1243, 0.005) -> 1.120
    """
    return round(n / f) * f


for line in sys.stdin:
    line = re.split('(\s+)', line)

    for i in range(len(line)): # for each token
        token = line[i]
        num_match = re.search(PRECISE_NUM_REGEX, token)
        if num_match:
            x = float(num_match.group(0))
            # print(x)
            x = gridify(x, MANUFACTURINGGRID)
            token = "%.3f" % x
        line[i] = token

    print("".join(line), end='')

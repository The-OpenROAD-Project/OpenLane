#!/usr/bin/env python3
# Copyright 2021 UET Lahore, Pakistan
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
# Author: Tayyeb Mahmood
"""
This Script removes specified input cells ARGV[2] from the lib file input ARGV [1] and emits trimmed lib in ARGV[3]
"""

import sys
import re

ARGV = sys.argv

with open(ARGV[2], 'r') as f:
    e = [line.strip() for line in f]
f.close()

with open(ARGV[1], 'r') as f:
    s = f.read()
f.close()

c = [(t.start(), t.group(1)) for t in re.finditer(r'cell\s*\(\s*\"(\w*)\"\s*\)', s)]

k = [cell[1] not in e for cell in c]

h = s[:c[0][0]]

r = len(k)

for i in range(r):
    f = c[i + 1][0] if i < r - 1 else -1 
    h += s[c[i][0]:f] if k[i] else '/* removed {} */\n\n'.format(c[i][1])

h += '}'

with open(ARGV[3], 'w') as f:
    f.write(h)
f.close()


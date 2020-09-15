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

import os
import sys
import re

argv = sys.argv
argc = len(argv)

if argc < 4:
    print("Usage: antenna_info_copy.py from.lef to.lef output.lef <macro_mappings: <name in from.lef> <name in to.lef> ... >  ")
    sys.exit(-1)

# build map with antenna info
# { cell_name : {pin_name : [antenna info1, antenna info2, ...]}, ... }
antenna_dict = {}
cur_cell = None
cur_pin = None
with open(argv[1], 'r') as from_lef_file:
    for line in from_lef_file:
        if cur_cell is None:
            match = re.search(r"^MACRO\s+(\S+)", line)
            if match:
                cur_cell = match.group(1)
                antenna_dict[cur_cell] = {}
                # print("Current cell:", cur_cell)
        elif re.search(r"END %s" % (re.escape(cur_cell)), line):
            cur_cell = None
        elif cur_pin is None:
            match = re.search(r"PIN\s+(\S+)", line)
            if match:
                cur_pin = match.group(1)
                antenna_dict[cur_cell][cur_pin] = []
                # print("Current pin:", cur_pin)
        elif re.search(r"END %s" % (re.escape(cur_pin)), line):
            cur_pin = None
        else:  # cur_pin and cur_cell aren't None
            if re.search(r"ANTENNA.*;", line):
                antenna_dict[cur_cell][cur_pin].append(line)

for i in range(4, argc, 2):
    if i+1 >= argc:
        print("Mapping syntax: <name in from.lef> <name in to.lef>")
        sys.exit(-1)
    if argv[i] not in antenna_dict:
        print("Invalid mapping:", argv[i], argv[i+1])
        sys.exit(-1)
    antenna_dict[argv[i+1]] = antenna_dict[argv[i]]

cur_cell = None
cur_pin = None
with open(argv[2], 'r') as to_lef_file,\
        open(argv[3], 'w+') as output_lef_file:
    for line in to_lef_file:
        if cur_cell is None:
            match = re.search(r"^MACRO\s+(\S+)", line)
            if match:
                cell = match.group(1)
                if cell in antenna_dict:
                    cur_cell = cell
        elif re.search(r"END %s" % (re.escape(cur_cell)), line):
            cur_cell = None
        elif cur_pin is None:
            match = re.search(r"PIN\s+(\S+)", line)
            if match:
                pin = match.group(1)
                if pin in antenna_dict[cur_cell]:
                    cur_pin = pin
        elif re.search(r"END %s" % (re.escape(cur_pin)), line):
            for info in antenna_dict[cur_cell][cur_pin]:
                line = info + line
            cur_pin = None
        output_lef_file.write(line)

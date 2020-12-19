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

"""

import argparse
import re
import os
import opendbpy as odb

parser = argparse.ArgumentParser(
    description='Places macros in positions and orientations specified by a config file')

parser.add_argument('--lef', '-l',
                    nargs='+',
                    type=str,
                    default=None,
                    required=True,
                    help='Input LEF file(s)')

parser.add_argument('--input-def', '-id', required=True,
                    help='DEF view of the design that needs to have its instances placed')

parser.add_argument('--output-def', '-o', required=True,
                    help='Output placed DEF file')

parser.add_argument('--config', '-c', required=True,
                    help='Configuration file')

parser.add_argument('--fixed', '-f', action='store_true', default=False,
                help="a flag to signal whether the placement should be fixed or placed")

args = parser.parse_args()
input_lef_file_names = args.lef
input_def_file_name = args.input_def
output_def_file_name = args.output_def
config_file_name = args.config
fixed_flag = args.fixed

LEF2OA_MAP = {"N": "R0",
              "S": "R180",
              "W": "R90",
              "E": "R270",
              "FN": "MY",
              "FS": "MX",
              "FW": "MX90",
              "FE": "MY90"}
def lef_rot_to_oa_rot(rot):
    if rot in LEF2OA_MAP:
        return LEF2OA_MAP[rot]
    else:
        assert rot in [item[1] for item in LEF2OA_MAP.items()], rot
        return rot

def gridify(n, f):
    """
    e.g., (1.1243, 0.005) -> 1.120
    """
    return round(n / f) * f

# read config
macros = {}
with open(config_file_name, 'r') as config_file:
    for line in config_file:
        # Discard comments and empty lines
        line = line.split('#')[0].strip()
        if not line:
            continue
        line = line.split()
        macros[line[0]] = [str(int(float(line[1])*1000)), str(int(float(line[2])*1000)), line[3]]

print("Placing the following macros:")
print(macros)

db_design = odb.dbDatabase.create()

for lef in input_lef_file_names:
    odb.read_lef(db_design, lef)
odb.read_def(db_design, input_def_file_name)

chip_design = db_design.getChip()
block_design = chip_design.getBlock()
top_design_name = block_design.getName()
print("Design name:", top_design_name)

macros_cnt = len(macros)
for inst in block_design.getInsts():
    inst_name = inst.getName()
    if inst.isFixed():
        assert inst_name not in macros, inst_name
        continue
    if inst_name in macros:
        print("Placing", inst_name)
        macro_data = macros[inst_name]
        x = gridify(int(macro_data[0]), 5)
        y = gridify(int(macro_data[1]), 5)
        inst.setOrient(lef_rot_to_oa_rot(macro_data[2]))
        inst.setLocation(x, y)
        if fixed_flag:
            inst.setPlacementStatus("FIRM")
        else:
            inst.setPlacementStatus("PLACED")
        del macros[inst_name]

assert not macros, ("Macros not found:", macros)

print("Successfully placed", macros_cnt, "instances")

odb.write_def(block_design, output_def_file_name)
assert os.path.exists(output_def_file_name), "Output not written successfully"

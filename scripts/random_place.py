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

import argparse
import random
import opendbpy as odb

parser = argparse.ArgumentParser(
    description='Places instances in random locations in layout. Intended for cases,'
    'where using a placer would be an overkill (very small number of instances < ~40)')

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

args = parser.parse_args()

input_lef_file_names = args.lef
input_def_file_name = args.input_def
output_def_file_name = args.output_def

def gridify(n, f):
    """
    e.g., (1.1243, 0.005) -> 1.120
    """
    return round(n / f) * f

db_design = odb.dbDatabase.create()

for lef in input_lef_file_names:
    odb.read_lef(db_design, lef)
odb.read_def(db_design, input_def_file_name)

chip_design = db_design.getChip()
block_design = chip_design.getBlock()
top_design_name = block_design.getName()
core_area = block_design.getCoreArea()
LLX, LLY =  core_area.ll()
URX, URY = core_area.ur()
insts = block_design.getInsts()

print("Design name:", top_design_name)
print("Core Area Boundaries:", LLX, LLY, URX, URY)
print("Number of instances", len(insts))

placed_cnt = 0
for inst in insts:
    if inst.isFixed():
        continue
    master = inst.getMaster()
    master_width = master.getWidth()
    master_height = master.getHeight()
    x = gridify(random.randint(LLX, max(LLX, URX-master_width)), 5)
    y = gridify(random.randint(LLY, max(LLY, URY-master_height)), 5)
    inst.setLocation(x, y)
    inst.setPlacementStatus("PLACED")

    placed_cnt += 1

print("Placed", placed_cnt, "instances")

odb.write_def(block_design, output_def_file_name)

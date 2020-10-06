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
import opendbpy as odb

# overkill
parser = argparse.ArgumentParser(
    description='gets the core dimensions from DEF/LEF')

parser.add_argument('--input-def', '-d', required=True)

parser.add_argument('--input-lef', '-l', required=True)

args = parser.parse_args()

input_lef_file_name = args.input_lef
input_def_file_name = args.input_def

db = odb.dbDatabase.create()
odb.read_lef(db, input_lef_file_name)
odb.read_def(db, input_def_file_name)

chip = db.getChip()
tech = db.getTech()
block = chip.getBlock()

r = block.getCoreArea()
print(r.dx()/tech.getDbUnitsPerMicron(), r.dy()/tech.getDbUnitsPerMicron())

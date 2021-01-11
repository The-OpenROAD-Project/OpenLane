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
import re
import opendbpy as odb

parser = argparse.ArgumentParser(
    description='Creates obstructions in def files.')

parser.add_argument('--lef', '-l',
                    nargs='+',
                    type=str,
                    default=None,
                    required=True,
                    help='LEF file needed to have a proper view of the DEF files.')

parser.add_argument('--input-def', '-id', required=True,
                    help='DEF view of the design that needs to be obstructed.')

parser.add_argument('--obstructions', '-obs', required=True,
                    help='Format: layer llx lly urx ury, ... (in microns)')

parser.add_argument('--output', '-o', required=True,
                    help='Output DEF file.')

args = parser.parse_args()

input_lef_file_names = args.lef
input_def_file_name = args.input_def
obs_args = args.obstructions
output_def_file_name = args.output

RE_NUMBER = r'[\-]?[0-9]+(\.[0-9]+)?'
RE_OBS = r'(?P<layer>\S+)\s+' r'(?P<bbox>' +  RE_NUMBER + r'\s+' + RE_NUMBER + r'\s+' + RE_NUMBER + r'\s+' + RE_NUMBER + r')'

obses = obs_args.split(',')
obs_list = []
for obs in obses:
    obs = obs.strip()
    m = re.match(RE_OBS, obs)
    assert m,\
        "Incorrectly formatted input (%s).\n Format: layer llx lly urx ury, ..." % (obs)
    layer = m.group('layer')
    bbox = [float(x) for x in m.group('bbox').split()]
    obs_list.append((layer, bbox))

design_db = odb.dbDatabase.create()

for lef in input_lef_file_names:
    odb.read_lef(design_db, lef)

odb.read_def(design_db, input_def_file_name)

design_chip = design_db.getChip()
design_block = design_chip.getBlock()
design_insts = design_block.getInsts()
design_tech = design_db.getTech()

for obs in obs_list:
    layer = obs[0]
    bbox = obs[1]
    dbu = design_tech.getDbUnitsPerMicron()
    bbox = [int(x*dbu) for x in bbox]
    print("Creating an obstruction on", layer, "at", *bbox, "(DBU)")
    odb.dbObstruction_create(design_block, design_tech.findLayer(layer), *bbox)

odb.write_def(design_block, output_def_file_name)

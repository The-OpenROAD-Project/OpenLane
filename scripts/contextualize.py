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

parser = argparse.ArgumentParser(
    description='Produces a DEF file where a design is shown in the context of its instantiation in a top-level design')

parser.add_argument('--macro-def', '-md', required=True,
                    help='DEF view of the design')

parser.add_argument('--macro-lef', '-ml', required=True,
                    help='LEF file needed to have a proper view of the macro DEF')

parser.add_argument('--top-def', '-td', required=True,
                    help='DEF view of the top-level design where the macro is instantiated')
parser.add_argument('--top-lef', '-tl', required=True,
                    help='LEF file needed to have a proper view of the top-level DEF')

parser.add_argument('--output', '-o', required=True,
                    default='output.def', help='Output Contextualized DEF')

parser.add_argument('--keep-inner-connections', '-keep', action='store_true', default=False,
                help="If set, the internal cells will remain conneted in the otput DEF")


args = parser.parse_args()

macro_def_file_name = args.macro_def
macro_lef_file_name = args.macro_lef
top_def_file_name = args.top_def
top_lef_file_name = args.top_lef
keep_flag = args.keep_inner_connections

output_def_file_name = args.output

# in the tcl side
# top_lef_new_file_name = os.path.join(os.path.dirname(macro_lef_file_name), os.path.basename(macro_lef_file_name) + ".top.lef")
# top_def_new_file_name = os.path.join(os.path.dirname(macro_def_file_name), os.path.basename(macro_def_file_name) + ".top.def")

# copy(os.path.normpath(top_lef_file_name), top_lef_new_file_name)
# copy(os.path.normpath(top_def_file_name), top_def_new_file_name)

# top_lef_file_name = top_lef_new_file_name
# top_def_file_name = top_def_new_file_name

db_macro = odb.dbDatabase.create()
db_top = odb.dbDatabase.create()
odb.read_lef(db_macro, top_lef_file_name) # must read first to have consistent views with the top-level
odb.read_lef(db_macro, macro_lef_file_name) # rest of the macros that don't appear in the top-level are covered here
odb.read_def(db_macro, macro_def_file_name)

odb.read_lef(db_top, top_lef_file_name)
odb.read_def(db_top, top_def_file_name)

chip_macro = db_macro.getChip()
block_macro = chip_macro.getBlock()
macro_design_name = block_macro.getName()

chip_top = db_top.getChip()
block_top = chip_top.getBlock()
top_design_name = block_top.getName()

print("Block design name:", macro_design_name)
print("Top-level design name:", top_design_name)

nets_top = block_top.getNets()
to_connect = {}
MACRO_TOP_PLACEMENT_X = 0
MACRO_TOP_PLACEMENT_Y = 0
MACRO_TOP_PLACEMENT_ORIENT = 0

assert macro_design_name in [inst.getMaster().getName() for inst in block_top.getInsts()], "%s not found in %s" % (macro_design_name, top_design_name)

for net in nets_top:
    iterms = net.getITerms()  # asssumption: no pins (bterms) on top level
    block_net_name = None
    for iterm in iterms:
        macro_name = iterm.getMTerm().getMaster().getName()
        if macro_name == macro_design_name:
            block_net_name = iterm.getMTerm().getName()
            macro_top_inst = iterm.getInst()
            MACRO_TOP_PLACEMENT_X, MACRO_TOP_PLACEMENT_Y = macro_top_inst.getLocation()
            MACRO_TOP_PLACEMENT_ORIENT = macro_top_inst.getOrient()
            print("Block net name: ", block_net_name)
            break
    if block_net_name is not None:
        to_connect[block_net_name] = []
        for iterm in iterms:
            macro_name = iterm.getMTerm().getMaster().getName()
            if macro_name != macro_design_name:
                to_connect[block_net_name].append(iterm)
        block_net_name = None


        # print(macro_name, inst_name, end= ' ')
        # print(iterm.getMTerm().getName())

# print(to_connect)

nets_macro = block_macro.getNets()
created_macros = {}
for net in nets_macro:
    iterms = net.getITerms()  # asssumption: no pins (bterms) on top level
    if not keep_flag:
        for iterm in iterms:
            odb.dbITerm_disconnect(iterm)
    if net.getName() in to_connect:
        for node_iterm in to_connect[net.getName()]:
            node_master = node_iterm.getMTerm().getMaster()
            node_inst = node_iterm.getInst()
            node_inst_name = node_iterm.getInst().getName()
            if node_inst_name not in created_macros:
                created_macros[node_inst_name] = 1
                print("Creating: ", node_master.getName(), node_inst_name)
                new_inst = odb.dbInst_create(block_macro, node_master, node_inst_name)
                new_inst.setOrient(node_inst.getOrient())
                new_inst.setLocation(node_inst.getLocation()[0]-MACRO_TOP_PLACEMENT_X, node_inst.getLocation()[1]-MACRO_TOP_PLACEMENT_Y)
                new_inst.setPlacementStatus("FIRM")
            else:
                new_inst = block_macro.findInst(node_inst_name)
            odb.dbITerm_connect(new_inst.findITerm(node_iterm.getMTerm().getName()), net)

odb.write_def(block_macro, output_def_file_name)

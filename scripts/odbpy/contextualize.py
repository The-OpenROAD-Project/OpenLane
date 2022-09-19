# Copyright 2020-2022 Efabless Corporation
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
import odb

import click

from reader import OdbReader, click_odb


@click.command()
@click.option(
    "-D",
    "--top-def",
    required=True,
    help="DEF view of the top-level design instantiating the macro",
)
@click.option(
    "-L",
    "--top-lef",
    required=True,
    help="DEF view of the top-level design instantiating the macro",
)
@click.option("--keep-inner-connections", default=False, is_flag=True)
@click_odb
def contextualize(reader, top_def, top_lef, keep_inner_connections):
    reader.add_lef(top_lef)

    top = OdbReader(top_lef, top_def)
    macro = reader

    print("Block design name:", macro.name)
    print("Top-level design name:", top.name)

    nets_top = top.block.getNets()
    to_connect = {}
    MACRO_TOP_PLACEMENT_X = 0
    MACRO_TOP_PLACEMENT_Y = 0

    assert macro.name in [
        inst.getMaster().getName() for inst in top.block.getInsts()
    ], "%s not found in %s" % (macro.name, top.name)

    for net in nets_top:
        iterms = net.getITerms()  # asssumption: no pins (bterms) on top level
        block_net_name = None
        for iterm in iterms:
            macro_name = iterm.getMTerm().getMaster().getName()
            if macro_name == macro.name:
                block_net_name = iterm.getMTerm().getName()
                macro_top_inst = iterm.getInst()
                (
                    MACRO_TOP_PLACEMENT_X,
                    MACRO_TOP_PLACEMENT_Y,
                ) = macro_top_inst.getLocation()
                print("Block net name: ", block_net_name)
                break
        if block_net_name is not None:
            to_connect[block_net_name] = []
            for iterm in iterms:
                macro_name = iterm.getMTerm().getMaster().getName()
                if macro_name != macro.name:
                    to_connect[block_net_name].append(iterm)
            block_net_name = None

            # print(macro_name, inst_name, end= ' ')
            # print(iterm.getMTerm().getName())

    # print(to_connect)

    nets_macro = macro.block.getNets()
    created_macros = {}
    for net in nets_macro:
        iterms = net.getITerms()  # asssumption: no pins (bterms) on top level
        if not keep_inner_connections:
            for iterm in iterms:
                iterm.disconnect()
        if net.getName() in to_connect:
            for node_iterm in to_connect[net.getName()]:
                node_master = node_iterm.getMTerm().getMaster()
                node_inst = node_iterm.getInst()
                node_inst_name = node_iterm.getInst().getName()
                if node_inst_name not in created_macros:
                    created_macros[node_inst_name] = 1
                    print("Creating: ", node_master.getName(), node_inst_name)
                    new_inst = odb.dbInst_create(
                        macro.block, node_master, node_inst_name
                    )
                    new_inst.setOrient(node_inst.getOrient())
                    new_inst.setLocation(
                        node_inst.getLocation()[0] - MACRO_TOP_PLACEMENT_X,
                        node_inst.getLocation()[1] - MACRO_TOP_PLACEMENT_Y,
                    )
                    new_inst.setPlacementStatus("FIRM")
                else:
                    new_inst = macro.block.findInst(node_inst_name)
                new_inst.findITerm(node_iterm.getMTerm().getName()).connect(net)


if __name__ == "__main__":
    contextualize()

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

import odb


def remove_buffers(block_design, dont_buffer):
    design_nets = block_design.getNets()
    dont_buffer_nets = [net for net in design_nets if net.getConstName() in dont_buffer]

    for net in dont_buffer_nets:
        # get the cells driving the dont buffer net
        master_cells = get_master_cells(net)

        assert (
            len(master_cells) == 1
        ), f"Net {net.getConstName()} is driven by multiple cells."

        cell_name = master_cells[0].getMaster().getConstName()
        assert (
            "buf" in cell_name
        ), f"{net.getConstName()} isn't driven by a buffer cell. It is driven by {cell_name}. "

        # get the net connected to the input pin of this buffer
        input_nets, output_nets = get_nets(master_cells[0])

        assert (
            len(output_nets) == 1
        ), f"{cell_name} has more than one output port. Please make sure that {cell_name} is a buffer cell."
        assert (
            len(input_nets) == 1
        ), f"{cell_name} has more than one input port. Please make sure that {cell_name} is a buffer cell."
        assert (
            output_nets[0].getConstName() in dont_buffer
        ), f"{cell_name} isn't driving any of the dont buffer nets."

        # remove the buffer cell instance
        master_cells[0].destroy(master_cells[0])

        # connect buffer cell input net to the dont buffer port
        for input_net in input_nets:
            input_net_master_cell = get_master_cells(input_net)[0]
            _, output_nets_2 = get_nets(input_net_master_cell)
            output_net_it = output_nets_2[0].getITerms()[0]
            output_net_it.connect(net)


def get_master_cells(net):
    master_cells = []
    for it in net.getITerms():
        master_instance = it.getInst().getMaster()
        master_cells.append(it.getInst())
        cell_type = master_instance.getConstName()
        cell_pin = it.getMTerm().getConstName()
        print(f"Net {net.getConstName()} is connected to {cell_type}, pin {cell_pin}")

    return master_cells


def get_nets(master_instance):
    input_nets = []
    output_nets = []
    for iterm in master_instance.getITerms():
        if iterm.isSpecial():  # Skip special nets
            continue

        if iterm.isInputSignal():
            input_pin_net = iterm.getNet()
            input_nets.append(input_pin_net)

        if iterm.isOutputSignal():
            output_pin_net = iterm.getNet()
            output_nets.append(output_pin_net)

    return input_nets, output_nets


def main():
    parser = argparse.ArgumentParser(description="DEF to Liberty.")

    parser.add_argument(
        "--input_lef",
        "-l",
        nargs="+",
        type=str,
        default=None,
        required=True,
        help="Input LEF file(s)",
    )
    parser.add_argument(
        "--input_def", "-i", required=True, help="DEF view of the design."
    )
    parser.add_argument("--output_def", "-o", required=True, help="Output DEF file")
    parser.add_argument(
        "--dont_buffer", "-d", required=True, help="Dont Buffer list of output ports."
    )

    args = parser.parse_args()
    input_lef_files = args.input_lef
    input_def_file = args.input_def
    output_def = args.output_def
    dont_buffer_list = args.dont_buffer

    # parse input def/lef files
    db_design = odb.dbDatabase.create()

    for lef in input_lef_files:
        odb.read_lef(db_design, lef)

    odb.read_def(db_design, input_def_file)

    chip_design = db_design.getChip()
    block_design = chip_design.getBlock()

    # remove buffers connected to the dont buffer nets
    remove_buffers(block_design, dont_buffer_list)

    # write output def
    odb.write_def(block_design, output_def)


if __name__ == "__main__":
    main()

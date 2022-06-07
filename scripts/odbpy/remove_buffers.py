# Copyright 2021-2022 Efabless Corporation
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


@click.command()
@click.option(
    "-p",
    "--ports",
    required=True,
    help="Semicolon;delimited net(s) to remove buffers from",
)
@click_odb
def remove_buffers(output, ports, input_lef, input_def):
    reader = OdbReader(input_lef, input_def)

    design_nets = reader.block.getNets()
    dont_buffer_nets = [net for net in design_nets if net.getConstName() in ports]

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
            output_nets[0].getConstName() in ports
        ), f"{cell_name} isn't driving any of the dont buffer nets."

        # remove the buffer cell instance
        master_cells[0].destroy(master_cells[0])

        # connect buffer cell input net to the dont buffer port
        for input_net in input_nets:
            input_net_master_cell = get_master_cells(input_net)[0]
            _, output_nets_2 = get_nets(input_net_master_cell)
            output_net_it = output_nets_2[0].getITerms()[0]
            output_net_it.connect(net)

    odb.write_def(reader.block, output)


if __name__ == "__main__":
    remove_buffers()

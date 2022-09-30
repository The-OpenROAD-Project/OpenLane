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

import os
import re
from typing import List

import click

from reader import click_odb


def get_pin_name(pin: odb.dbITerm):
    cell = pin.getInst()
    cell_name = cell.getName()
    master_pin = pin.getMTerm()
    master_pin_name = master_pin.getConstName()
    return f"{cell_name}/{master_pin_name}"


def get_sinks_terms(net: odb.dbNet) -> List[odb.dbITerm]:
    sinks = []
    for it in net.getITerms():
        cell = it.getInst()
        cell_pin = it.getMTerm()

        master_instance = cell.getMaster()
        master_name = master_instance.getConstName()

        if cell_pin.getIoType() == "INPUT":
            print(
                f"  * Net {net.getConstName()} sinks into {get_pin_name(it)} ({master_name})..."
            )
            sinks.append(it)

    return sinks


def get_drivers(net: odb.dbNet) -> List[odb.dbInst]:
    drivers = []
    for it in net.getITerms():
        cell = it.getInst()
        cell_pin = it.getMTerm()

        master_instance = cell.getMaster()
        master_name = master_instance.getConstName()

        if cell_pin.getIoType() == "OUTPUT":
            print(
                f"  * Net {net.getConstName()} is driven by {get_pin_name(it)} ({master_name})..."
            )
            drivers.append(cell)

    return drivers


def get_io(cell: odb.dbInst):
    inputs = []
    outputs = []
    for iterm in cell.getITerms():
        if iterm.isSpecial():  # Skip special nets
            continue

        if iterm.isInputSignal():
            input_pin_net = iterm.getNet()
            inputs.append((iterm, input_pin_net))

        if iterm.isOutputSignal():
            output_pin_net = iterm.getNet()
            outputs.append((iterm, output_pin_net))

    return inputs, outputs


@click.command()
@click.option(
    "-m",
    "--match",
    "rx_str",
    required=True,
    help="A regular expression matching all nets to remove.",
)
@click_odb
def remove_buffers(reader, rx_str):
    if rx_str != "^$":
        # Save some compute time :)

        rx = re.compile(rx_str)

        design_nets = reader.block.getNets()
        dont_buffer_nets = [
            net for net in design_nets if rx.match(net.getConstName()) is not None
        ]

        for net in dont_buffer_nets:
            net_name = net.getConstName()
            print(f"* Attempting to unbuffer {net_name}...")
            # get the cells driving the dont buffer net
            drivers = get_drivers(net)

            if len(drivers) > 1:
                print(f"Net {net_name} is driven by multiple cells.")
                exit(os.EX_DATAERR)
            elif len(drivers) == 0:
                print(f"Net {net_name} is not driven by any cell..")
                exit(os.EX_DATAERR)

            buffer = drivers[0]
            buffer_name = drivers[0].getName()
            master = buffer.getMaster()
            master_name = master.getConstName()

            if "buf" not in master_name:
                print(
                    f"*  {net_name} isn't driven by a buffer cell. It is driven by {buffer_name} ({master_name}). Skipping..."
                )
                continue

            # get the net connected to the input pin of this buffer
            inputs, outputs = get_io(buffer)

            if len(inputs) != 1:
                print(
                    f"*  {master_name} has more than one output port. Doesn't appear to actually be a buffer. Skipping..."
                )
                continue
            if len(outputs) != 1:
                print(
                    f"{master_name} has more than one output port. Doesn't appear to actually be a buffer. Skipping..."
                )
                continue

            _, input_net = inputs[0]
            _, output_net = outputs[0]

            print("  * Reconnecting IO...")
            # We connect the driver's output to the output_net: there may not be a
            # sink with ITerms in case of things like output ports for example.
            buffer_input_driver = get_drivers(input_net)[0]
            _, bid_outputs = get_io(buffer_input_driver)
            (bid_iterm, _) = bid_outputs[0]
            bid_iterm.connect(output_net)
            print(
                f"  * Connected buffer output({output_net.getConstName()}) to {get_pin_name(bid_iterm)}."
            )

            print(f"  * Removing buffer {buffer_name} ({master_name})...")
            odb.dbInst.destroy(buffer)

            input_net_sinks = get_sinks_terms(input_net)
            for iterm in input_net_sinks:
                iterm.connect(output_net)
                print(
                    f"  * Connected buffer output({output_net.getConstName()}) to {get_pin_name(iterm)}."
                )

            print(f"  * Removing net {input_net.getName()}...")
            odb.dbNet.destroy(input_net)

        print("  * Done.")


if __name__ == "__main__":
    remove_buffers()

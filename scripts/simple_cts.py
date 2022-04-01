#!/usr/bin/env python3
# Copyright 2020-2021 Efabless Corporation
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

# Original code by M. Shalan, Translated to Python by Donn

import io
import re
import math
import click
import textwrap


@click.command()
@click.option("--fanout", required=True)
@click.option("--clk-net", required=True)
@click.option("--root-clkbuf", required=True, help="Clock tree root buffer type")
@click.option("--clkbuf", required=True, help="Clock tree branching buffer type")
@click.option(
    "--clkbuf-input-pin", required=True, help="Name of input pin in clock buffers"
)
@click.option(
    "--clkbuf-output-pin", required=True, help="Name of output pin in clock buffers"
)
@click.option("--clk-port", required=True, help="Name of clock pin in storage elements")
@click.option("-o", "--output", required=True, help="Name of output netlist")
@click.argument("input_netlist")
def cli(
    fanout,
    clk_net,
    clkbuf,
    root_clkbuf,
    clkbuf_input_pin,
    clkbuf_output_pin,
    clk_port,
    output,
    input_netlist,
):
    """
    Shalan's Simple Clock Tree Synthesizer

    Made to work on Yosys netlists.
    """
    fanout = int(fanout)

    netlist_str = open(input_netlist).read()
    clock_port_rx = re.compile(rf"{re.escape(clk_port)}\(\s*{re.escape(clk_net)}\s*\)")
    leaves = len(clock_port_rx.findall(netlist_str))
    levels = math.ceil(math.log(leaves, fanout))

    buffers = [0] * (levels + 1)
    buffers[0] = leaves

    verilog_wires = []
    verilog_cells = []

    cell_count = 0
    for level in range(1, levels):
        level_before = level - 1
        instance = f"_CTS_buf_{level}_"
        input_wire = f"clk_{level}_"
        output_wire = f"clk_{level_before}_"

        # obviously translated c-style for loop
        i = 0
        while i < leaves:
            next_level_fanout = fanout ** (level + 1)
            ii = i // next_level_fanout * next_level_fanout
            cell_name = f"{instance}{i}"
            verilog_cells.append(
                textwrap.dedent(
                    f"""
            {clkbuf} {cell_name} (
            \t.{clkbuf_input_pin}({input_wire}{ii}),
            \t.{clkbuf_output_pin}({output_wire}{i})
            );"""
                )
            )
            verilog_wires.append(f"wire {output_wire}{i};")
            buffers[level] += 1
            cell_count += 1

            i += fanout**level

    root_net = f"clk_{levels - 1}_0"
    verilog_cells.append(
        textwrap.dedent(
            f"""
    {root_clkbuf} _CTS_root(
    \t.{clkbuf_input_pin}({clk_net}),
    \t.{clkbuf_output_pin}({root_net})
    );"""
        )
    )
    verilog_wires.append(f"wire clk_{levels - 1}_0;\n")

    with io.StringIO() as sio:
        state = 0
        ff_count = 0
        for line in netlist_str.split("\n"):
            if state == 0:
                if "wire" in line:
                    state = 1
                print(line, file=sio)
            elif state == 1:
                if "wire" not in line and "input" not in line and "output" not in line:
                    state = 2
                    print("\n// CTS added wires:", file=sio)
                    print("\n".join(verilog_wires), file=sio)
                    print("\n// CTS added buffers:", file=sio)
                    print("\n".join(verilog_cells), file=sio)
                    print(line, file=sio)
                else:
                    print(line, file=sio)
            elif state == 2:
                clk_port = clock_port_rx.search(line)
                if clk_port is not None:
                    clk_wire_name = f"clk_0_{ff_count // fanout * fanout}"
                    line_replaced = re.sub(re.escape(clk_net), clk_wire_name, line)
                    ff_count += 1
                    print(line_replaced, file=sio)
                else:
                    print(line, file=sio)
        with open(output, "w") as f:
            f.write(sio.getvalue())


if __name__ == "__main__":
    cli()

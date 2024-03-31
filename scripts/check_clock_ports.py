# Copyright 2023 Efabless Corporation
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
import json
import click


@click.command()
@click.option("--netlist-in", required=True, help="JSON netlist")
@click.option("--top", required=True, help="Top module")
@click.argument("clock_ports", nargs=-1)
def main(netlist_in, top, clock_ports):
    netlist = json.load(open(netlist_in, encoding="utf8"))
    valid_input_ports = set()
    for name, info in netlist["modules"][top]["ports"].items():
        if info["direction"] not in ["input", "inout"]:
            continue
        width = len(info["bits"])
        offset = info.get("offset", 0)
        # See https://github.com/YosysHQ/yosys/blob/91685355a082f1b5fbc539d0ec484f4d484f5baa/passes/cmds/portlist.cc#L65
        if width == 1:
            valid_input_ports.add(name)  # Accept just the name if it's a wire
        msb = offset + width - 1
        lsb = offset
        for bit in range(lsb, msb + 1):
            valid_input_ports.add(f"{name}[{bit}]")  # Also accept bits in a bus
    for clock_port in clock_ports:
        if clock_port not in valid_input_ports:
            print(f"{clock_port} ", end="")


if __name__ == "__main__":
    main()

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
import json
import click


@click.command()
@click.option("--netlist-in", required=True, help="JSON netlist")
@click.option("--top", required=True, help="Top module")
@click.argument("clock_ports", nargs=-1)
def main(netlist_in, top, clock_ports):
    netlist = json.load(open(netlist_in, encoding="utf8"))
    top_module = netlist["modules"][top]
    ports = top_module["ports"]
    for clock_port in clock_ports:
        if clock_port not in ports:
            print(f"{clock_port} ", end="")


if __name__ == "__main__":
    main()

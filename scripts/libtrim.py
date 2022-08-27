#!/usr/bin/python3
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

# Direct-translated from Perl to Python by Donn.

import re
import click


@click.command()
@click.option("-c", "--cell-file", required=True, help="Cell file")
@click.option("-o", "--output", required=True, help="Output liberty file")
@click.argument("input_lib_files", nargs=-1)
def cli(cell_file, output, input_lib_files):
    excluded_cells = [
        cell.strip()
        for cell in open(cell_file).read().strip().split("\n")
        if cell.strip() != ""
    ]

    output_file_handle = open(output, "w")

    def write(string):
        print(string, file=output_file_handle)

    cell_start_rx = re.compile(r"(\s*)cell\s*\(\"?(.*?)\"?\)\s*\{")

    state = 0
    brace_count = 0
    for file in input_lib_files:
        input_lib_str = open(file).read()
        input_lib_lines = input_lib_str.split("\n")
        for line in input_lib_lines:
            if state == 0:
                cell_m = cell_start_rx.search(line)
                if cell_m is not None:
                    whitespace = cell_m[1]
                    cell_name = cell_m[2]
                    if cell_name in excluded_cells:
                        state = 2
                        write(f"{whitespace}/* removed {cell_name} */")
                    else:
                        state = 1
                        write(line)
                    brace_count = 1
                else:
                    write(line)
            elif state in [1, 2]:
                if "{" in line:
                    brace_count += 1
                if "}" in line:
                    brace_count -= 1
                if state == 1:
                    write(line)
                if brace_count == 0:
                    state = 0

    output_file_handle.close()


if __name__ == "__main__":
    cli()

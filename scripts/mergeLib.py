#!/usr/bin/env python3
# Copyright 2022 Efabless Corporation
# Copyright 2020 The OpenROAD Project
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

# Direct-translated (more or less) from Perl to Python by Donn.

import click

import re
import io

library_start_rx = re.compile(r"library\s*\(")
cell_start_rx = re.compile(r"^\s*cell\s*\(")


def write_header(output_file: io.IOBase, final_library_name: str, input_str: str):
    f = output_file

    for line in input_str.split("\n"):
        if library_start_rx.match(line) is not None:
            print(f"library ({final_library_name}) {{", file=f)
        elif cell_start_rx.match(line) is not None:
            break
        else:
            print(line, file=f)


def write_footer(output_file: io.IOBase):
    f = output_file

    print("\n}", file=f)


@click.command()
@click.option("-o", "--output", required=True, help="Output file")
@click.option("-n", "--name", required=True, help="The name of the final library")
@click.argument("input_libs", nargs=-1)
def mergeLib(output, name, input_libs):
    file_strings = [open(input_lib).read() for input_lib in input_libs]
    out_str = ""

    with io.StringIO() as f:
        # Write everything up until (and excluding) the first cell to f,
        # replacing the library() header with a new name
        write_header(f, name, file_strings[0])

        # Find and write cells (and cells only)
        for input_str in file_strings:
            brace_count = 0
            for line in input_str.split("\n"):
                if cell_start_rx.match(line) is not None:
                    if brace_count != 0:
                        raise Exception(
                            "Error: New cell before finishing the previous one."
                        )
                    else:
                        print(f"\n{line}", file=f)
                        brace_count += 1
                elif brace_count > 0:
                    if "{" in line:
                        brace_count += 1
                    if "}" in line:
                        brace_count -= 1
                    print(line, file=f)

        # Write a footer (just a })
        write_footer(f)

        out_str = f.getvalue()

    with open(output, "w") as f:
        f.write(out_str)


if __name__ == "__main__":
    mergeLib()

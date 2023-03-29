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
import click


@click.command()
@click.argument("report")
def tristate_only(report):
    content = open(report).read()
    if "Warning:" not in content:
        print("No errors found")
        exit(0)
    warnings = content.split("Warning: ")[1:]
    for warning in warnings:
        warning_header = warning.rstrip().split("\n")[0]
        if "is used but has no driver" in warning_header:
            print(f"Error: {warning_header} found")
            exit(1)
        warning_lines = [
            line for line in warning.rstrip().split("\n")[1:] if line.startswith(" ")
        ]
        warning_lines_tristate = [
            line for line in warning_lines if "tribuf" in line and line.startswith(" ")
        ]
        if len(warning_lines_tristate) == 0:
            print(f"Error: {warning_header} found")
            exit(1)

    print("Only tristate errors found")
    exit(0)


if __name__ == "__main__":
    tristate_only()

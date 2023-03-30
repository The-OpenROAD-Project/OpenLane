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
            print(f"Error: {warning_header}")
            exit(1)
        warning_lines = [
            line for line in warning.rstrip().split("\n")[1:] if line.startswith(" ")
        ]
        warning_lines_tristate = [
            line for line in warning_lines if "tribuf" in line and line.startswith(" ")
        ]
        if len(warning_lines_tristate) == 0:
            print(f"Error: {warning_header}")
            exit(1)

    print("Only tristate errors found")
    exit(0)


if __name__ == "__main__":
    tristate_only()

## Keeping this here because one will forget in the future what
## this really does

## Sample input flagging fail (trisate + other)
#
# 21. Executing CHECK pass (checking for obvious problems).
# Checking module spm...
# Warning: multiple conflicting drivers for spm.\x:
#     module input f[0]
#     module input x[0]
# Warning: multiple conflicting drivers for spm.\y:
#     port Y[0] of cell $ternary$/media/karim/ssd_gamed/work/ef/openlane-src/designs/spm/src/spm.v:18$1 ($tribuf)
#     port Y[0] of cell $ternary$/media/karim/ssd_gamed/work/ef/openlane-src/designs/spm/src/spm.v:19$3 ($tribuf)
#     module input y[0]
# Warning: found logic loop in module spm:
#     cell $ternary$/media/karim/ssd_gamed/work/ef/openlane-src/designs/spm/src/spm.v:18$1 ($tribuf)
#     wire \y
# Found and reported 3 problems.
#
## Another one (trisate + others)
#
# 21. Executing CHECK pass (checking for obvious problems).
# Checking module spm...
# Warning: multiple conflicting drivers for spm.\y:
#     port Y[0] of cell $ternary$/media/karim/ssd_gamed/work/ef/openlane-src/designs/spm/src/spm.v:16$1 ($tribuf)
#     port Y[0] of cell $ternary$/media/karim/ssd_gamed/work/ef/openlane-src/designs/spm/src/spm.v:17$3 ($tribuf)
#     module input y[0]
# Warning: Wire spm.\k is used but has no driver.
# Warning: found logic loop in module spm:
#     cell $ternary$/media/karim/ssd_gamed/work/ef/openlane-src/designs/spm/src/spm.v:16$1 ($tribuf)
#     wire \y
# Found and reported 3 problems.
#
## Another one (others)
#
# 21. Executing CHECK pass (checking for obvious problems).
# Checking module spm...
# Warning: Wire spm.\k is used but has no driver.
# Found and reported 1 problems.
#
## Sample input flagging success
#
# 21. Executing CHECK pass (checking for obvious problems).
# Checking module spm...
# Warning: multiple conflicting drivers for spm.\y:
#     port Y[0] of cell $ternary$/media/karim/ssd_gamed/work/ef/openlane-src/designs/spm/src/spm.v:16$1 ($tribuf)
#     port Y[0] of cell $ternary$/media/karim/ssd_gamed/work/ef/openlane-src/designs/spm/src/spm.v:17$3 ($tribuf)
#     module input y[0]
# Warning: found logic loop in module spm:
#     cell $ternary$/media/karim/ssd_gamed/work/ef/openlane-src/designs/spm/src/spm.v:16$1 ($tribuf)
#     wire \y
# Found and reported 2 problems.

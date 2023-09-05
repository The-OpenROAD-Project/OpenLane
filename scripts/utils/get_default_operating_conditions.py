#!/usr/bin/env python3
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
import sys

import click
from libparse import LibertyParser


@click.command()
@click.argument("liberty", type=click.Path(dir_okay=False, exists=True))
def get_default_operating_conditions(liberty):
    library = LibertyParser(open(liberty))
    ast = library.ast

    default_operating_conditions_id = None
    operating_conditions_raw = {}
    for child in ast.children:
        if child.id == "default_operating_conditions":
            default_operating_conditions_id = child.value
        if child.id == "operating_conditions":
            operating_conditions_raw[child.args[0]] = child

    if default_operating_conditions_id is None:
        if len(operating_conditions_raw) > 1:
            print(
                "No default operating condition defined, and the liberty file has multiple operating conditions.",
                file=sys.stderr,
            )
            exit(-1)
        elif len(operating_conditions_raw) < 1:
            print("Liberty file has no operating conditions.", file=sys.stderr)
            exit(-1)
        default_operating_conditions_id = list(operating_conditions_raw.keys())[0]

    print(f"{ast.args[0]}:{default_operating_conditions_id}", end="")


if __name__ == "__main__":
    get_default_operating_conditions()

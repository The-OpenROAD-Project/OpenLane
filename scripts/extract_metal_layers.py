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

import re
import click
from typing import List


def extract_metal_layers(techlef_str: str) -> List[str]:
    printed = False
    metal_list = []
    current_layer_name = ""

    pattern = re.compile(r"\s*LAYER\s*([\S+]+)\s*")

    for line in techlef_str.split("\n"):
        m = pattern.match(line)
        if m:
            current_layer_name = m.group(1)
            printed = False

        if "ROUTING" in line and not printed:
            metal_list.append(current_layer_name + " ")
            printed = True

    return metal_list


@click.command()
@click.option("--output", "-o", default="/dev/stdout", help="Output file.")
@click.argument("techlef")
def cli(output, techlef):
    techlef_str = open(techlef).read()

    metal_list = extract_metal_layers(techlef_str)

    with open(output, "w") as f:
        f.write(" ".join(metal_list).strip())


if __name__ == "__main__":
    cli()

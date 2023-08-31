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
import re
import click
from enum import Enum


@click.command()
@click.option("-o", "--output", default=None)
@click.argument(
    "file_in",
    type=click.Path(exists=True, file_okay=True, dir_okay=False),
    required=True,
)
def clean_models(output, file_in):
    class State(Enum):
        output = 0
        primitive = 1

    out_file = None
    if output is not None:
        out_file = open(output, "w", encoding="utf8")
    bad_yosys_line = re.compile(r"^\s+\S+\s*\(.*\).*;")
    state = State.output
    for line in open(file_in, "r", encoding="utf8"):
        if state == State.output:
            if line.strip().startswith("primitive"):
                state = State.primitive
            elif bad_yosys_line.search(line) is None:
                print(line.strip("\n"), file=out_file)
        elif state == State.primitive:
            if line.strip().startswith("endprimitive"):
                print("/* removed primitive */", file=out_file)
                state = State.output


if __name__ == "__main__":
    clean_models()

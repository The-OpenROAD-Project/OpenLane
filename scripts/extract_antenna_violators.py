# Copyright 2020 Efabless Corporation
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


@click.command()
@click.option("-o", "--output", required=True, help="Output file to store results.")
@click.argument("report", nargs=1)
def extract_antenna_violators(output, report):
    """
    Usage: extract_antenna_violators.py -o <output text file> <input ARC report>
    Extracts the list of violating nets from an ARC report file"
    """

    pattern = re.compile(r"\s*Net:\s*(\S+)")

    vios_list = []
    current_net = ""
    printed = False

    with open(report, "r") as f:
        for line in f:
            m = pattern.match(line)
            if m is not None:
                current_net = m.group(1)
                printed = False

            if "VIOLATED" in line and not printed:
                print(current_net)
                vios_list.append(current_net + " ")
                printed = True

    with open(output, "w") as f:
        f.write("\n".join(vios_list))


if __name__ == "__main__":
    extract_antenna_violators()

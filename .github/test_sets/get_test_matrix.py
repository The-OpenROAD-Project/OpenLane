#!/usr/bin/env python3
# Copyright 2021 Efabless Corporation
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

import os
import json

import yaml
import click

__dir__ = os.path.dirname(os.path.abspath(__file__))

TEST_SETS_FILE = os.path.join(__dir__, "test_sets.yml")


@click.command()
@click.option(
    "--scl",
    "scls",
    multiple=True,
    default=["sky130A/sky130_fd_sc_hd"],
    help="Specify which PDK/SCL combination to use",
)
@click.option(
    "--json/--plain",
    "use_json",
    default=True,
    help="Print as plain text joined by whitespace instead of a JSON file. Omits PDKs.",
)
@click.argument("test_sets", nargs=-1)
def main(scls, use_json, test_sets):

    data_str = open(TEST_SETS_FILE).read()
    data = yaml.safe_load(data_str)
    test_set_data = filter(lambda e: e["scl"] in scls and e["name"] in test_sets, data)

    designs = list()
    for test_set in list(test_set_data):
        pdk, scl = test_set["scl"].split("/")
        for design in test_set["designs"]:
            designs.append({"name": design, "pdk": pdk, "scl": scl})

    if use_json:
        print(json.dumps({"design": designs}), end="")
    else:
        print(" ".join([design["name"] for design in designs]), end="")


if __name__ == "__main__":
    main()

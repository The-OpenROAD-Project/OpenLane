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
    "--pdk", "pdks", multiple=True, default=["sky130A"], help="Specify which PDK to use"
)
@click.argument("test_sets", nargs=-1)
def main(pdks, test_sets):

    data_str = open(TEST_SETS_FILE).read()
    data = yaml.safe_load(data_str)
    test_set_data = filter(lambda e: e["pdk"] in pdks and e["name"] in test_sets, data)

    designs = list()
    for test_set in list(test_set_data):
        for design in test_set["designs"]:
            designs.append({"name": design, "pdk": test_set["pdk"]})

    print(json.dumps({"design": designs}), end="")


if __name__ == "__main__":
    main()

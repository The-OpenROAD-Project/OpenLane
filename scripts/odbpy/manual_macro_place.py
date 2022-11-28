#!/usr/bin/env python3
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
import click

from reader import click_odb

LEF2OA_MAP = {
    "N": "R0",
    "S": "R180",
    "W": "R90",
    "E": "R270",
    "FN": "MY",
    "FS": "MX",
    "FW": "MXR90",
    "FE": "MYR90",
}


def lef_rot_to_oa_rot(rot):
    if rot in LEF2OA_MAP:
        return LEF2OA_MAP[rot]
    else:
        assert rot in [item[1] for item in LEF2OA_MAP.items()], rot
        return rot


def gridify(n, f):
    """
    e.g., (1.1243, 0.005) -> 1.120
    """
    return round(n / f) * f


@click.command()
@click.option("-c", "--config", required=True, help="Configuration file")
@click.option(
    "-f",
    "--fixed",
    default=False,
    is_flag=True,
    help="A flag to signal whether the placement should be fixed or not",
)
@click_odb
def manual_macro_place(reader, config, fixed):
    """
    Places macros in positions and orientations specified by a config file
    """

    db_units_per_micron = reader.block.getDbUnitsPerMicron()

    # read config
    macros = {}
    with open(config, "r") as config_file:
        for line in config_file:
            # Discard comments and empty lines
            line = line.split("#")[0].strip()
            if not line:
                continue
            line = line.split()
            macros[line[0]] = [
                str(int(float(line[1]) * db_units_per_micron)),
                str(int(float(line[2]) * db_units_per_micron)),
                line[3],
            ]

    print("Placing the following macros:")
    print(macros)

    print("Design name:", reader.name)

    macros_cnt = len(macros)
    for inst in reader.block.getInsts():
        inst_name = inst.getName()
        if inst.isFixed():
            assert inst_name not in macros, inst_name
            continue
        if inst_name in macros:
            print("Placing", inst_name)
            macro_data = macros[inst_name]
            x = gridify(int(macro_data[0]), 5)
            y = gridify(int(macro_data[1]), 5)
            inst.setOrient(lef_rot_to_oa_rot(macro_data[2]))
            inst.setLocation(x, y)
            if fixed:
                inst.setPlacementStatus("FIRM")
            else:
                inst.setPlacementStatus("PLACED")
            del macros[inst_name]

    assert not macros, ("Macros not found:", macros)

    print(f"Successfully placed {macros_cnt} instances.")


if __name__ == "__main__":
    manual_macro_place()

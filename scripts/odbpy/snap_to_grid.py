# Copyright 2022 Efabless Corporation
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
import math
from decimal import Decimal

import click

from reader import OdbReader


def snap_value(value: Decimal, manufacturing_grid: Decimal) -> Decimal:
    adjusted = math.floor(value / manufacturing_grid) * manufacturing_grid
    if adjusted == Decimal(0):
        adjusted = math.ceil(value / manufacturing_grid) * manufacturing_grid
    return adjusted


@click.command()
@click.option(
    "-o",
    "--output",
    required=True,
    help="A text file to which final values are output.",
)
@click.option(
    "-l",
    "--input-lef",
    required=True,
    help="Input LEF file (for the manufacturing grid)",
)
@click.argument("input_values", type=Decimal, nargs=-1)
def cli(output, input_lef, input_values):
    reader = OdbReader(input_lef, None)
    manufacturing_grid = Decimal(reader.db.getTech().getManufacturingGrid()) / Decimal(
        reader.db.getTech().getDbUnitsPerMicron()
    )
    with open(output, "w") as f:
        print(
            " ".join(
                [str(snap_value(value, manufacturing_grid)) for value in input_values]
            ),
            end="",
            file=f,
        )


if __name__ == "__main__":
    cli()

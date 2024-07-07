# Copyright ©2022 Efabless Corporation
#
# This file is part of the DFFRAM Memory Compiler.
# See https://github.com/Cloud-V/DFFRAM for further info.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import os
import click
from decimal import Decimal

from reader import click_odb, OdbReader


def to_si(microns: Decimal) -> str:
    units = ["μm", "mm", "m"]
    unit = 0
    value = microns
    while value >= 1000 and unit < len(units):
        value /= 1000
        unit += 1
    return f"{value}{units[unit]}"


@click.command()
@click.option(
    "-h",
    "--human-readable",
    default=False,
    is_flag=True,
    help="Print with SI units instead of database units.",
)
@click.option(
    "-t",
    "--threshold",
    default=Decimal("Infinity"),
    type=Decimal,
    help="Threshold above which to print the wire (Default: ∞)",
)
@click.option(
    "-F",
    "--fail",
    default=False,
    is_flag=True,
    help="Exit with a non-zero code if any wire surpasses the threshold.",
)
@click.option(
    "-R",
    "--report-out",
    default=None,
    help="Output to print CSV file to. (Default: input + .wire_lengths.csv)",
)
@click_odb
def main(report_out, threshold, fail, human_readable, input_db, reader: OdbReader):
    db = reader.db
    if report_out is None:
        report_out = f"{input_db}.wire_length.csv"

    block = db.getChip().getBlock()
    dbunits = block.getDefUnits()
    nets = list(filter(lambda net: net.getWire() is not None, block.getNets()))
    nets.sort(key=lambda net: net.getWire().getLength(), reverse=True)

    above_threshold = []
    with open(report_out, "w") as f:
        print("net,length_um", file=f)
        for net in nets:
            length = net.getWire().getLength()
            length_microns = Decimal(length) / Decimal(dbunits)
            if length_microns >= threshold:
                above_threshold.append((net, length_microns))
            length_printable: str = str(length_microns)
            if human_readable:
                length_printable = str(to_si(length_microns))
            print(f"{net.getName()},{length_printable}", file=f)

    for net, length_microns in above_threshold:
        print(
            f"Net {net.getName()} is above the length threshold ({length_microns}/{threshold} μm)."
        )

    if len(above_threshold) == 0:
        print(f"No wire length surpasses the threshold ({threshold} μm).")
    elif fail:
        exit(os.EX_DATAERR)


if __name__ == "__main__":
    main()

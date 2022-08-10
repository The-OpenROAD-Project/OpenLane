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


import os
import sys
import click


@click.command()
@click.option(
    "--from-pdk",
    "-P",
    default=None,
    help="The name of the PDK to copy the configuration from. If either this option or --from-scl are not given an argument, an empty configuration file will be created.",
)
@click.option(
    "--from-scl",
    "-S",
    default=None,
    help="The name of the standard cell library to copy the configuration from. If either this option or --from-pdk are not given an argument, an empty configuration file will be created.",
)
@click.option(
    "--to-pdk",
    "-p",
    required=True,
    help="The name of the PDK to copy/create the configuration for.",
)
@click.option(
    "--to-scl",
    "-s",
    required=True,
    help="The name of the standard cell library to copy/create the configuration for.",
)
@click.argument("designs", nargs=-1)
def replicate(from_pdk, from_scl, to_pdk, to_scl, designs):
    """
    Create new PDK+SCL-specific configurations for one or more designs either
    by copying from a given PDK-SCL pair to another, or, if unspecified or
    nonexistent, by creating a new empty configuration file.

    If no designs are given, all designs in the OpenLane designs folder will
    be selected.
    """

    designs = list(designs)

    OPENLANE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    DESIGN_DIR = os.path.join(OPENLANE_DIR, "designs")

    if len(designs) == 0:
        designs = [
            os.path.join(DESIGN_DIR, design) for design in os.listdir(DESIGN_DIR)
        ]

    for i in range(0, len(designs)):
        if not os.path.isdir(designs[i]):
            # Check if design exists in OpenLane designs folder
            ol_design = os.path.join(DESIGN_DIR, designs[i])
            if os.path.isdir(ol_design):
                designs[i] = ol_design
            else:
                print(
                    f"Design {designs[i]} not found either relative to the current working directory or the OpenLane design order.",
                    file=sys.stderr,
                )
                exit(-1)

    for design in designs:
        design_name = os.path.basename(design)
        print(f"Replicating config for {design_name} ({design})...")

        target = os.path.join(design, f"{to_pdk}_{to_scl}_config.tcl")
        source = (
            os.path.join(design, f"{from_pdk}_{from_scl}_config.tcl")
            if from_pdk is not None and from_scl is not None
            else None
        )

        data = f"# {design_name}: configuration for {to_pdk}/{to_scl}"

        if source is not None and os.path.exists(source):
            data = open(source).read()

        with open(target, "w") as f:
            print(data, file=f)

    print("Done.")


if __name__ == "__main__":
    replicate()

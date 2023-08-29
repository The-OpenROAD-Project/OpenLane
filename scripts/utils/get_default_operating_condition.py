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
from liberty.parser import parse_liberty


def print_error(message):
    print(f"[ERROR]: {message}")


@click.command()
@click.argument("liberty", type=click.Path(dir_okay=False, exists=True))
def get_default_operating_condition(liberty):
    library = parse_liberty(open(liberty).read())
    default_operating_conditions = library.get_attributes(
        "default_operating_conditions"
    )
    if len(default_operating_conditions) > 1:
        print_error(
            f"Liberty {library.args[0]} has more than one default_operating_conditions"
        )
        sys.exit(1)
    if len(default_operating_conditions) < 1:
        operating_conditions = library.get_groups("operating_conditions")
        if len(operating_conditions) > 1:
            print_error(f"Liberty {library.args[0]} has more than one operating_conditions. User has to explicitly set the default")
            sys.exit(1)
        if len(operating_conditions) == 0:
            print_error(f"Liberty {library.args[0]} has no operating_conditions.")
            sys.exit(1)

        print((operating_conditions[0].args[0]))

    if len(default_operating_conditions) == 1:
        print(default_operating_conditions[0].value)


if __name__ == '__main__':
    get_default_operating_condition()

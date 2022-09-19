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
import defutil

from reader import click_odb


@click.command()
@click.option("-t", "--def-template", required=True, help="Template DEF")
@click_odb
def cli(reader, input_lef, def_template):
    defutil.relocate_pins(
        reader.db,
        input_lef,
        def_template,
    )

    defutil.move_diearea(
        reader.db,
        input_lef,
        def_template,
    )


if __name__ == "__main__":
    cli()

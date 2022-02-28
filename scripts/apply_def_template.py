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
import shutil
import defutil


@click.command()
@click.option("-t", "--def-template", "templatedef", required=True, help="Template DEF")
@click.option("-l", "--lef", "lef", required=True, help="LEF file")
@click.option("-lg", "--log", "logfile", required=True, help="Log output file")
@click.argument("userdef")
def cli(templatedef, userdef, lef, logfile):
    userDEF = userdef
    templateDEF = templatedef

    # Removed section to remove the power/ground pins as defutil:replace_pins implements this

    defutil.replace_pins(
        input_lef=lef,
        logpath=logfile,
        template_def=templateDEF,
        source_def=userDEF,
        output_def=f"{userDEF}.replace_pins.tmp",
    )

    # Call defutil to move die area
    defutil.move_diearea(
        template_def=templateDEF,
        output_def=f"{userDEF}.replace_pins.tmp",
        input_lef=lef,
    )
    shutil.copy(f"{userDEF}.replace_pins.tmp", userDEF)


if __name__ == "__main__":
    cli()

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

import click

import os
import subprocess
import glob

from scripts.config.tcl import read_tcl_env


def err(msg):
    print(f"Error: {msg}")
    exit(1)


@click.command()
@click.option(
    "--viewer",
    default="openroad",
    show_default=True,
    help="Viewer option",
    type=click.Choice(["klayout", "openroad"]),
)
@click.option(
    "-f",
    "--format",
    default=None,
    help="Layout format to view [default: per-tool]",
    type=click.Choice(["def", "odb", "gds"]),
)
@click.option(
    "-s",
    "--stage",
    help="Optionally specify which stage to view",
    type=click.Choice(["cts", "floorplan", "placement", "routing", "signoff"]),
)
@click.argument("run_dir")
def gui(viewer, format, run_dir, stage):
    """View specified layout from run_dir using supported viewers"""

    run_config_file = os.path.join(run_dir, "config.tcl")
    if not os.path.exists(run_config_file):
        err("Run config file does not exist.")

    run_config = read_tcl_env(run_config_file)

    if viewer == "openroad":
        format = format or "odb"
        if format in ["gds"]:
            err(f"OpenROAD does not support {format}.")
        extra_config = {}
        if stage is not None:
            matches = glob.glob(os.path.join(run_dir, "results", stage, f"*.{format}"))
            if matches == []:
                err(f"No {format} found for stage {stage}")
            else:
                extra_config[f"CURRENT_{format.upper()}"] = matches[0]

        if format == "def":
            extra_config["IO_READ_DEF"] = "1"

        extra_config["GUI_PARASITICS"] = "1"
        print(f"Using {run_config_file}")
        run_env = os.environ.copy()
        subprocess.check_call(
            ["openroad", "-gui", "./scripts/openroad/gui.tcl"],
            env={**run_env, **run_config, **extra_config},
        )

    elif viewer == "klayout":
        format = format or "gds"
        if format in ["odb"]:
            err(f"KLayout does not support {format}.")

        layout = run_config[f"CURRENT_{format.upper()}"]
        if stage is not None:
            matches = glob.glob(os.path.join(run_dir, "results", stage, f"*.{format}"))
            if len(matches) == 0:
                err(f"No {format} found for stage {stage}: see --help for more formats")
            else:
                layout = matches[0]

        subprocess.check_call(
            [
                "python3",
                "./scripts/klayout/open_design.py",
                "--input-lef",
                run_config["MERGED_LEF"],
                "--lyt",
                run_config["KLAYOUT_TECH"],
                "--lyp",
                run_config["KLAYOUT_PROPERTIES"],
                "--lym",
                run_config["KLAYOUT_DEF_LAYER_MAP"],
                layout,
            ]
        )


if __name__ == "__main__":
    gui()

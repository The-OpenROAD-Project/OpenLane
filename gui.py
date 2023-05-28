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
    default="odb",
    help="Layout format to view",
    show_default=True,
    type=click.Choice(["def", "odb"]),
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
        err(f"Run config file does not exist.")

    run_config = read_tcl_env(run_config_file)

    if viewer == "openroad":
        extra_config = {}
        if stage is not None:
            matches = glob.glob(os.path.join(run_dir, "results", stage, f"*.{format}"))
            if matches is []:
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
        if format == "odb":
            err("Klayout does not support odb. Please use --format def instead.")

        def_file = run_config["CURRENT_DEF"]
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
                def_file,
            ]
        )


gui()

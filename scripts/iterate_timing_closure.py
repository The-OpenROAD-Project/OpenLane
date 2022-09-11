#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Adapted from Pathfinder
# Copyright 2021 The American University in Cairo
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
import re
import os
import csv
import glob
import click
import shutil
import pathlib
import datetime
import subprocess
from typing import Dict, Tuple

openlane_dir = os.path.dirname(os.path.dirname(__file__))

log_dir = os.path.join(openlane_dir, "_build", "it_tc_logs")

pathlib.Path(log_dir).mkdir(parents=True, exist_ok=True)


def rp(path):
    return os.path.realpath(path)


def openlane(*args_tuple, tag="ol_run"):
    args = list(args_tuple)

    stdout_f = open(os.path.join(log_dir, f"{tag}.stdout"), "w")
    stderr_f = open(os.path.join(log_dir, f"{tag}.stderr"), "w")

    cmd = [f"{openlane_dir}/flow.tcl"] + args
    status = subprocess.run(cmd, stdout=stdout_f, stderr=stderr_f)

    stdout_f.close()
    stderr_f.close()

    if status.returncode != 0:
        raise Exception(f"{args} failed with exit code {status.returncode}")


def get_run_dir(design: str, run_tag: str) -> str:
    return os.path.join(design, "runs", run_tag)


def override_env_str(override_env: dict) -> str:
    return ",".join([f"{k}={v}" for k, v in override_env.items()])


def process_report_csv(csv_in: str) -> Dict[str, str]:
    metric_dict = {}
    with open(csv_in) as f:
        csv_data = list(csv.reader(f, delimiter=",", quotechar="'"))
        column_count = len(csv_data[0])
        for column in range(0, column_count):
            key = csv_data[0][column]
            value = csv_data[1][column]
            metric_dict[key] = value
    return metric_dict


presynth_end_step = "placement"
iteration_start_step = "routing"


def presynthesize(design: str) -> Tuple[str, Dict[str, float]]:
    run_tag = f"{datetime.datetime.now().isoformat()}"

    override_env = {"QUIT_ON_TIMING_VIOLATIONS": 0}

    design_name = os.path.basename(design)

    openlane(
        "-tag",
        run_tag,
        "-design",
        design,
        "-to",
        presynth_end_step,
        "-override_env",
        override_env_str(override_env),
        tag=f"{design_name}_presynth",
    )

    return run_tag


def run_and_quantify_closure(
    design: str, run_tag: str, inputs: dict, tag: str = "0"
) -> float:
    override_env = {"QUIT_ON_TIMING_VIOLATIONS": 0, **inputs}

    shutil.copytree(get_run_dir(design, run_tag), get_run_dir(design, f"{run_tag}.bk"))

    exception: Exception = None

    try:
        openlane(
            "-tag",
            run_tag,
            "-design",
            design,
            "-from",
            "routing",
            "-to",
            "routing",
            "-override_env",
            override_env_str(override_env),
            tag=tag,
        )

        metric_glob = glob.glob(
            f"{get_run_dir(design, run_tag)}/reports/routing/*-parasitics_sta.worst_slack.rpt"
        )
        metric_file = list(
            filter(lambda x: not os.path.basename(x).startswith("-"), metric_glob)
        )[0]
        metric_file_str = open(metric_file).read()
        metric_rx = re.compile(r"worst\s+slack\s+(-?[\d.]+)")
        metric_match = metric_rx.search(metric_file_str)
        worst_slack = float(metric_match[1])
    except Exception as e:
        exception = e
    finally:
        final_dir = get_run_dir(design, f"{run_tag}.exploration_{tag}")
        shutil.rmtree(final_dir, ignore_errors=True)
        shutil.move(get_run_dir(design, run_tag), final_dir)

        shutil.move(get_run_dir(design, f"{run_tag}.bk"), get_run_dir(design, run_tag))

    if exception is not None:
        raise exception

    return worst_slack


@click.command()
@click.option("--inputs", default="", help="Comma,delimited,KEY=VALUE,pairs")
@click.option(
    "--iterate-routing/--iterate-pnr",
    "iterate_routing_only",
    default=True,
    help="Pick whether to iterate on only routing or both placement and routing (latter takes a bit longer)",
)
@click.option("--run-tag", required=None, help="Run tag from a previous run")
@click.argument("design")
def cli(inputs, iterate_routing_only, run_tag, design):
    global presynth_end_step, iteration_start_step

    if not iterate_routing_only:
        presynth_end_step = "floorplan"
        iteration_start_step = "placement"

    if design.endswith("/"):
        design = design[:-1]

    if run_tag is None:
        print("Presynthesizing...")
        run_tag = presynthesize(design)
        print(f"Done, presynthesized to {run_tag}")

    input_dict = {}
    for kvp in inputs.split(","):
        if not kvp:
            continue
        key, value = kvp.split("=")
        input_dict[key] = value

    count = len(glob.glob(get_run_dir(design, run_tag) + "*"))

    print(f"Running exploration {count} with inputs {input_dict}...")

    design_basename = os.path.basename(design)

    worst_slack = run_and_quantify_closure(
        design, run_tag, input_dict, f"{design_basename}_{count}"
    )
    achieved = worst_slack >= 0
    if achieved:
        print("Timing closure achieved.")
    else:
        print(f"Timing closure failed: worst slack {worst_slack}.")
        exit(os.EX_DATAERR)


if __name__ == "__main__":
    cli()

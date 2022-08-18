#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright 2020-2021 Efabless Corporation
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
import yaml
import glob
import shlex
import getpass
import subprocess
from gh import gh

threads_used = os.cpu_count() - 1
test_name = "ci_test"
design = sys.argv[1]
print(f"Running on designs {test_name} using {threads_used} threads…")

username = getpass.getuser()
user = subprocess.check_output(["id", "-u", username]).decode("utf8")[:-1]
group = subprocess.check_output(["id", "-g", username]).decode("utf8")[:-1]

docker_command = [
    "docker",
    "run",
    "-v",
    f"{os.path.realpath(gh.root)}:/openlane",
    "-v",
    f"{os.path.realpath(gh.root)}/designs:/openlane/install",
    "-v",
    f"{gh.pdk_root}:{gh.pdk_root}",
    "-u",
    f"{user}:{group}",
    "-e",
    f"PDK_ROOT={gh.pdk_root}",
    "-e",
    f"PDK={gh.pdk}",
    gh.image,
    "bash",
    "-c",
    shlex.join(
        [
            "python3",
            "run_designs.py",
            "--disable_timestamp",
            "--tag",
            test_name,
            "--threads",
            str(threads_used),
            "--benchmark",
            os.path.join("regression_results", "benchmark_results", "SW_HD.csv"),
            "--show_output",
            design,
        ]
    ),
]

print(f"Running {shlex.join(docker_command)} in {os.getenv('PWD')}…")

try:
    subprocess.run(docker_command, check=True)
except subprocess.CalledProcessError as e:
    if e.returncode != 2:
        raise e


def cat(x):
    print(open(x).read())


results_folder = os.path.join(gh.root, "regression_results", test_name)

print("Verbose differences within the benchmark:")
for report in glob.glob(os.path.join(results_folder, f"{test_name}*.rpt")):
    cat(report)

design_test_report = os.path.join(results_folder, f"{test_name}.rpt.yml")
if not os.path.exists(design_test_report):
    print(f"Couldn't find final design test report at {design_test_report}.")
    exit(-1)

cat(design_test_report)

dtr_str = open(design_test_report).read()
dtr = yaml.safe_load(dtr_str)

print("Tarballing run...")
subprocess.check_call(
    ["tar", "-czf", "./reproducible.tar.gz", os.path.join("designs", design, "runs")]
)
print("Created ./reproducible.tar.gz.")

if not dtr[design]["pass"]:
    print("Testing the design has failed.")
    exit(-1)

print("Done.")

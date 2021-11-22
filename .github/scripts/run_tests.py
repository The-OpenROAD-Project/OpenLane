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
import re
import os
import sys
import glob
import shlex
import getpass
import subprocess
from gh import gh

threads_used = int(subprocess.check_output(["nproc"]).decode("utf-8")) - 1
test_name = "TEST"
design_list = sys.argv[1:]
test_set = os.getenv("TEST_SET")
if test_set is not None:
    test_name = f"TEST_{test_set}"
    test_set_file = os.path.join(gh.root, ".github", "test_sets", test_set)
    if os.path.exists(test_set_file):
        design_list = open(test_set_file).read().split()
    else:
        raise Exception(f"Test set {test_set} not found.")

    print(f"Running test set {test_set} using {threads_used} threads…")
else:
    print(f"Running on designs {design_list} using {threads_used} threads…")

username = getpass.getuser()
user = subprocess.check_output(["id", "-u", username]).decode("utf8")[:-1]
group = subprocess.check_output(["id", "-g", username]).decode("utf8")[:-1]

docker_command = [
    "docker", "run",
    "-v", f"{os.path.realpath(gh.root)}:/openlane",
    "-v", f"{gh.pdk}:{gh.pdk}",
    # "-u", f"{user}:{group}",
    "-e", f"PDK_ROOT={gh.pdk}",
    gh.image,
    "bash", "-c",
    shlex.join([
        "python3",
        "run_designs.py",
        "--tarList", "all",
        "--disable_timestamp",
        "--designs",
    ] + design_list + [
        "--tag", test_name,
        "--threads", str(threads_used),
        "--print_rem", "30",
        "--benchmark", os.path.join("regression_results", "benchmark_results", "SW_HD.csv")
    ])
]
print(os.getenv("PWD"))
print("Running %s…" % shlex.join(docker_command))
subprocess.run(docker_command, check=True)


cat = lambda x: print(open(x).read())

results_folder = os.path.join(gh.root, "regression_results", test_name)

print("Verbose differences within the benchmark:")
for report in glob.glob(os.path.join(results_folder, f"{test_name}*.rpt")):
    cat(report)
print("Full report:")
cat(os.path.join(results_folder, f"{test_name}.csv"))

design_test_report = os.path.join(results_folder, f"{test_name}.csv")
if not os.path.exists(design_test_report):
    print(f"Couldn't find final design test report at {design_test_report}.")
    exit(-1)

cat(design_test_report)

if "FAILED" in open(design_test_report).read():
    print("At least one test has failed.")
    exit(-1)

print("Done.")
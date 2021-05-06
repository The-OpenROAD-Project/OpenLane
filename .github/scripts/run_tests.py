#!/usr/bin/env python3
# -*- coding: utf-8 -*-
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
import re
import os
import glob
import shlex
import getpass
import subprocess
from gh import gh

extra_flags = (os.getenv("EXTRA_FLAGS") or "").split()

test_set = os.getenv("TEST_SET")
if test_set is None:
    raise Exception("Environment variable TEST_SET must be set.")

test_name = "TEST_%s" % test_set

test_set_file = os.path.join(gh.root, ".github", "test_sets", test_set)
design_list = [test_set]
if os.path.exists(test_set_file):
    design_list = open(test_set_file).read().split()

threads_used = int(subprocess.check_output(["nproc"]).decode("utf-8")) - 1

print("Running test set %s using %i threads…" % (test_set, threads_used))

username = getpass.getuser()
user = subprocess.check_output(["id", "-u", username]).decode("utf8")[:-1]
group = subprocess.check_output(["id", "-g", username]).decode("utf8")[:-1]

docker_command = [
    "docker", "run",
    "-v", "%s:/openLANE_flow" % os.path.realpath(gh.root),
    "-v", "{p}:{p}".format(p=gh.pdk),
    "-u", "%s:%s" % (user, group),
    "-e", "PDK_ROOT=%s" % gh.pdk,
    gh.image,
    "bash", "-c",
    shlex.join([
        "python3", "run_designs.py",
        "-d"] + design_list + [
        "-t", test_name,
        "-dl", "-dt", "-th", str(threads_used),
        "-p", "30",
        "-b", os.path.join("regression_results", "benchmark_results", "SW_HD.csv")
    ] + extra_flags)
]
print(os.getenv("PWD"))
print("Running %s…" % shlex.join(docker_command))
subprocess.run(docker_command, check=True)


df = lambda x: print(open(x).read())

results_folder = os.path.join(gh.root, "regression_results", test_name)

print("Verbose differences within the benchmark:")
for report in glob.glob(os.path.join(results_folder, "%s*.rpt" % test_name)):
    df(report)
print("Full report:")
df(os.path.join(results_folder, "%s.csv" % test_name))

design_test_report = os.path.join(results_folder, "%s_design_test_report.csv" % test_name)
if not os.path.exists(design_test_report):
    print("Couldn't find final design test report at %s." % design_test_report)
    exit(-1)

df(design_test_report)

if "FAILED" in open(design_test_report).read():
    print("At least one test has failed.")
    exit(-1)

print("Done.")
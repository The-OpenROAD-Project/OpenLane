#!/usr/bin/env python3
#
# Copyright 2022 Arman Avetisyan
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

import os  # For checking if file exists
import json  # To serialize the matrix for the CI
import click  # For command line parsing
import subprocess  # For running the flow

# TODO: If command is get designs
# print(json.dumps({"design": designs}))
# else if design specified
#


def get_test_cases():
    openlane_dir_relative = os.path.dirname(os.path.relpath(__file__))
    test_dir_relative = os.path.join(openlane_dir_relative, "tests")
    retval = []
    for file in os.listdir(test_dir_relative):
        test_path = os.path.join(test_dir_relative, file)
        if os.path.isdir(test_path):
            retval.append(test_path)
    return retval


@click.group()
def cli():
    pass


# Note: Following command is executed outside of OpenRoad, so you can't run the ./flow.tcl
@click.command("get_matrix")
def get_matrix():
    print(json.dumps({"design": get_test_cases()}))


cli.add_command(get_matrix)


@click.command("run")
@click.argument("test_case")
def run_test_case_cmd(test_case):
    run_test_case(test_case)


cli.add_command(run_test_case_cmd)


@click.command("run_all")
def run_all():
    for test_case in get_test_cases():
        run_test_case(test_case)
    print("Done.")


cli.add_command(run_all)


def run_test_case(test_case):
    # test_case is the path to design
    # test_case_name is name of design to test
    # It is assumed that every test case is inside designs path

    # -------------------------------
    # 0. Calculate names
    # -------------------------------
    result = ""
    test_case_issue_regression_script = test_case + "/issue_regression.py"
    script_exists = os.path.isfile(test_case_issue_regression_script)
    (_, test_case_name) = os.path.split(test_case)
    # print("test_case_name", test_case_name)
    logpath = "./regression_results/issue_regression_" + test_case_name + ".log"
    logpath_check = (
        "./regression_results/issue_regression_" + test_case_name + "_check.log"
    )
    # -------------------------------
    # 1. Run the flow
    # -------------------------------
    try:
        logfile = open(logpath, "w")
        print(f"Running test case: {test_case_name} (logging to {logpath})")
        interactive = []
        interactive_file = os.path.join(test_case, "interactive.tcl")
        if os.path.exists(interactive_file):
            interactive = ["-it", "-file", interactive_file]
        result = subprocess.run(
            [
                "./flow.tcl",
                "-design",
                test_case,
                "-tag",
                "issue_regression_run",
                "-run_hooks",
                "-overwrite",
            ]
            + interactive,
            stdout=logfile,
            stderr=subprocess.STDOUT,
            check=True,
        )
    except subprocess.CalledProcessError as err:
        # -------------------------------
        # 2.1 If run was not successful, then run the issue_regression.py which
        #       will check if the fail was expected or not and it will also check the logs
        #       for errors to match
        # 2.2 If issue_regression.py does not exist then it's enough for this design to pass LVS
        # -------------------------------
        if script_exists:
            result = err
        else:
            print(
                f"./flow.tcl failed and issue_regression.py does not exist, therefore test case {test_case} failed."
            )
            raise err
    # -------------------------------
    # 3. Run the issue_regression.py.
    # -------------------------------
    if script_exists:
        print("Running post-run hook...")
        logfile_check = open(logpath_check, "w")
        try:
            subprocess.run(
                [
                    "openroad",
                    "-python",
                    test_case_issue_regression_script,
                    test_case + "/runs/issue_regression_run",
                    str(result.returncode),
                ],
                check=True,
                stdout=logfile_check,
                stderr=subprocess.STDOUT,
            )
        except subprocess.CalledProcessError as err:
            # -------------------------------
            # 4. Run the issue_regression.py. If it errors out, log it and then raise an error
            # -------------------------------
            print(f"{test_case_name} failed: see '{logpath_check}'.")
            raise err
    print(f"{test_case_name} completed successfully.")


if __name__ == "__main__":
    cli()

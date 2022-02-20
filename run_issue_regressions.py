# Copyright 2022 Arman Avetisyan
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

import glob  # For finding all issue_regression designs
import subprocess  # For running the flow
import os  # For checking if file exists
import click  # For command line parsing
import json


test_cases = glob.glob("./designs/issue_*")

# TODO: If command is get designs
# print(json.dumps({"design": designs}))
# else if design specified
#


@click.group()
def cli():
    pass


# Note: Following command is executed outside of OpenRoad, so you can't run the ./flow.tcl
@click.command("get_matrix")
def get_matrix():
    print(json.dumps({"design": test_cases}))


cli.add_command(get_matrix)


@click.command("run")
@click.argument("test_case")
def run_test_case_cmd(test_case):
    run_test_case(test_case)


cli.add_command(run_test_case_cmd)


@click.command("run_all")
def run_all():
    for test_case in test_cases:
        run_test_case(test_case)
    print("Issue regression flow completed without errors")


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
        print("Running test case:", test_case_name, "Logfile:", logpath)
        result = subprocess.run(
            [
                "./flow.tcl",
                "-design",
                test_case,
                "-tag",
                "issue_regression_run",
                "-run_hooks",
                "-overwrite",
            ],
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
            print(
                "./flow.tcl failed. This might be expected, as issue_regression.py may expect this"
            )
        else:
            print(
                "./flow.tcl failed and issue_regression.py does not exist, therefore test case",
                test_case,
                "failed. Logfile:",
                logpath,
            )
            raise err
    # -------------------------------
    # 3. Run the issue_regression.py.
    # -------------------------------
    if script_exists:
        print("Running", test_case_issue_regression_script, "Logfile:", logpath_check)
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
            print("Issue regression check failed, check log:", logpath_check)
            raise err
        print("Completed run successfully:", test_case)
    else:
        print(
            "For design",
            test_case,
            "no regression script",
            test_case_issue_regression_script,
            "has been found",
        )


if __name__ == "__main__":
    cli()

#!/usr/bin/env python3
#
# Copyright 2022 Efabless Corporation
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
import os
import json
import click
import pathlib
import subprocess

# TODO: If command is get designs
# print(json.dumps({"design": designs}))
# else if design specified
#

openlane_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def mkdirp(path):
    return pathlib.Path(path).mkdir(parents=True, exist_ok=True)


def get_test_cases():
    test_dir = os.path.join(openlane_root, "tests")
    retval = []
    for file in os.listdir(test_dir):
        if file == "__pycache__":
            continue
        test_path = os.path.join(test_dir, file)
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
    # if the path does not exist, openlane_root/tests/<test_case> will also be checked

    # -------------------------------
    # 0. Extract names and paths
    # -------------------------------
    result = ""
    if not os.path.isdir(test_case):
        original_test_case = test_case
        test_case = os.path.join(openlane_root, "tests", test_case)
        if not os.path.isdir(test_case):
            print(f"Test case {original_test_case} not found.")

    test_case = os.path.abspath(test_case)

    test_case_issue_regression_script = os.path.join(test_case, "issue_regression.py")
    script_exists = os.path.isfile(test_case_issue_regression_script)
    (_, test_case_name) = os.path.split(test_case)

    log_dir = os.path.join(openlane_root, "test_logs")
    mkdirp(log_dir)
    run_log_path = os.path.join(log_dir, f"{test_case_name}.log")
    check_log_path = os.path.join(log_dir, f"{test_case_name}.check.log")

    # -------------------------------
    # 1. Run the flow
    # -------------------------------
    try:
        logfile = open(run_log_path, "w")
        print(
            f"Running test case: {test_case_name}... (log: {os.path.relpath(run_log_path, '.')})"
        )
        interactive = []
        interactive_file = os.path.join(test_case, "interactive.tcl")
        if os.path.exists(interactive_file):
            interactive = ["-it", "-file", interactive_file]
        env = os.environ.copy()
        env["TEST_DIR"] = test_case
        result = subprocess.run(
            [
                "flow.tcl",
                "-design",
                test_case,
                "-tag",
                "issue_regression_run",
                "-run_hooks",
                "-overwrite",
                "-verbose",
                "99",
            ]
            + interactive,
            stdout=logfile,
            stderr=subprocess.STDOUT,
            check=True,
            env=env,
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
                f"flow.tcl failed and issue_regression.py does not exist, therefore test case {test_case} failed."
            )
            raise err
    # -------------------------------
    # 3. Run the issue_regression.py.
    # -------------------------------
    if script_exists:
        print(
            f"Running post-run check... (log: '{os.path.relpath(check_log_path, '.')}')"
        )
        logfile_check = open(check_log_path, "w")
        try:
            subprocess.run(
                [
                    "openroad",
                    "-python",
                    test_case_issue_regression_script,
                    os.path.join(test_case, "runs", "issue_regression_run"),
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
            print("Failed.")
            raise err
    print(f"{test_case_name} completed successfully.")


if __name__ == "__main__":
    cli()

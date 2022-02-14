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

test_cases = glob.glob("./designs/issue_*")

for test_case in test_cases:
    result = ""
    test_case_issue_regression_script = test_case + "/issue_regression.py"
    script_exists = os.path.isfile(test_case_issue_regression_script)
    try:
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
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except subprocess.CalledProcessError as err:
        if script_exists:
            result = err
            print(
                "Flow failed. This might be expected, as issue_regression.py may expect this"
            )
        else:
            print(
                "Flow failed and issue_regression.py does not exist, therefore test case",
                test_case,
                "failed",
            )
            raise err

    if script_exists:
        print("Running", test_case_issue_regression_script)
        subprocess.run(
            [
                "openroad",
                "-python",
                test_case_issue_regression_script,
                test_case + "/runs/issue_regression_run",
                str(result.returncode),
            ]
        )
    else:
        print(
            "For design",
            test_case,
            "no regression script",
            test_case_issue_regression_script,
            "has been found",
        )

print("issuuer regression flow completed without errors")

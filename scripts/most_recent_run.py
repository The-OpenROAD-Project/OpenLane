#!/usr/bin/env python3
# Copyright 2022 Efabless Corporation

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
import click


@click.command("most_recent_run")
@click.argument("runs_directory")
def main(runs_directory):
    max_time = 0
    latest_run_name = None
    if not os.path.isdir(runs_directory):
        print(f"No runs found at '{runs_directory}'.", file=sys.stderr)
        exit(os.EX_NOINPUT)
    for run in os.listdir(runs_directory):
        run_folder_path = os.path.join(runs_directory, run)
        if not os.path.isdir(run_folder_path):
            continue
        time = os.stat(run_folder_path).st_mtime
        if time > max_time:
            max_time = time
            latest_run_name = run

    if latest_run_name is not None:
        print(latest_run_name, end="")
    else:
        print(f"No runs found at '{runs_directory}'.", file=sys.stderr)
        exit(os.EX_NOINPUT)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
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

import os
import sys
import subprocess


class NoGitException(Exception):
    pass


# Slashes are not allowed in the container tag
def canon(ref: str) -> str:
    return ref.replace("/", "-")


def get_tag() -> str:
    try:
        if os.path.exists("/git_version"):
            return open("/git_version").read().strip()

        try:
            subprocess.run(
                ["git", "status"], stdout=subprocess.PIPE, stderr=subprocess.PIPE
            )
        except FileNotFoundError:
            raise NoGitException(
                "Cannot find the git binary. Please specify OPENLANE_IMAGE_NAME manually."
            )

        branch_name_data: subprocess.CompletedProcess = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

        if branch_name_data.returncode != 0:
            raise NoGitException(
                f"Cannot determine git branch. Please specify OPENLANE_IMAGE_NAME manually.\nFull output: {branch_name_data.stderr.decode('utf8').strip()}"
            )

        branch_name = branch_name_data.stdout.decode("utf8").strip()
        if branch_name not in ["", "HEAD"]:
            if branch_name not in ["main", "master", "superstable"]:
                return canon(f"{branch_name}-dev")

        process_data: subprocess.CompletedProcess = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        if process_data.returncode != 0:
            raise NoGitException(
                f"Failed to get commit.  Please specify OPENLANE_IMAGE_NAME manually.\nFull output: {process_data.stderr.decode('utf8').strip()}"
            )
        return canon(process_data.stdout.decode("utf8").strip())
    except NoGitException as e:
        raise e
    except Exception as e:
        raise Exception(
            f"An unexpected error has occurred when trying to find the OpenLane version: {e}."
        )


if __name__ == "__main__":
    try:
        print(get_tag(), end="")
    except Exception as e:
        print(e, file=sys.stderr)
        sys.exit(os.EX_UNAVAILABLE)

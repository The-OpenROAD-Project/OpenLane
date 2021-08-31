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

import sys
import subprocess

def get_tag():
    tag = None

    try:
        tag = subprocess.check_output(["git", "describe", "--tags", "--abbrev=0"]).decode("utf8").strip()
    except Exception as e:
        pass

    if tag is None:
        try:
            tag = open("./resolved_version").read()
        except:
            print("Please input the version of OpenLane you'd like to pull: ", file=sys.stderr)
            try:
                tag = input()
                with open("./resolved_version", "w") as f:
                    f.write(tag)
            except EOFError:
                print("Could not resolve the version of OpenLane being used. This is a critical error.", file=sys.stderr)
                exit(-1)

    return tag

if __name__ == "__main__":
    print(get_tag(), end="")
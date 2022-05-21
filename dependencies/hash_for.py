#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright 2022 Efabless Corporation
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
"""
Gets a hash of the current dependency set of a certain operating system.
"""

import os
import sys
import glob
import hashlib

__dir__ = os.path.dirname(os.path.abspath(__file__))


def main(argv):
    if len(argv) != 2:
        print(f"Usage: {argv[0]} <operating system>", file=sys.stderr)
        exit(64)

    os = argv[1]
    if os not in ["macos", "centos-7", "ubuntu-20.04", "arch"]:
        print(f"Unknown operating system pick '{os}'.")
        exit(64)

    files = glob.glob(f"{__dir__}/python/*")
    files += glob.glob(f"{__dir__}/{os}/*")

    files.sort()

    content = ""
    for file in files:
        content += open(file).read()

    hash = hashlib.sha256(content.encode("utf-8")).hexdigest()

    print(hash, end="")


if __name__ == "__main__":
    main(sys.argv)

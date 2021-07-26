#!/usr/bin/env python3
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
import re
import sys

args = sys.argv[1:]

if len(args) != 1:
    print(f"Usage: {__file__} [test set name]", file=sys.stderr)
    exit(os.EX_USAGE)

test_set = args[0]

directory = os.path.dirname(os.path.realpath(__file__))

files = [os.path.join(directory, x) for x in filter(lambda x: x.startswith(test_set), os.listdir(directory))]

designs = []

for file in files:
    designs += re.split(r"\s+", open(file).read().strip())

print(" ".join(designs))
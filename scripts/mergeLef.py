#!/usr/bin/env python3
# From: https://github.com/The-OpenROAD-Project/OpenROAD-flow/blob/master/flow/util/mergeLef.py
# Copyright 2020 The OpenROAD Project
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
import argparse  # argument parsing

# WARNING: this script expects the tech lef first

# Parse and validate arguments
# ==============================================================================
parser = argparse.ArgumentParser(description="Merges lefs together")
parser.add_argument("--inputLef", "-i", required=True, help="Input Lef", nargs="+")
parser.add_argument("--outputLef", "-o", required=True, help="Output Lef")
args = parser.parse_args()


def get_delimited_blocks(data):
    # MACRO and SITE blocks
    # assumes correctly indented LEF; otherwise, assertions should fail
    blocks = []

    current_block_name = None
    block_content = []
    for line in data.splitlines():
        if line.startswith("MACRO") or line.startswith("SITE"):
            assert current_block_name is None, (current_block_name, line)
            assert not block_content, block_content
            tokens = line.split()
            assert len(tokens) == 2, line
            current_block_name = tokens[1]
            block_content.append(line)
        elif current_block_name is not None:
            block_content.append(line)
            if line.startswith("END"):
                assert line != "END LIBRARY", current_block_name
                tokens = line.split()
                assert len(tokens) == 2, line
                assert tokens[1] == current_block_name, (line, current_block_name)
                blocks.append("\n".join(block_content))
                current_block_name = None
                block_content = []

    assert not current_block_name, current_block_name
    assert not block_content, block_content
    return blocks


print(os.path.basename(__file__), ": Merging LEFs")

f = open(args.inputLef[0])
content = f.read()
f.close()

# Remove Last line ending the library
content = re.sub("END LIBRARY", "", content)

content = content.splitlines()

lefs = args.inputLef[1:]
if len(lefs) == 1:
    lefs = lefs[0].split()

# Iterate through additional lefs
for lefFile in lefs:
    f = open(lefFile)
    snippet = f.read()
    f.close()

    snippet = snippet.replace("END LIBRARY", "")

    blocks = get_delimited_blocks(snippet)
    site_cnt = 0
    macro_cnt = 0
    for block in blocks:
        if block.startswith("MACRO"):
            macro_cnt += 1
        else:
            assert block.startswith("SITE"), block
            site_cnt += 1

    print(os.path.basename(lefFile) + ": SITEs matched found:", site_cnt)
    print(os.path.basename(lefFile) + ": MACROs matched found:", macro_cnt)

    content.extend(blocks)

content.append("END LIBRARY")

f = open(args.outputLef, "w")
f.write("\n".join(content))
f.close()

print(os.path.basename(__file__), ": Merging LEFs complete")

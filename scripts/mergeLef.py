#!/usr/bin/env python3
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

# All credits go to https://github.com/The-OpenROAD-Project/OpenROAD-flow/blob/master/flow/util/mergeLef.py
# Efabless doesn't own this script

import re
import sys
import os
import argparse  # argument parsing

# WARNING: this script expects the tech lef first

# Parse and validate arguments
# ==============================================================================
parser = argparse.ArgumentParser(
    description='Merges lefs together')
parser.add_argument('--inputLef', '-i', required=True,
                    help='Input Lef', nargs='+')
parser.add_argument('--outputLef', '-o', required=True,
                    help='Output Lef')
args = parser.parse_args()


print(os.path.basename(__file__),": Merging LEFs")

f = open(args.inputLef[0])
content = f.read()
f.close()

# Remove Last line ending the library
content = re.sub("END LIBRARY","",content)

lefs = args.inputLef[1:]
if len(lefs) == 1:
	lefs = lefs[0].split()

# Iterate through additional lefs
for lefFile in lefs:
  f = open(lefFile)
  snippet = f.read()
  f.close()

  # Match the sites
  pattern = r"^SITE.*?^END\s\S+"
  m = re.findall(pattern, snippet, re.M | re.DOTALL)

  print(os.path.basename(lefFile) + ": SITEs matched found: " + str(len(m)))
  content += "\n".join(m)

  # Match the macros
  pattern = r"^MACRO.*?^END\s\S+"
  m = re.findall(pattern, snippet, re.M | re.DOTALL)

  print(os.path.basename(lefFile) + ": MACROs matched found: " + str(len(m)))
  content += "\n" + "\n".join(m)


content += "\nEND LIBRARY"

f = open(args.outputLef, "w")
f.write(content)
f.close()

print(os.path.basename(__file__),": Merging LEFs complete")

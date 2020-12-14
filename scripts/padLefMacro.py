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

# Adapted from the OpenROAD project

import re
import sys
import os
import argparse  # argument parsing

# Parse and validate arguments
# ==============================================================================
parser = argparse.ArgumentParser(
    description='Adds padding to the right of all macros in a lef file')
parser.add_argument('--right', '-r', required=False, type=float,
                    default='0',
                    help='Padding on the right in SITE widths')
parser.add_argument('--left', '-l', required=False, type=float,
                    default='0',
                    help='Padding on the left in SITE widths')
parser.add_argument('--top', '-t', required=False, type=float,
                    default='0',
                    help='Padding on the top in SITE heights')
parser.add_argument('--bottom', '-b', required=False, type=float,
                    default='0',
                    help='Padding on the bottom in SITE heights')
parser.add_argument('--site', '-s', required=False,
                    default='0',
                    help='Lef SITE')
parser.add_argument('--site_width', '-sw', required=False,
                    default='0')
parser.add_argument('--site_height', '-sh', required=False,
                    default='0')
parser.add_argument('--exclude', '-e', required=False,
                    help='exclude')
parser.add_argument('--inputLef', '-i', required=True,
                    help='Input LEF')
parser.add_argument('--outputLef', '-o', required=True,
                    help='Output LEF')
args = parser.parse_args()

REGEXNUM = "-?\d+\.?\d*"

def replace_size(match):
  m = match.groups()
  newWidth = float(m[0]) + right_padding + left_padding
  newHeight = float(m[1]) + top_padding + bottom_padding
  return "SIZE " + '{0:g}'.format(newWidth) + " BY " + '{0:g}'.format(newHeight)

def replace_rect(match):
  m = match.groups()
  pt1 = '{0:g}'.format(float(m[0]) + left_padding) + " " + '{0:g}'.format(float(m[1]) + bottom_padding)
  pt2 = '{0:g}'.format(float(m[2]) + left_padding) + " " + '{0:g}'.format(float(m[3]) + bottom_padding)
  return "RECT " + pt1 + " " + pt2

def replace_rectMask(match):
  m = match.groups()
  pt1 = '{0:g}'.format(float(m[0]) + left_padding) + " " + '{0:g}'.format(float(m[1]) + bottom_padding)
  pt2 = '{0:g}'.format(float(m[2]) + left_padding) + " " + '{0:g}'.format(float(m[3]) + bottom_padding)
  return "RECT MASK " + str(m[0]) + " " + pt1 + " " + pt2

# Function used by re.sub
def replace_pad(match):
  m = match.groups()
  skip = 0

  # Check if it's a MACRO to be skipped
  for pattern in args.exclude.split():
    if re.match(pattern, m[0]):
      print('Skipping LEF padding for MACRO ', m[0])
      return match.group()

  returnString = match.group()

  # Pad SIZE
  sizePattern = r"SIZE\s+(" + REGEXNUM + r")\s+BY\s+(" + REGEXNUM + r")"
  returnString = re.sub(sizePattern, replace_size, returnString, 0, re.M | re.DOTALL)

  # Pad RECTs
  rectPattern = r"RECT\s+(" + REGEXNUM + r")\s+(" + REGEXNUM + r")\s+(" + REGEXNUM + r")\s+(" + REGEXNUM + r")"
  returnString = re.sub(rectPattern, replace_rect, returnString, 0, re.M | re.DOTALL)

  # Pad RECT MASKs
  rectMastPattern = r"^RECT\s+MASK\s+(" + REGEXNUM + r")\s+(" + REGEXNUM + r")\s+(" + REGEXNUM + r")\s+(" + REGEXNUM + r")"
  returnString = re.sub(rectMastPattern, replace_rectMask, returnString, 0, re.M | re.DOTALL)

  return returnString


print(os.path.basename(__file__),": Padding technology lef file")

# Read input file
f = open(args.inputLef)
content = f.read()
f.close()

# Find SITE width
sitePattern = r"^SITE\s+" + args.site + r".*SIZE\s+(" + REGEXNUM + r")\s+BY\s+(" + REGEXNUM + r").*END\s+" + args.site
m = re.search(sitePattern, content, re.M | re.DOTALL)

if m:
  site_width = float(m.group(1))
  site_height = float(m.group(2))
elif args.site_height or args.site_width:
  site_width = float(args.site_width)
  site_height = float(args.site_height)
else:
  raise ValueError("Error: no site size")

right_padding = float(args.right) * site_width
left_padding = float(args.left) * site_width
top_padding = float(args.top) * site_height
bottom_padding = float(args.bottom) * site_height

print("Derived SITE width (microns): " + str(site_width))
print("Derived SITE height (microns): " + str(site_height))
print("Right cell padding (microns): " + str(right_padding))
print("Left cell padding (microns): " + str(left_padding))
print("Top cell padding (microns): " + str(top_padding))
print("Bottom cell padding (microns): " + str(bottom_padding))


# Perform substitution on every macro
pattern = r"^MACRO\s+(\S+).*?^END\s\S+"
result, count = re.subn(pattern, replace_pad, content, 0, re.M | re.DOTALL)

# Write output file
f = open(args.outputLef, "w")
f.write(result)
f.close()

# Check
if count < 1:
  print("WARNING: Replacement pattern not found")
  # sys.exit(1)

print(os.path.basename(__file__),": Finished")

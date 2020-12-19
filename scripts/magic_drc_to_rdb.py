# Copyright 2020 Efabless Corporation
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

# Developed by @ganeshgore

import os
import sys
import re
import shutil
import argparse
import math


def formatter(prog): return argparse.HelpFormatter(prog, max_help_position=60)


parser = argparse.ArgumentParser(formatter_class=formatter)

# Mandatory arguments
parser.add_argument('--magic_drc_in', type=str, default="./checks/caravel.magic.drc")
parser.add_argument('--rdb_out', type=str, default="./checks/caravel.magic.rdb")
args = parser.parse_args()

data, drc = True, False
def main():
    try:
        fp = open(args.magic_drc_in)
        lineType = data
        drcRule = ""
        with open(args.rdb_out,"w") as fpw:
            for indx, line in enumerate(fp.readlines()):
                if ("[INFO]" in line) or (len(line.strip())==0):
                    continue
                elif indx == 0:
                    fpw.write(f"${line} 100\n")
                elif "------" in line:
                    lineType = not lineType
                elif (lineType==drc):
                    drcRule = line.strip().split("(")
                    drcRule = [drcRule,"UnknownRule"] if len(drcRule) <2 else drcRule
                    fpw.write(f"r_0_{drcRule[1][:-1]}\n")
                    fpw.write(f"500 500 2 Nov 29 03:26:39 2020\n")
                    fpw.write(f"Rule File Pathname: {args.magic_drc_in}\n")
                    fpw.write(f"{drcRule[1][:-1]}: {drcRule[0]}\n")
                    drcNumber = 1
                elif (lineType==data):
                    cord = [int(float(i))*100 for i in line.strip().split(" ")]
                    fpw.write(f"p {drcNumber} 4\n")
                    fpw.write(f"{cord[0]} {cord[1]}\n")
                    fpw.write(f"{cord[2]} {cord[1]}\n")
                    fpw.write(f"{cord[2]} {cord[3]}\n")
                    fpw.write(f"{cord[0]} {cord[3]}\n")
                    drcNumber+=1
        print(f"Generated RDB at {args.rdb_out}")
    except IOError:
        print("Magic DRC Error file not found {args.magic_drc_in}")
    except:
        print("Failed to generate RDB file")
    finally:
        fp.close()


if __name__ == "__main__":
    main()

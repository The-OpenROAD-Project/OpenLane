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

import re
import argparse


parser = argparse.ArgumentParser(
    description='Replaces a given prefix from instances in DEF COMPONENTS with another.')

parser.add_argument('--def_file', '-d',required=True,
                    help='Input DEF')

parser.add_argument('--original_prefix', '-op', required=True,
                    help='The original prefix')
parser.add_argument('--new_prefix', '-np', required=True,
                    help='The new prefix')


args = parser.parse_args()

def_file     =   args.def_file

original_prefix   =   args.original_prefix
new_prefix   =   args.new_prefix



tmpFile = open(def_file,"r")
if tmpFile.mode == 'r':
    defContent = tmpFile.read()
tmpFile.close()

exitFlag = False
for line in defContent.split("\n"):
    if line.find("COMPONENTS") != -1:
        if exitFlag:
            break
        else:
            exitFlag = True
            continue
    
    if exitFlag:
        cell = re.findall(r'- '+original_prefix+r'_(\d+) ',line)
        if len(cell) == 1:
            old = " " + original_prefix + "_" + cell[0]+" "
            new = " " + new_prefix + "_" + cell[0]+" "
            defContent = defContent.replace(old,new)

tmpFile = open(def_file,"w")
tmpFile.write(defContent)
tmpFile.close()


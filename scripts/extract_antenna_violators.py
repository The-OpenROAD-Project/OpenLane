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

import argparse
import re

parser = argparse.ArgumentParser(
    description='extracts the list of violating nets from an ARC report file')

parser.add_argument('--report', '-i',required=True,
                    help='report file')

parser.add_argument('--output', '-o', required=True,
                    help='output file to store results')

args = parser.parse_args()
report_file_name = args.report
out_file_name = args.output

vios_list=[]

reportFileOpener = open(report_file_name, "r")
if reportFileOpener.mode == 'r':
    reportContent = reportFileOpener.read()
reportFileOpener.close()


pattern = re.compile(r'\n\s*[\S+]+\s*\([\S+]+\)\s*[\S+]+')
cells = re.findall(pattern, reportContent)
cnt = 0
for idx in range(len(cells)):
    cell = ""
    if idx != len(cells)-1:
        cell = reportContent.split(cells[idx])[1].split(cells[idx+1])[0]
    else:
        cell = reportContent.split(cells[idx])[1]
    if cell.find("*") != -1:
        #print("AYe")
        #print(cells[idx])
        #print (cells[idx+1])
        #cnt+=1
        vio = cells[idx].strip().split(" (")[0]
        print(vio)     
        vios_list.append(vio)
    #if cnt == 7:
        #break
outFileOpener = open(out_file_name, "w")
outFileOpener.write(" ".join(vios_list))
outFileOpener.close()

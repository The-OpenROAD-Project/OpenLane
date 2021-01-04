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

pattern = re.compile(r'\s*([\S+]+)\s*\([\S+]+\)\s*[\S+]+')

vios_list=[]
current_net = ''
printed = False

with open(report_file_name, "r") as f:
    for line in f:
        m = pattern.match(line)
        if m:
            current_net = m.group(1)
            printed = False

        if '*' in line and not printed:
            print(current_net)
            vios_list.append(current_net + ' ')
            printed = True


outFileOpener = open(out_file_name, "w")
outFileOpener.write(" ".join(vios_list))
outFileOpener.close()

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
    description='extracts the total xor differnces from an xor log')

parser.add_argument('--log_file', '-l',required=True,
                    help='log file')

parser.add_argument('--output', '-o', required=True,
                    help='output file to store results')

args = parser.parse_args()
log_file_name = args.log_file
out_file_name = args.output

string = "XOR differences:"
pattern = re.compile(r'\s*%s\s*([\d+]+)' % string)
tot_cnt = 0
with open(log_file_name, "r") as f:
    for line in f:
        m = pattern.match(line)
        if m:
            tot_cnt += int(m.group(1))

outFileOpener = open(out_file_name, "w")
outFileOpener.write("Total XOR differences = "+ str(tot_cnt))
outFileOpener.close()

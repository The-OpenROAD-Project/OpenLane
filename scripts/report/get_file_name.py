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

# The only purpose of this file is to create a wrapper around report.py and config.py and make them usable by flow.tcl

import argparse
import os

parser = argparse.ArgumentParser(
    description='Returns the output_file name with the highest index.')

parser.add_argument('--path', '-p', required=True,
                    help='Path')

parser.add_argument('--output_file', '-o', required=True,
                    help='File name to search for, i.e. 1.X 2.X 3.X, then the script will return <path>/3.X')

args = parser.parse_args()
run_path=args.path
output_file = args.output_file
neededfile = sorted([(int(f.split('.',1)[0]),f.split('.',1)[1]) for f in os.listdir(run_path) if os.path.isfile(os.path.join(run_path, f)) and len(f.split('.',1)) > 1 and f.split('.',1)[1] == output_file])[0]
print(str(run_path)+'/'+str(neededfile[0])+'.'+str(neededfile[1]))

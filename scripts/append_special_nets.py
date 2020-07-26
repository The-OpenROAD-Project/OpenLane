#!/usr/bin/env python3
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


import argparse  # argument parsing
import re
from shutil import copyfile

parser = argparse.ArgumentParser(
    description='Adds special nets from one file to another')
parser.add_argument('--source', required=True)
parser.add_argument('--destination', required=True)
args = parser.parse_args()

source_file = args.source
destination_file = args.destination

with open(source_file, 'r') as source, \
open(destination_file, 'r+') as destination:
	input_def = source.read()
	pattern = r'^ *SPECIALNETS.*^ *END SPECIALNETS *\s'
	special_nets_section = re.findall(pattern, input_def, re.M | re.DOTALL)

	output_def = destination.read()
	output_def = re.sub("END DESIGN", "", output_def)
	output_def = output_def + "\n" + special_nets_section[0]
	destination.seek(0)
	destination.write(output_def)
	destination.truncate()

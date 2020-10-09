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
from scripts.report.report import Report
from scripts.config.config import ConfigHandler
import scripts.utils.utils as utils

parser = argparse.ArgumentParser(
    description='Creates a csv report for a given design.')

parser.add_argument('--design', '-d', required=True,
                    help='Design Path')

parser.add_argument('--design_name', '-dn', required=True,
                    help='Design Name')

parser.add_argument('--tag', '-t', required=False,
                    help='Run Tag')

parser.add_argument('--output_file', '-o', required=False,
                    help='Output File')

args = parser.parse_args()
design = args.design
design_name = args.design_name
tag = args.tag
output_file = args.output_file

# Extracting Configurations
params = ConfigHandler.get_config(design, tag)
# Extracting Report
report = Report(design, tag, design_name,params).get_report()
# write into file
outputFileOpener = open(output_file,"w")
outputFileOpener.write(Report.get_header() + "," + ConfigHandler.get_header())
outputFileOpener.write("\n")
outputFileOpener.write(report)
outputFileOpener.close()

# Adding Extra Attributes computed from configs and reported statistics
utils.addComputedStatistics(output_file)

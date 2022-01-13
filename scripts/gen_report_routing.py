# Copyright 2021 The University of Michigan
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
from config.config import ConfigHandler
from report.report_routing import Report

parser = argparse.ArgumentParser(
    description="Creates reports after routing phase is concluded"
)

parser.add_argument("--design", "-d", required=True, help="Design Path")

parser.add_argument("--design_name", "-n", required=True, help="Design Name")

parser.add_argument("--tag", "-t", required=True, help="Run Tag")

parser.add_argument("--run_path", "-r", default=None, help="Run Path")

args = parser.parse_args()
design = args.design
design_name = args.design_name
tag = args.tag
run_path = args.run_path

params = ConfigHandler.get_config(design, tag, run_path)
Report(design, tag, design_name, params, run_path).reports_from_logs()

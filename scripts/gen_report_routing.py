import argparse
import os
import re
import utils.utils as utils
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

#!/usr/bin/env python3
import os
import re
import sys
import yaml
import argparse
from typing import List

def timestamp_to_seconds(runtime):
    pattern = re.compile(r"\s*([\d+]+)h([\d+]+)m([\d+]+)s([\d+]+)+ms")
    m = pattern.match(runtime)
    time = (
        int(m.group(1)) * 60 * 60
        + int(m.group(2)) * 60
        + int(m.group(3))
        + int(m.group(4)) / 1000.0
    )
    return time

parser = argparse.ArgumentParser()
parser.add_argument("step")

args = parser.parse_args()
step = args.step

runtime_file_path: str = os.path.join(os.environ["RUN_DIR"], "runtime.yaml")
runtime_data_str: str = "[]"
try:
    runtime_data_str = open(runtime_file_path).read()
except FileNotFoundError:
    pass

runtime_data: List = yaml.safe_load(runtime_data_str)

current_runtime = sys.stdin.read().rstrip()

obj = {
    "step": f"{os.environ['CURRENT_INDEX']} - {step}",
    "runtime": current_runtime,
    "runtime_s": timestamp_to_seconds(current_runtime)
}

runtime_data.append(obj)

with open(runtime_file_path, "w") as f:
    f.write(yaml.safe_dump(runtime_data))
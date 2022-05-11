#!/usr/bin/python3
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
import os
import re
import csv


def get_design_path(design):
    path = os.path.abspath(design) + "/"
    if not os.path.exists(path):
        path = os.path.join(os.getcwd(), f"./designs/{design}/")
    if os.path.exists(path):
        return path
    else:
        return None


def get_run_path(design, tag):
    return os.path.join(get_design_path(design), "runs", tag)


def get_design_name(design, config):
    design_path = get_design_path(design=design)
    if design_path is None:
        return ("Design path not found", None)
    config_file = f"{design_path}/{config}.tcl"
    try:
        config_file_opener = open(config_file, "r")
        configs = config_file_opener.read()
        config_file_opener.close()
        pattern = re.compile(r"\s*?set ::env\(DESIGN_NAME\)\s*?(\S+)\s*")
        for name in re.findall(pattern, configs):
            return (None, name.strip('"{}'))
        return ("Invalid configuration file", None)
    except OSError:
        return ("Configuration file not found", None)


def add_computed_statistics(filename):
    """
    Adds some calculated values to a report CSV file, namely:

    * Cells per mm sq over core utilization
    * Suggested clock period
    * Suggested clock frequency
    """
    rows = []

    csv_headers = open(filename).read().split("\n")[0].split(",")

    def add(name: str, before: str):
        nonlocal csv_headers
        idx = csv_headers.index(before)
        csv_headers.insert(idx, name)

    add("(Cell/mm^2)/Core_Util", "DIEAREA_mm^2")
    add("suggested_clock_period", "CLOCK_PERIOD")
    add("suggested_clock_frequency", "CLOCK_PERIOD")

    csv_file_in = open(filename)
    reader = csv.DictReader(csv_file_in)
    for row in reader:
        row["(Cell/mm^2)/Core_Util"] = float(row["CellPer_mm^2"]) / (
            float(row["FP_CORE_UTIL"]) / 100
        )

        suggest_clock_period = float(row["CLOCK_PERIOD"]) - float(row["spef_wns"])
        row["suggested_clock_period"] = suggest_clock_period
        row["suggested_clock_frequency"] = 1000 / suggest_clock_period
        rows.append(row)
    csv_file_in.close()

    with open(filename, "w") as f:
        writer = csv.DictWriter(f, csv_headers)
        writer.writeheader()
        for row in rows:
            writer.writerow(row)

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
import sys
import pandas as pd
import re

def get_design_path(design):
    path = os.path.abspath(design) + '/'
    if not os.path.exists(path):
        path = os.path.join(
            os.getcwd(),
            './designs/{design}/'.format(
                design=design
            )
        )
    if os.path.exists(path):
        return path
    else:
        return None

def get_run_path(design, tag):
    DEFAULT_PATH = os.path.join(
        get_design_path(design),
        'runs/{tag}/'.format(
            tag=tag
        )
    )

    return DEFAULT_PATH

def get_design_name(design, config):
        design_path= get_design_path(design=design)
        if design_path is None:
            print("{design} not found, skipping...".format(design=design))
            return "[INVALID]: design path doesn't exist"
        config_file = "{design_path}/{config}.tcl".format(
                design_path=design_path,
                config=config,
        )
        try:
            config_file_opener = open(config_file, "r")
            configs = config_file_opener.read()
            config_file_opener.close()
            pattern = re.compile(r'\s*?set ::env\(DESIGN_NAME\)\s*?(\S+)\s*')
            for name in re.findall(pattern, configs):
                    return name.replace("\"","")
            return "[INVALID]: design name doesn't exist inside the config file!"
        except OSError:
            return "[INVALID]: design config doesn't exist"

# addComputedStatistics adds: CellPerMMSquaredOverCoreUtil, suggested_clock_period, and suggested_clock_frequency to a report.csv
def addComputedStatistics(filename):
    data = pd.read_csv(filename, error_bad_lines=False)
    df = pd.DataFrame(data)

    diearea_mm2_index = df.columns.get_loc("DIEAREA_mm^2")
    df.insert(diearea_mm2_index,
        column='(Cell/mm^2)/Core_Util',
        value= df['CellPer_mm^2'] / (df['FP_CORE_UTIL'] / 100),
        allow_duplicates=True
    )

    suggest_clock_period = df['CLOCK_PERIOD'] - df['spef_wns']
    clock_period_index = df.columns.get_loc("CLOCK_PERIOD")
    df.insert(
        clock_period_index,
        column='suggested_clock_period',
        value=suggest_clock_period,
        allow_duplicates=True
    )
    df.insert(
        clock_period_index,
        column='suggested_clock_frequency',
        value=1000.0/suggest_clock_period,
        allow_duplicates=True
    )
    df.to_csv(filename)

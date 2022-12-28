# Copyright 2020-2021 Efabless Corporation
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
from typing import Dict
from shutil import copyfile
from collections import OrderedDict

sys.path.append(os.path.dirname(os.path.dirname(__file__)))
sys.path.append(os.path.dirname(__file__))

from utils.utils import get_run_path, get_design_path  # noqa: E402
from tcl import read_tcl_env  # noqa: E402


class ConfigHandler:
    configuration_values = [
        "CLOCK_PERIOD",
        "SYNTH_STRATEGY",
        "SYNTH_MAX_FANOUT",
        "FP_CORE_UTIL",
        "FP_ASPECT_RATIO",
        "FP_PDN_VPITCH",
        "FP_PDN_HPITCH",
        "PL_TARGET_DENSITY",
        "GRT_ADJUSTMENT",
        "STD_CELL_LIBRARY",
        "DIODE_INSERTION_STRATEGY",
    ]

    configuration_files = [
        "synthesis.tcl",
        "floorplan.tcl",
        "placement.tcl",
        "cts.tcl",
        "routing.tcl",
        # "magic.tcl",
    ]

    @classmethod
    def update_configuration_values(Self, params, append):
        if append:
            Self.configuration_values = Self.configuration_values + params
        else:
            Self.configuration_values = params
        Self.configuration_values = list(
            OrderedDict.fromkeys(Self.configuration_values)
        )

    @classmethod
    def update_configuration_values_to_all(Self, append):
        config_relative_path = "configuration"
        config_path = os.path.join(os.getcwd(), config_relative_path)
        if not append:
            Self.configuration_values = []

        for file in Self.configuration_files:
            try:
                file_string = open(os.path.join(config_path, file), "r").read()
                file_lines = file_string.split("\n")
                for line in file_lines:
                    start = line.find("(")
                    end = line.find(")")
                    if (start > -1) & (end > 0) & (line.find("SCRIPT") == -1):
                        Self.configuration_values.append(line[start + 1 : end])
            except OSError:
                print("Could not open/read file:", config_path)
                sys.exit()
        Self.configuration_values = list(dict.fromkeys(Self.configuration_values))

    @classmethod
    def get_header(Self):
        return ",".join(Self.configuration_values)

    @classmethod
    def get_config_for_run(Self, run_path, design, tag) -> Dict[str, str]:
        if run_path is None:
            run_path = get_run_path(design=design, tag=tag)
        config_path = os.path.join(os.getcwd(), run_path, "config.tcl")
        config = read_tcl_env(config_path)
        config = {k: v for k, v in config.items() if k in Self.configuration_values}
        return config

    @staticmethod
    def gen_base_config(design, base_config_file):
        config_file = os.path.join(get_design_path(design=design), "config.tcl")
        copyfile(config_file, base_config_file)

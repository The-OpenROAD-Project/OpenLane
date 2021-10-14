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
import subprocess
import sys

sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from shutil import copyfile
from utils.utils import *
from collections import OrderedDict

class ConfigHandler:
    config_getter_script = os.path.join(os.path.dirname(__file__), "config_get.sh")

    configuration_values = [
        'CLOCK_PERIOD',
        'SYNTH_STRATEGY',
        'SYNTH_MAX_FANOUT',
        'FP_CORE_UTIL',
        'FP_ASPECT_RATIO',
        'FP_PDN_VPITCH',
        'FP_PDN_HPITCH',
        'PL_TARGET_DENSITY',
        'GLB_RT_ADJUSTMENT',
        'STD_CELL_LIBRARY',
        'CELL_PAD',
        'DIODE_INSERTION_STRATEGY'
    ]

    base_config_values = [
        'DESIGN_NAME',
        'VERILOG_FILES',
        'CLOCK_PERIOD',
        'CLOCK_PORT'
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
        Self.configuration_values = list(OrderedDict.fromkeys(Self.configuration_values))

    @classmethod
    def update_configuration_values_to_all(Self, append):
        config_relative_path = "configuration"
        config_path = os.path.join(os.getcwd(), config_relative_path)
        if append == False:
            Self.configuration_values = []

        for file in Self.configuration_files:
            try:
                file_string = open(os.path.join(config_path, file), "r").read()
                file_lines = file_string.split("\n")
                for line in file_lines:
                    start =  line.find("(")
                    end = line.find(")")
                    if (start > -1) & (end > 0) & (line.find("SCRIPT") == -1):
                        Self.configuration_values.append(line[start+1:end])
            except OSError:
                print("Could not open/read file:", config_path)
                sys.exit()
        Self.configuration_values = list( dict.fromkeys(Self.configuration_values) )

    @classmethod
    def get_header(Self):
        return ",".join(Self.configuration_values)

    @classmethod
    def get_config(Self, design, tag, run_path=None):
        if run_path is None:
            run_path = get_run_path(design=design, tag=tag)
        config_params = " ".join(Self.configuration_values)
        config_relative_path = "config.tcl"
        config_path = os.path.join(os.getcwd(), run_path, config_relative_path)
        cmd = "{script} {path} {params}".format(script=Self.config_getter_script, path=config_path, params=config_params)
        config_coded = subprocess.check_output(cmd.split())
        config = config_coded.decode(sys.getfilesystemencoding()).strip()
        config = config.split("##")
        config = list(filter(None, config))
        return config

    @classmethod
    def gen_base_config_legacy(Self, design, base_config_path):
        config_params = " ".join(Self.base_config_values)
        config_relative_path = "designs/{design}/config.tcl".format(design=design)
        config_path = os.path.join(os.getcwd(), config_relative_path)
        cmd = "{script} {path} {params}".format(script=Self.config_getter_script, path=config_path, params=config_params)
        config_coded = subprocess.check_output(cmd.split())
        config = config_coded.decode(sys.getfilesystemencoding()).strip()
        config = config.split("##")
        config = list(filter(None, config))

        f = open(base_config_path, 'w')
        for i in range(len(config)):
            f.write("set ::env({var}) {val}\n".format(var=Self.base_config_values[i], val=config[i]))

        f.close()

    @staticmethod
    def gen_base_config(design, base_config_file):
        config_file = os.path.join(get_design_path(design=design), 'config.tcl')
        copyfile(config_file, base_config_file)



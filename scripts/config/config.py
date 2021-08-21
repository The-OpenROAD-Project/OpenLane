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
from shutil import copyfile
from ..utils.utils import *
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

    base_config_values = ['DESIGN_NAME', 'VERILOG_FILES', 'CLOCK_PERIOD', 'CLOCK_PORT']

    @staticmethod
    def update_configuration_values(params, append):
        if append:
            ConfigHandler.configuration_values = ConfigHandler.configuration_values + params
        else:
            ConfigHandler.configuration_values = params
        ConfigHandler.configuration_values = list(OrderedDict.fromkeys(ConfigHandler.configuration_values))

    @staticmethod
    def update_configuration_values_to_all(append):
        configFiles = ["synthesis.tcl","floorplan.tcl","placement.tcl","cts.tcl", "routing.tcl"]#, "magic.tcl"]
        config_relative_path = "configuration/"
        config_path = os.path.join(os.getcwd(), config_relative_path)
        if append == False:
            ConfigHandler.configuration_values = []

        for configFile in configFiles:
            try:
                tmpFile = open(config_path+configFile,"r")
                if tmpFile.mode == 'r':
                    configurationFileContent = tmpFile.read().split("\n")
                    for line in configurationFileContent:
                        start =  line.find("(")
                        end = line.find(")")
                        if (start > -1) & (end >0) & (line.find("SCRIPT") == -1) :
                            ConfigHandler.configuration_values.append(line[start+1:end])
            except  OSError:
                print ("Could not open/read file:", config_path)
                sys.exit()
        ConfigHandler.configuration_values = list( dict.fromkeys(ConfigHandler.configuration_values) )

    @staticmethod
    def get_header():
        return ",".join(ConfigHandler.configuration_values)

    @staticmethod
    def get_config(design, tag, run_path=None):
        if run_path is None:
            run_path = get_run_path(design=design, tag=tag)
        config_params = " ".join(ConfigHandler.configuration_values)
        config_relative_path = "config.tcl"
        config_path = os.path.join(os.getcwd(), run_path, config_relative_path)
        cmd = "{script} {path} {params}".format(script=ConfigHandler.config_getter_script, path=config_path, params=config_params)
        config_coded = subprocess.check_output(cmd.split())
        config = config_coded.decode(sys.getfilesystemencoding()).strip()
        config = config.split("##")
        config = list(filter(None, config))
        return config

    @staticmethod
    def gen_base_config_legacy(design, base_config_path):
        config_params = " ".join(ConfigHandler.base_config_values)
        config_relative_path = "designs/{design}/config.tcl".format(design=design)
        config_path = os.path.join(os.getcwd(), config_relative_path)
        cmd = "{script} {path} {params}".format(script=ConfigHandler.config_getter_script, path=config_path, params=config_params)
        config_coded = subprocess.check_output(cmd.split())
        config = config_coded.decode(sys.getfilesystemencoding()).strip()
        config = config.split("##")
        config = list(filter(None, config))

        f = open(base_config_path, 'w')
        for i in range(len(config)):
            f.write("set ::env({var}) {val}\n".format(var=ConfigHandler.base_config_values[i], val=config[i]))

        f.close()

    @staticmethod
    def gen_base_config(design, base_config_file):
        config_file = os.path.join(get_design_path(design=design), 'config.tcl')
        copyfile(config_file, base_config_file)



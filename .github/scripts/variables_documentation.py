#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright 2023 Efabless Corporation
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

import subprocess

documented_elsewhere = """
CREATE_REPRODUCIBLE_FROM_SCRIPT
"""
internal_variables = """
CONFIGS
CORE_HEIGHT
CORE_WIDTH
CURRENT_DEF
CURRENT_GDS
CURRENT_GUIDE
CURRENT_INDEX
CURRENT_LIB
CURRENT_NETLIST
CURRENT_ODB
CURRENT_POWERED_NETLIST
CURRENT_SDC
CURRENT_SDF
CURRENT_SPEF
CURRENT_STEP
DEBUG
DESIGN_CONFIG
DESIGN_DIR
ESTIMATE_PARASITICS
EXIT_ON_ERROR
EXT_NETLIST
FLOW_FAILED
GDS_INPUT
GLB_CFG_FILE
GND_NET
GRT_CONGESTION_REPORT_FILE
INSERT_BUFFER_COMMAND
INSERT_BUFFER_COUNTER
IO_READ_DEF
LAST_TIMING_REPORT_TAG
LEC_LHS_NETLIST
LEC_RHS_NETLIST
LOGS_DIR
MAGIC_GDS
MAGIC_SCRIPT
MAX_METAL_LAYER
MC_SDF_DIR
MC_SPEF_DIR
METAL_LAYER_NAMES
OPENLANE_MOUNTED_SCRIPTS_VERSION
OPENLANE_ROOT
OPENLANE_VERSION
OPENLANE_COMMIT
OPENROAD_BIN
PACKAGED_SCRIPT_0
PDKPATH
PROCESS_CORNER
PWD
RCX_DEF
RCX_LEF
RCX_LIB
RCX_RULESET
REPORTS_DIR
REPORT_OUTPUT
RESULTS_DIR
RUN_DIR
RUN_TAG
SAVE_DEF
SAVE_GDS
SAVE_GUIDE
SAVE_LIB
SAVE_MAG
SAVE_NETLIST
SAVE_ODB
SAVE_POWERED_NETLIST
SAVE_SDC
SAVE_SDF
SAVE_SPEF
SCRIPTS_DIR
SCRIPT_DIR
START_TIME
STA_MULTICORNER
STA_PRE_CTS
SYNTH_EXPLORE
SYNTH_SCRIPT
TECH
TERM
TERMINAL_OUTPUT
TMP_DIR
TCL8_5_TM_PATH
TRACKS_INFO_FILE_PROCESSED
VCHECK_OUTPUT
VDD_NET
WRITE_VIEWS_NO_GLOBAL_CONNECT
TECH_METAL_LAYERS
LIB_SYNTH_COMPLETE
LIB_SYNTH_COMPLETE_NO_PG
LIB_SYNTH_MERGED
LIB_SYNTH_NO_PG
"""
gpio_variables = """
USE_GPIO_ROUTING_LEF
GPIO_PADS_LEF_CORE_SIDE
GPIO_PADS_VERILOG
"""
to_be_removed = """
ANTENNA_CHECK_CURRENT_DEF
CTS_CURRENT_DEF
DRC_CURRENT_DEF
LVS_CURRENT_DEF
PARSITICS_CURRENT_DEF
PLACEMENT_CURRENT_DEF
ROUTING_CURRENT_DEF
FAKEDIODE_CELL
VERILOG_STA_NETLISTS
"""
unexposed = """
HEURISTIC_ANTENNA_INSERTION_MODE
STA_MULTICORNER_READ_LIBS
"""
opts = """
CELLS_LEF_OPT
DRC_EXCLUDE_CELL_LIST_OPT
GDS_FILES_OPT
NO_SYNTH_CELL_LIST_OPT
STD_CELL_LIBRARY_OPT_CDL
TECH_LEF_OPT
LIB_SYNTH_OPT
"""
untested = """
LVS_EXTRA_GATE_LEVEL_VERILOG
LVS_EXTRA_STD_CELL_LIBRARY
KLAYOUT_DRC_TECH_SCRIPT
"""

white_list = set(
    (
        internal_variables
        + gpio_variables
        + to_be_removed
        + documented_elsewhere
        + unexposed
        + opts
        + untested
    ).split()
)
docs_variables = (
    subprocess.check_output(
        [
            "rg",
            "\\| *`([A-Z]\\S+) *` *‡*  *\\|",
            "-r",
            "$1",
            "-o",
            "-N",
            "-I",
            "--no-ignore",
            "docs",
        ]
    )
    .decode("utf-8")
    .split()
)
docs_variables = [var for var in docs_variables if var.isupper()]
docs_variables_set = set(docs_variables)

deprecated_docs_variables = (
    subprocess.check_output(
        [
            "rg",
            "\\| *`([A-Z]\\S+) *` *‡*  *\\|.*(Deprecated|Removed)",
            "-r",
            "$1",
            "-o",
            "-N",
            "-I",
            "--no-ignore",
            "docs",
        ]
    )
    .decode("utf-8")
    .split()
)
depreacted_docs_variables = [var for var in deprecated_docs_variables if var.isupper()]
deprecated_docs_variables_set = set(deprecated_docs_variables)


used_variables = (
    subprocess.check_output(
        [
            "rg",
            "\\$::env\\(([A-Z]\\S+?)\\)",
            "-r",
            "$1",
            "-o",
            "-N",
            "-I",
            "--no-ignore",
            "scripts",
            "flow.tcl",
        ]
    )
    .decode("utf-8")
    .split()
)
used_variables_set = set(used_variables)

undocumented = sorted(
    used_variables_set - docs_variables_set - deprecated_docs_variables_set - white_list
)
if undocumented:
    print("[ERROR]: found the following undocumented variables.")
    for var in undocumented:
        print(var)
    exit(1)
else:
    print("Pass")

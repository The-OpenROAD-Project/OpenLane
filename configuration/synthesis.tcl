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

# Synth defaults
set ::env(SYNTH_BIN) yosys
set ::env(SYNTH_SCRIPT) $::env(SCRIPTS_DIR)/yosys/synth.tcl
set ::env(SYNTH_NO_FLAT) 0
set ::env(SYNTH_CLOCK_UNCERTAINTY) 0.25
set ::env(SYNTH_CLOCK_TRANSITION) 0.15
set ::env(SYNTH_TIMING_DERATE) 0.05
set ::env(SYNTH_SHARE_RESOURCES) 1
set ::env(SYNTH_BUFFERING) 1
set ::env(SYNTH_SPLITNETS) 1
set ::env(SYNTH_BUFFER_DIRECT_WIRES) 1
set ::env(SYNTH_SIZING) 0
set ::env(SYNTH_STRATEGY) "AREA 0"
set ::env(SYNTH_ADDER_TYPE) "YOSYS"
set ::env(CLOCK_BUFFER_FANOUT) 16
set ::env(SYNTH_READ_BLACKBOX_LIB) 0
set ::env(SYNTH_ELABORATE_ONLY) 0
set ::env(SYNTH_FLAT_TOP) 0
set ::env(IO_PCT) 0.2
set ::env(SYNTH_EXTRA_MAPPING_FILE) ""

set ::env(BASE_SDC_FILE) $::env(SCRIPTS_DIR)/base.sdc


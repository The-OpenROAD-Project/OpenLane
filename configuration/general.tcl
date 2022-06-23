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

# default pdk/scl
if { ![info exists ::env(PDK)] } {
    set ::env(PDK) "sky130A"
}
if { ![info exists ::env(STD_CELL_LIBRARY)] } {
    set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"
}

set ::env(USE_GPIO_PADS) 0

if { ![info exists ::env(QUIT_ON_MISMATCHES)] } {
    set ::env(QUIT_ON_MISMATCHES) {1}
}
if { ![info exists ::env(TEST_MISMATCHES)] } {
    set ::env(TEST_MISMATCHES) {all}
}

# Flow control defaults
set ::env(RUN_LVS) 1

set ::env(LEC_ENABLE) 0
set ::env(YOSYS_REWRITE_VERILOG) 0

set ::env(PRIMARY_SIGNOFF_TOOL) magic

set ::env(RUN_MAGIC) 1
set ::env(RUN_MAGIC_DRC) 1
set ::env(MAGIC_PAD) 0
set ::env(MAGIC_ZEROIZE_ORIGIN) 0
set ::env(MAGIC_GENERATE_GDS) 1
set ::env(MAGIC_GENERATE_LEF) 1
set ::env(MAGIC_GENERATE_MAGLEF) 1
set ::env(MAGIC_WRITE_FULL_LEF) 0
set ::env(MAGIC_DRC_USE_GDS) 1
set ::env(MAGIC_EXT_USE_GDS) 0
set ::env(MAGIC_INCLUDE_GDS_POINTERS) 0
set ::env(MAGIC_DISABLE_HIER_GDS) 1
set ::env(MAGIC_CONVERT_DRC_TO_RDB) 1

set ::env(KLAYOUT_XOR_GDS) 1
set ::env(KLAYOUT_XOR_XML) 1

set ::env(RUN_ROUTING_DETAILED) 1
set ::env(RUN_SIMPLE_CTS) 0
set ::env(CLOCK_PERIOD) "10.0"
set ::env(RUN_KLAYOUT) 1
set ::env(TAKE_LAYOUT_SCROT) 0
set ::env(RUN_KLAYOUT_DRC) 0
set ::env(KLAYOUT_DRC_KLAYOUT_GDS) 0
set ::env(RUN_KLAYOUT_XOR) 1
set ::env(USE_ARC_ANTENNA_CHECK) 1

set ::env(FILL_INSERTION) 1
set ::env(TAP_DECAP_INSERTION) 1

set ::env(WIDEN_SITE) 1
set ::env(WIDEN_SITE_IS_FACTOR) 1

set ::env(RUN_SPEF_EXTRACTION) 1
set ::env(RUN_CVC) 1

set ::env(GENERATE_FINAL_SUMMARY_REPORT) 1


# 0: no diodes
# 1: spray inputs with diodes
# 2: spray inputs with fake diodes first then fix up the violators with real ones
# 3: use FR Antenna Avoidance flow
# 4: Spray diodes on design pins, and add diodes where they need to be added for each macro.
# 5: Same as 2 but behaves like 4.
set ::env(DIODE_INSERTION_STRATEGY) 3

set ::env(STA_REPORT_POWER) {1}

## ECO Flow
set ::env(ECO_ENABLE) {0}
set ::env(ECO_ITER) {0}
set ::env(ECO_FINISH) {0}
set ::env(ECO_SKIP_PIN) {1}

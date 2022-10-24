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

# General Defaults
set ::env(CLOCK_PERIOD) "10.0"
set ::env(USE_GPIO_PADS) 0
set ::env(RSZ_DONT_TOUCH_RX) "$^"


# Flow Controls
set ::env(LEC_ENABLE) 0
set ::env(YOSYS_REWRITE_VERILOG) 0
set ::env(FILL_INSERTION) 1
set ::env(TAP_DECAP_INSERTION) 1

## Intentionally Undocumented
set ::env(RSZ_USE_OLD_REMOVER) 0

## STA
set ::env(STA_REPORT_POWER) {1}
set ::env(STA_WRITE_LIB) {1}

## ECO Flow
set ::env(ECO_ENABLE) {0}
set ::env(ECO_ITER) {0}
set ::env(ECO_FINISH) {0}
set ::env(ECO_SKIP_PIN) {1}

## Routing
set ::env(RUN_DRT) 1
set ::env(USE_ARC_ANTENNA_CHECK) 1
set ::env(RUN_SPEF_EXTRACTION) 1
set ::env(RUN_IRDROP_REPORT) 1

# See documentation for the various strategies.
set ::env(DIODE_INSERTION_STRATEGY) {3}

## Signoff
set ::env(RUN_CVC) 1
set ::env(PRIMARY_SIGNOFF_TOOL) magic

### Netgen
set ::env(RUN_LVS) 1
set ::env(LVS_INSERT_POWER_PINS) 1
set ::env(LVS_CONNECT_BY_LABEL) 0

### Magic-Specific
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
set ::env(MAGIC_DEF_NO_BLOCKAGES) 1
set ::env(MAGIC_DEF_LABELS) 1

### Klayout-Specific
set ::env(RUN_KLAYOUT) 1
set ::env(RUN_KLAYOUT_DRC) 0
set ::env(KLAYOUT_XOR_GDS) 1
set ::env(KLAYOUT_XOR_XML) 1
set ::env(TAKE_LAYOUT_SCROT) 0
set ::env(KLAYOUT_DRC_KLAYOUT_GDS) 0
set ::env(RUN_KLAYOUT_XOR) 1

set ::env(GENERATE_FINAL_SUMMARY_REPORT) {1}

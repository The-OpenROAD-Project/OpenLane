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

foreach lib $::env(LIB_RESIZER_OPT) {
    read_liberty $lib
}
if {[catch {read_lef $::env(MERGED_LEF_UNPADDED)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

read_sdc -echo $::env(BASE_SDC_FILE)

# Resize
# estimate wire rc parasitics
set_wire_rc -signal -layer $::env(WIRE_RC_LAYER)
set_wire_rc -clock  -layer $::env(WIRE_RC_LAYER)
estimate_parasitics -placement
if { [info exists ::env(DONT_USE_CELLS)] } {
    set_dont_use $::env(DONT_USE_CELLS)
}

if { [info exists ::env(PL_RESIZER_BUFFER_INPUT_PORTS)] && $::env(PL_RESIZER_BUFFER_INPUT_PORTS) } {
    buffer_ports -inputs
}

if { [info exists ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS)] && $::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) } {
    buffer_ports -outputs
}

if { [info exists ::env(PL_RESIZER_MAX_WIRE_LENGTH)] && $::env(PL_RESIZER_MAX_WIRE_LENGTH) } {
    repair_design -max_wire_length $::env(PL_RESIZER_MAX_WIRE_LENGTH)
} else {
    repair_design
}

report_floating_nets -verbose

set_placement_padding -global -right $::env(CELL_PAD)

set_placement_padding -masters $::env(CELL_PAD_EXCLUDE) -right 0 -left 0
detailed_placement
if { [info exists ::env(PL_OPTIMIZE_MIRRORING)] && $::env(PL_OPTIMIZE_MIRRORING) } {
    optimize_mirroring
}
check_placement -verbose


write_def $::env(SAVE_DEF)

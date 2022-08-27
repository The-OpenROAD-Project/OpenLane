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

if { [info exists ::env(EXTRA_LIBS) ] } {
    foreach lib $::env(EXTRA_LIBS) {
        read_liberty $lib
    }
}

if {[catch {read_lef $::env(MERGED_LEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

read_sdc $::env(CURRENT_SDC)
set_propagated_clock [all_clocks]

if { [info exists ::env(DONT_USE_CELLS)] } {
    set_dont_use $::env(DONT_USE_CELLS)
}

# set rc values
source $::env(SCRIPTS_DIR)/openroad/set_rc.tcl

# CTS and detailed placement move instances, so update parastic estimates.
# estimate wire rc parasitics
estimate_parasitics -placement

# Resize
repair_timing -setup \
    -setup_margin $::env(PL_RESIZER_SETUP_SLACK_MARGIN) \
    -max_buffer_percent $::env(PL_RESIZER_SETUP_MAX_BUFFER_PERCENT)

set arg_list [list]
lappend arg_list -hold
lappend arg_list -setup_margin $::env(PL_RESIZER_SETUP_SLACK_MARGIN)
lappend arg_list -hold_margin $::env(PL_RESIZER_HOLD_SLACK_MARGIN)
lappend arg_list -max_buffer_percent $::env(PL_RESIZER_HOLD_MAX_BUFFER_PERCENT)
if { $::env(PL_RESIZER_ALLOW_SETUP_VIOS) == 1 } {
    lappend arg_list -allow_setup_violations
}
repair_timing {*}$arg_list

source $::env(SCRIPTS_DIR)/openroad/dpl_cell_pad.tcl

detailed_placement
if { [info exists ::env(PL_OPTIMIZE_MIRRORING)] && $::env(PL_OPTIMIZE_MIRRORING) } {
    optimize_mirroring
}

if { [catch {check_placement -verbose} errmsg] } {
    puts stderr $errmsg
    exit 1
}

write_def $::env(SAVE_DEF)
write_sdc $::env(SAVE_SDC)

# Run post timing optimizations STA
estimate_parasitics -placement
set ::env(RUN_STANDALONE) 0
source $::env(SCRIPTS_DIR)/openroad/sta.tcl

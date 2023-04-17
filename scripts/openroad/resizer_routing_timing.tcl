# Copyright 2020-2022 Efabless Corporation
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
source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
read -override_libs "$::env(RSZ_LIB)"

set_propagated_clock [all_clocks]

# set don't touch nets
source $::env(SCRIPTS_DIR)/openroad/common/resizer.tcl
set_dont_touch_rx "$::env(RSZ_DONT_TOUCH_RX)"

# set don't use cells
if { [info exists ::env(DONT_USE_CELLS)] } {
    set_dont_use $::env(DONT_USE_CELLS)
}

source $::env(SCRIPTS_DIR)/openroad/common/set_routing_layers.tcl

source $::env(SCRIPTS_DIR)/openroad/common/set_layer_adjustments.tcl

set arg_list [list]
lappend arg_list -congestion_iterations $::env(GRT_OVERFLOW_ITERS)
lappend arg_list -verbose
if { $::env(GRT_ALLOW_CONGESTION) == 1 } {
    lappend arg_list -allow_congestion
}
puts $arg_list
global_route {*}$arg_list

# set rc values
source $::env(SCRIPTS_DIR)/openroad/common/set_rc.tcl

# estimate wire rc parasitics
estimate_parasitics -global_routing

# Resize
repair_timing -setup \
    -setup_margin $::env(GLB_RESIZER_SETUP_SLACK_MARGIN) \
    -max_buffer_percent $::env(GLB_RESIZER_SETUP_MAX_BUFFER_PERCENT)

set arg_list [list]
lappend arg_list -hold
lappend arg_list -setup_margin $::env(GLB_RESIZER_SETUP_SLACK_MARGIN)
lappend arg_list -hold_margin $::env(GLB_RESIZER_HOLD_SLACK_MARGIN)
lappend arg_list -max_buffer_percent $::env(GLB_RESIZER_HOLD_MAX_BUFFER_PERCENT)
if { $::env(GLB_RESIZER_ALLOW_SETUP_VIOS) == 1 } {
    lappend arg_list -allow_setup_violations
}
repair_timing {*}$arg_list

source $::env(SCRIPTS_DIR)/openroad/common/dpl_cell_pad.tcl

detailed_placement

if { $::env(GLB_OPTIMIZE_MIRRORING) } {
    optimize_mirroring
}

if { [catch {check_placement -verbose} errmsg] } {
    puts stderr $errmsg
    exit 1
}

unset_dont_touch_rx "$::env(RSZ_DONT_TOUCH_RX)"

write

# Run post timing optimizations STA
estimate_parasitics -global_routing

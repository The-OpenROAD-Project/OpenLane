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
read

set_propagated_clock [all_clocks]

if { $::env(GRT_REPAIR_ANTENNAS) } {
    set_placement_padding -masters $::env(DIODE_CELL) -left $::env(DIODE_PADDING)
}

source $::env(SCRIPTS_DIR)/openroad/common/set_routing_layers.tcl

set_macro_extension $::env(GRT_MACRO_EXTENSION)

source $::env(SCRIPTS_DIR)/openroad/common/set_layer_adjustments.tcl

set arg_list [list]
lappend arg_list -congestion_iterations $::env(GRT_OVERFLOW_ITERS)
lappend arg_list -verbose
lappend arg_list -congestion_report_file $::env(GRT_CONGESTION_REPORT_FILE)
if { $::env(GRT_ALLOW_CONGESTION) == 1 } {
    lappend arg_list -allow_congestion
}
puts $arg_list
global_route {*}$arg_list

if { $::env(GRT_REPAIR_ANTENNAS) } {
    repair_antennas "$::env(DIODE_CELL)" -iterations $::env(GRT_ANT_ITERS) -ratio_margin $::env(GRT_ANT_MARGIN)
    check_placement
}

write

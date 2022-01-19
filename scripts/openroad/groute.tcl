# Copyright 2020-2021 Efabless Corporation
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

if { [info exists ::env(EXTRA_LIBS) ] } {
	foreach lib $::env(EXTRA_LIBS) {
		read_liberty $lib
	}
}

foreach lib $::env(LIB_SYNTH_COMPLETE) {
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

read_sdc -echo $::env(CURRENT_SDC)

if { $::env(DIODE_INSERTION_STRATEGY) == 3 } {
	set_placement_padding -masters $::env(DIODE_CELL) -left $::env(DIODE_PADDING)
}

set signal_min_layer $::env(RT_MIN_LAYER)
set signal_max_layer $::env(RT_MAX_LAYER)
set clock_min_layer $::env(RT_MIN_LAYER)
set clock_max_layer $::env(RT_MAX_LAYER)

if { [info exists ::env(RT_CLOCK_MIN_LAYER)]} {
    set clock_min_layer $::env(RT_CLOCK_MIN_LAYER)
}
if { [info exists ::env(RT_CLOCK_MAX_LAYER)]} {
    set clock_max_layer $::env(RT_CLOCK_MAX_LAYER)
}

puts "\[INFO]: Setting signal min routing layer to: $signal_min_layer and clock min routing layer to $clock_min_layer. "
puts "\[INFO]: Setting signal max routing layer to: $signal_max_layer and clock max routing layer to $clock_max_layer. "

set_routing_layers -signal [subst $signal_min_layer]-[subst $signal_max_layer] -clock [subst $clock_min_layer]-[subst $clock_max_layer]

set_macro_extension $::env(GLB_RT_MACRO_EXTENSION)

source $::env(SCRIPTS_DIR)/openroad/layer_adjustments.tcl

set arg_list [list]
lappend arg_list -congestion_iterations $::env(GLB_RT_OVERFLOW_ITERS)
lappend arg_list -verbose
if { $::env(GLB_RT_ALLOW_CONGESTION) == 1 } {
    lappend arg_list -allow_congestion
}
puts $arg_list
global_route {*}$arg_list

if { $::env(DIODE_INSERTION_STRATEGY) == 3 } {
    repair_antennas "$::env(DIODE_CELL)/$::env(DIODE_CELL_PIN)" -iterations $::env(GLB_RT_ANT_ITERS)
	check_placement
}


write_guides $::env(SAVE_GUIDE)
write_def $::env(SAVE_DEF)

if {[info exists ::env(CLOCK_PORT)]} {
    if { $::env(GLB_RT_ESTIMATE_PARASITICS) == 1 } {
        # set rc values
        source $::env(SCRIPTS_DIR)/openroad/set_rc.tcl 
        set_propagated_clock [all_clocks]
        # estimate wire rc parasitics
        estimate_parasitics -global_routing

        set ::env(RUN_STANDALONE) 0
        source $::env(SCRIPTS_DIR)/openroad/sta.tcl 
    }
} else {
    puts "\[WARN\]: No CLOCK_PORT found. Skipping STA..."
}

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

if {[catch {read_lef $::env(MERGED_LEF_UNPADDED)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

read_sdc -echo $::env(CURRENT_SDC)

if { [info exists ::env(DONT_USE_CELLS)] } {
    set_dont_use $::env(DONT_USE_CELLS)
}

set signal_min_layer [lindex $::env(TECH_METAL_LAYERS) [expr {$::env(GLB_RT_MINLAYER)-1}]]
set signal_max_layer [lindex $::env(TECH_METAL_LAYERS) [expr {$::env(GLB_RT_MAXLAYER)-1}]]

if { ![info exists ::env(CLB_RT_CLOCK_MIN_LAYER)] } {
    set clock_min_layer $signal_min_layer
} else {
    set clock_min_layer [lindex $::env(TECH_METAL_LAYERS) [expr {$::env(GLB_RT_CLOCK_MINLAYER)-1}]]
}

if { ![info exists ::env(CLB_RT_CLOCK_MAX_LAYER)] } {
    set clock_max_layer $signal_max_layer
} else {
    set clock_max_layer [lindex $::env(TECH_METAL_LAYERS) [expr {$::env(GLB_RT_CLOCK_MAXLAYER)-1}]]
}

puts "\[INFO]: Setting singal min routig layer to: $signal_min_layer and clock min routing layer to $clock_min_layer. "
puts "\[INFO]: Setting signal max routig layer to: $signal_max_layer and clock min routing layer to $clock_max_layer.  "

set_routing_layers -signal [subst $signal_min_layer]-[subst $signal_max_layer] -clock [subst $clock_min_layer]-[subst $clock_max_layer]

grt::set_capacity_adjustment $::env(GLB_RT_ADJUSTMENT)

grt::add_layer_adjustment 1 $::env(GLB_RT_L1_ADJUSTMENT)
grt::add_layer_adjustment 2 $::env(GLB_RT_L2_ADJUSTMENT)
grt::add_layer_adjustment 3 $::env(GLB_RT_L3_ADJUSTMENT)
if { $::env(GLB_RT_MAXLAYER) > 3 } {
    grt::add_layer_adjustment 4 $::env(GLB_RT_L4_ADJUSTMENT)
    if { $::env(GLB_RT_MAXLAYER) > 4 } {
        grt::add_layer_adjustment 5 $::env(GLB_RT_L5_ADJUSTMENT)
        if { $::env(GLB_RT_MAXLAYER) > 5 } {
            grt::add_layer_adjustment 6 $::env(GLB_RT_L6_ADJUSTMENT)
        }
    }
}

if { $::env(GLB_RT_ALLOW_CONGESTION) == 1 } {
    global_route -verbose 3\
        -congestion_iterations $::env(GLB_RT_OVERFLOW_ITERS)\
        -allow_congestion
} else {
    global_route -verbose 3 \
    -congestion_iterations $::env(GLB_RT_OVERFLOW_ITERS)
}

# set rc values
source $::env(SCRIPTS_DIR)/openroad/or_set_rc.tcl 

set_propagated_clock [all_clocks]

# estimate wire rc parasitics
estimate_parasitics -global_routing


# Resize
if { $::env(GLB_RESIZER_ALLOW_SETUP_VIOS) == 1} {
    if { [catch {repair_timing -hold -allow_setup_violations \
            -slack_margin $::env(GLB_RESIZER_HOLD_SLACK_MARGIN) \
            -max_buffer_percent $::env(GLB_RESIZER_HOLD_MAX_BUFFER_PERCENT)}
    ]} {
        puts "Hold utilization limit is reached. Continuing the flow... "
    }
} else {
    if { [catch {repair_timing -hold \
            -slack_margin $::env(GLB_RESIZER_HOLD_SLACK_MARGIN) \
            -max_buffer_percent $::env(GLB_RESIZER_HOLD_MAX_BUFFER_PERCENT)}
    ]} {
        puts "Hold utilization limit is reached. Continuing the flow... "
    }
}

if { [catch {repair_timing -setup \
        -slack_margin $::env(GLB_RESIZER_SETUP_SLACK_MARGIN) \
        -max_buffer_percent $::env(GLB_RESIZER_SETUP_MAX_BUFFER_PERCENT)}
]} {
    puts "Setup utilization limit is reached. Continuing the flow... "
}

# set_placement_padding -global -right $::env(CELL_PAD)
# set_placement_padding -masters $::env(CELL_PAD_EXCLUDE) -right 0 -left 0

detailed_placement

if { [info exists ::env(GLB_OPTIMIZE_MIRRORING)] && $::env(GLB_OPTIMIZE_MIRRORING) } {
    optimize_mirroring
}

check_placement -verbose

write_def $::env(SAVE_DEF)
write_sdc $::env(SAVE_SDC)

# Run post timing optimizations STA
estimate_parasitics -global_routing
set ::env(RUN_STANDALONE) 0
source $::env(SCRIPTS_DIR)/openroad/or_sta.tcl 

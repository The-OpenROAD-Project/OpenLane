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

if { $::env(DIODE_INSERTION_STRATEGY) == 3 } {
	set_placement_padding -masters $::env(DIODE_CELL) -left $::env(DIODE_PADDING)
}

grt::check_routing_layer $::env(GLB_RT_MINLAYER)
grt::set_min_layer $::env(GLB_RT_MINLAYER)

grt::check_routing_layer $::env(GLB_RT_MAXLAYER)
grt::set_max_layer $::env(GLB_RT_MAXLAYER)

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

if { $::env(DIODE_INSERTION_STRATEGY) == 3 } {
    repair_antennas "$::env(DIODE_CELL)/$::env(DIODE_CELL_PIN)" -iterations $::env(GLB_RT_ANT_ITERS)
	check_placement
}


write_guides $::env(SAVE_GUIDE)
write_def $::env(SAVE_DEF)

if {[info exists ::env(CLOCK_PORT)]} {
    if { $::env(GLB_RT_ESTIMATE_PARASITICS) == 1 } {
        read_sdc -echo $::env(CURRENT_SDC)
	
        # set rc values
        source $::env(SCRIPTS_DIR)/openroad/or_set_rc.tcl 
        set_wire_rc -layer $::env(WIRE_RC_LAYER)
        set_propagated_clock [all_clocks]
        estimate_parasitics -global_routing

        set ::env(RUN_STANDALONE) 0
        source $::env(SCRIPTS_DIR)/openroad/or_sta.tcl 
    }
} else {
    puts "\[WARN\]: No CLOCK_PORT found. Skipping STA..."
}

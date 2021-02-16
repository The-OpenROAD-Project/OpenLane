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

if {[catch {read_lef $::env(MERGED_LEF_UNPADDED)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}


set ::block [[[::ord::get_db] getChip] getBlock]
set ::insts [$::block getInsts]

set free_insts_flag 0

foreach inst $::insts {
	set placement_status [$inst getPlacementStatus]
	if { $placement_status != "FIRM" } {
		set free_insts_flag 1
		break
	}
}

if { ! $free_insts_flag } {
	puts "\[WARN] All instances are FIXED"
	puts "\[WARN] No need to use replace"
	puts "\[WARN] Skipping..."
	file copy -force $::env(CURRENT_DEF) $::env(SAVE_DEF)
	exit 0
}

set_replace_verbose_level_cmd 1

set_replace_density_cmd $::env(PL_TARGET_DENSITY)

if { $::env(PL_BASIC_PLACEMENT) } {
	set_replace_overflow_cmd 0.9
	set_replace_init_density_penalty_factor_cmd 0.0001
	set_replace_initial_place_max_iter_cmd 20
	set_replace_bin_grid_cnt_x_cmd 64
	set_replace_bin_grid_cnt_y_cmd 64
}

if { $::env(PL_TIME_DRIVEN) } {
	read_lib $::env(LIB_SYNTH)
	read_sdc $::env(SCRIPTS_DIR)/base.sdc
	read_verilog $::env(yosys_result_file_tag).v
} else {
	set_replace_disable_timing_driven_mode_cmd
}

if { !$::env(PL_ROUTABILITY_DRIVEN) } {
	set_replace_disable_routability_driven_mode_cmd
} else {
	grt::set_capacity_adjustment $::env(GLB_RT_ADJUSTMENT)
	grt::set_max_layer $::env(GLB_RT_MAXLAYER)
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
	grt::set_unidirectional_routing $::env(GLB_RT_UNIDIRECTIONAL)
	grt::set_overflow_iterations 150
	set_replace_routability_max_density_cmd [expr $::env(PL_TARGET_DENSITY) + 0.1]
	set_replace_routability_max_inflation_iter_cmd 10
}

if { !$::env(PL_SKIP_INITIAL_PLACEMENT) || $::env(PL_BASIC_PLACEMENT) } {
    replace_initial_place_cmd
}

replace_nesterov_place_cmd

replace_reset_cmd

write_def $::env(SAVE_DEF)

if {[info exists ::env(CLOCK_PORT)]} {
	if { $::env(PL_ESTIMATE_PARASITICS) == 1 } {

		read_liberty -max $::env(LIB_SLOWEST)
		read_liberty -min $::env(LIB_FASTEST)
		read_sdc -echo $::env(BASE_SDC_FILE)

		set_wire_rc -layer $::env(WIRE_RC_LAYER)
		estimate_parasitics -placement

		report_checks -fields {capacitance slew input_pins nets fanout} -unique -slack_max -0.0 -group_count 100 > $::env(replaceio_report_file_tag).timing.rpt
		report_checks -fields {capacitance slew input_pins nets fanout} -path_delay min_max > $::env(replaceio_report_file_tag).min_max.rpt
		report_checks -fields {capacitance slew input_pins nets fanout} -group_count 100  -slack_max -0.01 > $::env(replaceio_report_file_tag).rpt

		report_wns > $::env(replaceio_report_file_tag)_wns.rpt
		report_tns > $::env(replaceio_report_file_tag)_tns.rpt
	}
} else {
    puts "\[WARN\]: No CLOCK_PORT found. Skipping STA..."
}

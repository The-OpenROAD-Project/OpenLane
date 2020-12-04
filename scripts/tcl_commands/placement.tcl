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

proc global_placement {args} {
    puts_info "Running Global Placement..."
    TIMER::timer_start
    try_catch replace < $::env(SCRIPTS_DIR)/replace_gp.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(replaceio_log_file_tag).log

    try_catch cp $::env(replaceio_tmp_file_tag)_place.def $::env(replaceio_tmp_file_tag).def
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> $::env(replaceio_log_file_tag)_runtime.txt
    set_def $::env(replaceio_tmp_file_tag).def
}

proc global_placement_or {args} {
    puts_info "Running Global Placement..."
    TIMER::timer_start
    set ::env(SAVE_DEF) $::env(replaceio_tmp_file_tag).def
    try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_replace.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(replaceio_log_file_tag).log
    # sometimes replace fails with a ZERO exit code; the following is a workaround
    # until the cause is found and fixed
    if { ! [file exists $::env(SAVE_DEF)] } {
        puts_err "Failure in global placement"
        return -code error
    }

    check_replace_divergence

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> $::env(replaceio_log_file_tag)_runtime.txt
    set_def $::env(SAVE_DEF)
}

proc random_global_placement {args} {
    puts_warn "Performing Random Global Placement..."
    TIMER::timer_start
    set ::env(SAVE_DEF) $::env(replaceio_tmp_file_tag).def

    try_catch python3 $::env(SCRIPTS_DIR)/random_place.py --lef $::env(MERGED_LEF_UNPADDED) \
        --input-def $::env(CURRENT_DEF) --output-def $::env(SAVE_DEF) \
        |& tee $::env(TERMINAL_OUTPUT) $::env(replaceio_log_file_tag).log

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> $::env(replaceio_log_file_tag)_runtime.txt
    set_def $::env(SAVE_DEF)
}

proc detailed_placement {args} {
    puts_info "Running Detailed Placement..."
    TIMER::timer_start
    try_catch opendp \
	-lef $::env(MERGED_LEF) \
	-def $::env(CURRENT_DEF) \
	-output_def $::env(opendp_result_file_tag).def \
	|& tee $::env(TERMINAL_OUTPUT) $::env(opendp_log_file_tag).log
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> $::env(opendp_log_file_tag)_runtime.txt
    set_def $::env(opendp_result_file_tag).def
}

proc add_macro_placement {args} {
    puts_info " Adding Macro Placement..."
    set ori "NONE"
    if { [llength $args] == 4 } {
	set ori [lindex $args 3]
    }
    try_catch echo [lindex $args 0] [lindex $args 1] [lindex $args 2] $ori >> $::env(TMP_DIR)/macro_placement.cfg
}

proc manual_macro_placement {args} {
    puts_info " Manual Macro Placement..."
    set var "f"
    if { [string compare [lindex $args 0] $var] == 0 } {
        try_catch python3 $::env(SCRIPTS_DIR)/manual_macro_place.py -l $::env(MERGED_LEF) -id $::env(CURRENT_DEF) -o $::env(CURRENT_DEF).macro_placement.def -c $::env(TMP_DIR)/macro_placement.cfg -f |& tee $::env(TERMINAL_OUTPUT) $::env(LOG_DIR)/macro_placement.log
    } else {
        try_catch python3 $::env(SCRIPTS_DIR)/manual_macro_place.py -l $::env(MERGED_LEF) -id $::env(CURRENT_DEF) -o $::env(CURRENT_DEF).macro_placement.def -c $::env(TMP_DIR)/macro_placement.cfg |& tee $::env(TERMINAL_OUTPUT) $::env(LOG_DIR)/macro_placement.log
    }
    set_def $::env(CURRENT_DEF).macro_placement.def
}

proc detailed_placement_or {args} {
    puts_info "Running Detailed Placement..."
    TIMER::timer_start
    set ::env(SAVE_DEF) $::env(opendp_result_file_tag).def

    try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_opendp.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(opendp_log_file_tag).log
    set_def $::env(SAVE_DEF)

    if {[catch {exec grep -q -i "fail" $::env(opendp_log_file_tag).log}] == 0}  {
	puts_info "Error in detailed placement"
	puts_info "Retrying detailed placement"
	set ::env(SAVE_DEF) $::env(opendp_result_file_tag).1.def

	try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_opendp.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(opendp_log_file_tag).log

    }

    if {[catch {exec grep -q -i "fail" $::env(opendp_log_file_tag).log}] == 0}  {
	puts "Error: Check $::env(opendp_log_file_tag).log"
	puts stderr "\[ERROR\]: Check $::env(opendp_log_file_tag).log"
	exit 1
    }



    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> $::env(opendp_log_file_tag)_runtime.txt
    set_def $::env(SAVE_DEF)
}

proc basic_macro_placement {args} {
    puts_info "Running Basic Macro Placement"
    TIMER::timer_start
    set ::env(SAVE_DEF) $::env(CURRENT_DEF).macro_placement.def

    try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_basic_mp.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(LOG_DIR)/placement/basic_mp.log

    check_macro_placer_num_solns


    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> $::env(LOG_DIR)/placement/basic_mp_runtime.txt
    set_def $::env(SAVE_DEF)
}

proc run_placement {args} {
	puts_info "Running Placement..."
# |----------------------------------------------------|
# |----------------   3. PLACEMENT   ------------------|
# |----------------------------------------------------|
	set ::env(CURRENT_STAGE) placement

    if { [info exists ::env(PL_TARGET_DENSITY_CELLS)] } {
        set old_pl_target_density $::env(PL_TARGET_DENSITY)
        set ::env(PL_TARGET_DENSITY) $::env(PL_TARGET_DENSITY_CELLS)
    }

    if { $::env(PL_RANDOM_GLB_PLACEMENT) } {
        # useful for very tiny designs
        random_global_placement
    } else {
        global_placement_or
    }

    if { [info exists ::env(PL_TARGET_DENSITY_CELLS)] } {
        set ::env(PL_TARGET_DENSITY) $old_pl_target_density
    }

    if { $::env(PL_RESIZER_OVERBUFFER) == 1} {
		repair_wire_length
	}
	if { $::env(PL_OPENPHYSYN_OPTIMIZATIONS) == 1} {
	    run_openPhySyn
    }

	detailed_placement_or
}

proc repair_wire_length {args} {
    puts_info "Repairing Wire Length By Inserting Buffers..."
    set ::env(SAVE_DEF) $::env(CURRENT_DEF)
    try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_wireLengthRepair.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(LOG_DIR)/placement/resizer.log
    set_def $::env(SAVE_DEF)
}

proc run_openPhySyn {args} {
    puts_info "Running OpenPhySyn Timing Optimization..."
    TIMER::timer_start
    set ::env(LIB_OPT) $::env(TMP_DIR)/opt.lib
    trim_lib -input $::env(LIB_SLOWEST) -output $::env(LIB_OPT)

    set ::env(SAVE_DEF) $::env(openphysyn_tmp_file_tag).def
    try_catch Psn $::env(SCRIPTS_DIR)/openPhySyn.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(openphysyn_log_file_tag).log
	set_def $::env(SAVE_DEF)

    write_verilog $::env(yosys_result_file_tag)_optimized.v
    set_netlist $::env(yosys_result_file_tag)_optimized.v
    set report_tag_holder $::env(opensta_report_file_tag)
    set log_tag_holder $::env(opensta_log_file_tag)
    set ::env(opensta_report_file_tag) $::env(opensta_report_file_tag)_post_openphysyn
    set ::env(opensta_log_file_tag) $::env(opensta_log_file_tag)_post_openphysyn
    run_sta
    set ::env(opensta_report_file_tag) $report_tag_holder
    set ::env(opensta_log_file_tag) $log_tag_holder

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> $::env(openphysyn_log_file_tag)_runtime.txt

}

package provide openlane 0.9

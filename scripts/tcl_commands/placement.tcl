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
    try_catch replace < $::env(SCRIPTS_DIR)/replace_gp.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(replaceio_log_file_tag).log]
    try_catch cp $::env(replaceio_tmp_file_tag)_place.def $::env(replaceio_tmp_file_tag).def
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> [index_file $::env(replaceio_log_file_tag)_runtime.txt 0]
    set_def $::env(replaceio_tmp_file_tag).def
}

proc global_placement_or {args} {
    puts_info "Running Global Placement..."
    TIMER::timer_start
    set ::env(SAVE_DEF) [index_file $::env(replaceio_tmp_file_tag).def]

    # random initial placement
    if { $::env(PL_RANDOM_INITIAL_PLACEMENT) } {
        random_global_placement
        set ::env(PL_SKIP_INITIAL_PLACEMENT) 1
    }

    set report_tag_saver $::env(replaceio_report_file_tag)
    set ::env(replaceio_report_file_tag) [index_file $::env(replaceio_report_file_tag) 0]
    try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_replace.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(replaceio_log_file_tag).log 0]
    set ::env(replaceio_report_file_tag) $report_tag_saver
    # sometimes replace fails with a ZERO exit code; the following is a workaround
    # until the cause is found and fixed
    if { ! [file exists $::env(SAVE_DEF)] } {
        puts_err "Failure in global placement"
        return -code error
    }

    check_replace_divergence

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> [index_file $::env(replaceio_log_file_tag)_runtime.txt 0]
    set_def $::env(SAVE_DEF)
}

proc random_global_placement {args} {
    puts_warn "Performing Random Global Placement..."
    TIMER::timer_start
    set ::env(SAVE_DEF) [index_file $::env(replaceio_tmp_file_tag).def]

    try_catch python3 $::env(SCRIPTS_DIR)/random_place.py --lef $::env(MERGED_LEF_UNPADDED) \
        --input-def $::env(CURRENT_DEF) --output-def $::env(SAVE_DEF) \
        |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(replaceio_log_file_tag).log 0]

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> [index_file $::env(replaceio_log_file_tag)_runtime.txt 0]
    set_def $::env(SAVE_DEF)
}

proc detailed_placement {args} {
    puts_info "Running Detailed Placement..."
    TIMER::timer_start
    try_catch opendp \
	-lef $::env(MERGED_LEF) \
	-def $::env(CURRENT_DEF) \
	-output_def $::env(opendp_result_file_tag).def \
	|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(opendp_log_file_tag).log]

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> [index_file $::env(opendp_log_file_tag)_runtime.txt 0]
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
    set fbasename [file rootname $::env(CURRENT_DEF)]
    if { [string compare [lindex $args 0] $var] == 0 } {
        try_catch python3 $::env(SCRIPTS_DIR)/manual_macro_place.py -l $::env(MERGED_LEF) -id $::env(CURRENT_DEF) -o ${fbasename}.macro_placement.def -c $::env(TMP_DIR)/macro_placement.cfg -f |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(LOG_DIR)/macro_placement.log]
    } else {
        try_catch python3 $::env(SCRIPTS_DIR)/manual_macro_place.py -l $::env(MERGED_LEF) -id $::env(CURRENT_DEF) -o ${fbasename}.macro_placement.def -c $::env(TMP_DIR)/macro_placement.cfg |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(LOG_DIR)/macro_placement.log]
    }
    set_def ${fbasename}.macro_placement.def
}

proc detailed_placement_or {args} {
    puts_info "Running Detailed Placement..."
    TIMER::timer_start
    set ::env(SAVE_DEF) $::env(opendp_result_file_tag).def

    try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_opendp.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(opendp_log_file_tag).log]
    set_def $::env(SAVE_DEF)

    if {[catch {exec grep -q -i "fail" [index_file $::env(opendp_log_file_tag).log 0]}] == 0}  {
	puts_info "Error in detailed placement"
	puts_info "Retrying detailed placement"
	set ::env(SAVE_DEF) $::env(opendp_result_file_tag).1.def

	try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_opendp.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(opendp_log_file_tag).log]
    }

    if {[catch {exec grep -q -i "fail" [index_file $::env(opendp_log_file_tag).log 0]}] == 0}  {
	puts "Error: Check [index_file $::env(opendp_log_file_tag).log 0]"
	puts stderr "\[ERROR\]: Check [index_file $::env(opendp_log_file_tag).log 0]"
	exit 1
    }



    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> [index_file $::env(opendp_log_file_tag)_runtime.txt 0]
    set_def $::env(SAVE_DEF)
}

proc basic_macro_placement {args} {
    puts_info "Running Basic Macro Placement"
    TIMER::timer_start
    set fbasename [file rootname $::env(CURRENT_DEF)]
    set ::env(SAVE_DEF) ${fbasename}.macro_placement.def

    try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_basic_mp.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(LOG_DIR)/placement/basic_mp.log]

    check_macro_placer_num_solns


    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> [index_file $::env(LOG_DIR)/placement/basic_mp_runtime.txt 0]
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

    run_openPhySyn
    run_resizer_design
    detailed_placement_or
    scrot_klayout -layout $::env(CURRENT_DEF)
}

proc run_openPhySyn {args} {
    if { $::env(PL_OPENPHYSYN_OPTIMIZATIONS) == 1} {
        puts_info "Running OpenPhySyn Timing Optimizations..."
        TIMER::timer_start
        if { ! [info exists ::env(LIB_OPT)]} {
            set ::env(LIB_OPT) $::env(TMP_DIR)/opt.lib
            trim_lib -input $::env(LIB_SLOWEST) -output $::env(LIB_OPT) -drc_exclude_only
        }
        set report_tag_saver $::env(openphysyn_report_file_tag)
        set ::env(openphysyn_report_file_tag) [index_file $::env(openphysyn_report_file_tag)]

        set ::env(SAVE_DEF) [index_file $::env(openphysyn_tmp_file_tag).def 0]
        try_catch Psn $::env(SCRIPTS_DIR)/openPhySyn.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(openphysyn_log_file_tag).log 0]
        set_def $::env(SAVE_DEF)
        set ::env(openphysyn_report_file_tag) $report_tag_saver

        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" >> [index_file $::env(openphysyn_log_file_tag)_runtime.txt 0]

        write_verilog $::env(yosys_result_file_tag)_optimized.v
        set_netlist $::env(yosys_result_file_tag)_optimized.v

        if { $::env(LEC_ENABLE) && [file exists $::env(PREV_NETLIST)] } {
            logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
        }

        set report_tag_holder $::env(opensta_report_file_tag)
        set log_tag_holder $::env(opensta_log_file_tag)
        set ::env(opensta_report_file_tag) $::env(opensta_report_file_tag)_post_openphysyn
        set ::env(opensta_log_file_tag) $::env(opensta_log_file_tag)_post_openphysyn
        run_sta
        set ::env(opensta_report_file_tag) $report_tag_holder
        set ::env(opensta_log_file_tag) $log_tag_holder

    } else {
        puts_info "Skipping OpenPhySyn Timing Optimizations."
    }
}


proc run_resizer_timing {args} {
    if { $::env(PL_RESIZER_TIMING_OPTIMIZATIONS) == 1} {
        puts_info "Running Resizer Timing Optimizations..."
        TIMER::timer_start
        if { ! [info exists ::env(LIB_RESIZER_OPT) ] } {
            set ::env(LIB_RESIZER_OPT) $::env(TMP_DIR)/resizer.lib
            file copy -force $::env(LIB_SLOWEST) $::env(LIB_RESIZER_OPT)
        }
        if { ! [info exists ::env(DONT_USE_CELLS)] } {
            gen_exclude_list -lib $::env(LIB_RESIZER_OPT) -drc_exclude_only -create_dont_use_list
        }
        set ::env(SAVE_DEF) [index_file $::env(resizer_tmp_file_tag)_timing.def 0]
        try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_resizer_timing.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(resizer_log_file_tag)_timing.log 0]
        set_def $::env(SAVE_DEF)

        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" >> [index_file $::env(resizer_log_file_tag)_timing_runtime.txt 0]

        write_verilog $::env(yosys_result_file_tag)_optimized.v
        set_netlist $::env(yosys_result_file_tag)_optimized.v

        if { $::env(LEC_ENABLE) && [file exists $::env(PREV_NETLIST)] } {
            logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
        }

        set report_tag_holder $::env(opensta_report_file_tag)
        set log_tag_holder $::env(opensta_log_file_tag)
        set ::env(opensta_report_file_tag) $::env(opensta_report_file_tag)_post_resizer_timing
        set ::env(opensta_log_file_tag) $::env(opensta_log_file_tag)_post_resizer_timing
        run_sta
        set ::env(opensta_report_file_tag) $report_tag_holder
        set ::env(opensta_log_file_tag) $log_tag_holder
    } else {
        puts_info "Skipping Resizer Timing Optimizations."
    }
}


proc run_resizer_design {args} {
    if { $::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) == 1} {
        puts_info "Running Resizer Design Optimizations..."
        TIMER::timer_start
        if { ! [info exists ::env(LIB_RESIZER_OPT) ] } {
            set ::env(LIB_RESIZER_OPT) $::env(TMP_DIR)/resizer.lib
            file copy -force $::env(LIB_SLOWEST) $::env(LIB_RESIZER_OPT)
        }
        if { ! [info exists ::env(DONT_USE_CELLS)] } {
            gen_exclude_list -lib $::env(LIB_RESIZER_OPT) -drc_exclude_only -create_dont_use_list
        }
        set ::env(SAVE_DEF) [index_file $::env(resizer_tmp_file_tag).def 0]
        try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_resizer.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(resizer_log_file_tag).log 0]
        set_def $::env(SAVE_DEF)

        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" >> [index_file $::env(resizer_log_file_tag)_runtime.txt 0]

        write_verilog $::env(yosys_result_file_tag)_optimized.v
        set_netlist $::env(yosys_result_file_tag)_optimized.v

        if { $::env(LEC_ENABLE) && [file exists $::env(PREV_NETLIST)] } {
            logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
        }

        set report_tag_holder $::env(opensta_report_file_tag)
        set log_tag_holder $::env(opensta_log_file_tag)
        set ::env(opensta_report_file_tag) $::env(opensta_report_file_tag)_post_resizer
        set ::env(opensta_log_file_tag) $::env(opensta_log_file_tag)_post_resizer
        run_sta
        set ::env(opensta_report_file_tag) $report_tag_holder
        set ::env(opensta_log_file_tag) $log_tag_holder
    } else {
        puts_info "Skipping Resizer Timing Optimizations."
    }
}
package provide openlane 0.9

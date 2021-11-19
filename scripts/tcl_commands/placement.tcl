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

proc global_placement_or {args} {
    puts_info "Running Global Placement..."
    TIMER::timer_start
    set ::env(SAVE_DEF) [index_file $::env(placement_tmpfiles)/global.def]

    # random initial placement
    if { $::env(PL_RANDOM_INITIAL_PLACEMENT) } {
        random_global_placement
        set ::env(PL_SKIP_INITIAL_PLACEMENT) 1
    }
    
    try_catch $::env(OPENROAD_BIN) -exit $::env(SCRIPTS_DIR)/openroad/replace.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(placement_logs)/global.log 0]
    # sometimes replace fails with a ZERO exit code; the following is a workaround
    # until the cause is found and fixed
    if { ! [file exists $::env(SAVE_DEF)] } {
        puts_err "Failure in global placement"
        return -code error
    }

    check_replace_divergence

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "global placement - openroad"
    set_def $::env(SAVE_DEF)
}

proc global_placement {args} {
    global_placement_or args
}


proc random_global_placement {args} {
    puts_warn "Performing Random Global Placement..."
    TIMER::timer_start
    set ::env(SAVE_DEF) [index_file $::env(placement_tmpfiles)/global.def]

    try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/random_place.py --lef $::env(MERGED_LEF_UNPADDED) \
        --input-def $::env(CURRENT_DEF) --output-def $::env(SAVE_DEF) \
        |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(placement_logs)/global.log 0]

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "global placement - random_place.py"
    set_def $::env(SAVE_DEF)
}

proc detailed_placement_or {args} {
    puts_info "Running Detailed Placement..."
    TIMER::timer_start
    set ::env(SAVE_DEF) $::env(routing_results)/$::env(DESIGN_NAME)_detailed.def

    try_catch $::env(OPENROAD_BIN) -exit $::env(SCRIPTS_DIR)/openroad/opendp.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(routing_logs)/detailed.log]
    set_def $::env(SAVE_DEF)

    if {[catch {exec grep -q -i "fail" [index_file $::env(routing_logs)/detailed.log 0]}] == 0}  {
        puts_info "Error in detailed placement"
        puts_info "Retrying detailed placement"
        set ::env(SAVE_DEF) $::env(routing_results)/$::env(DESIGN_NAME)_detailed.1.def

        try_catch $::env(OPENROAD_BIN) -exit $::env(SCRIPTS_DIR)/openroad/opendp.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(routing_logs)/detailed.log]
    }

    if {[catch {exec grep -q -i "fail" [index_file $::env(routing_logs)/detailed.log 0]}] == 0}  {
        puts "Error: Check [index_file $::env(routing_logs)/detailed.log 0]"
        puts stderr "\[ERROR\]: Check [index_file $::env(routing_logs)/detailed.log 0]"
        exit 1
    }

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "detailed placement - openroad"
    set_def $::env(SAVE_DEF)
}

proc detailed_placement {args} {
    detailed_placement_or args
}

proc add_macro_placement {args} {
    puts_info "Adding Macro Placement..."
    set ori "NONE"
    if { [llength $args] == 4 } {
	set ori [lindex $args 3]
    }
    try_catch echo [lindex $args 0] [lindex $args 1] [lindex $args 2] $ori >> $::env(placement_tmpfiles)/macro_placement.cfg
}

proc manual_macro_placement {args} {
    puts_info " Manual Macro Placement..."
    set var "f"
    set fbasename [file rootname $::env(CURRENT_DEF)]
    if { [string compare [lindex $args 0] $var] == 0 } {
        try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/manual_macro_place.py -l $::env(MERGED_LEF) -id $::env(CURRENT_DEF) -o ${fbasename}.macro_placement.def -c $::env(placement_tmpfiles)/macro_placement.cfg -f |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(placement_logs)/macro_placement.log]
    } else {
        try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/manual_macro_place.py -l $::env(MERGED_LEF) -id $::env(CURRENT_DEF) -o ${fbasename}.macro_placement.def -c $::env(placement_tmpfiles)/macro_placement.cfg |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(placement_logs)/macro_placement.log]
    }
    set_def ${fbasename}.macro_placement.def
}

proc basic_macro_placement {args} {
    puts_info "Running Basic Macro Placement"
    TIMER::timer_start
    set fbasename [file rootname $::env(CURRENT_DEF)]
    set ::env(SAVE_DEF) ${fbasename}.macro_placement.def

    try_catch $::env(OPENROAD_BIN) -exit $::env(SCRIPTS_DIR)/openroad/basic_mp.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(placement_logs)/basic_mp.log]

    check_macro_placer_num_solns


    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "macro placement - basic_mp.tcl"
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

    run_resizer_design

    if { [info exists ::env(DONT_BUFFER_PORTS) ]} {
        remove_buffers
    }
    detailed_placement_or
    scrot_klayout -layout $::env(CURRENT_DEF)
}

proc run_resizer_timing {args} {
    if { $::env(PL_RESIZER_TIMING_OPTIMIZATIONS) == 1} {
        puts_info "Running Resizer Timing Optimizations..."
        TIMER::timer_start
        set ::env(SAVE_DEF) [index_file $::env(placement_tmpfiles)/rsz_timing.def 0]
        set ::env(SAVE_SDC) [index_file $::env(placement_tmpfiles)/rsz_timing.sdc 0]
        try_catch $::env(OPENROAD_BIN) -exit $::env(SCRIPTS_DIR)/openroad/resizer_timing.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(placement_logs)/rsz_timing_optimization.log 0]
        set_def $::env(SAVE_DEF)
        set ::env(CURRENT_SDC) $::env(SAVE_SDC)

        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "resizer timing optimizations - openroad"

        write_verilog $::env(placement_results)/$::env(DESIGN_NAME)_rsz_optimized.v -log [index_file $::env(placement_logs)/write_verilog.log 0]
        set_netlist $::env(placement_results)/$::env(DESIGN_NAME)_rsz_optimized.v

        if { $::env(LEC_ENABLE) && [file exists $::env(PREV_NETLIST)] } {
            logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
        }

    } else {
        puts_info "Skipping Resizer Timing Optimizations."
    }
}


proc run_resizer_design {args} {
    if { $::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) == 1} {
        puts_info "Running Resizer Design Optimizations..."
        TIMER::timer_start
        set ::env(SAVE_DEF) [index_file $::env(placement_tmpfiles)/rsz.def 0]
        set ::env(SAVE_SDC) [index_file $::env(placement_tmpfiles)/rsz.sdc 0]
        try_catch $::env(OPENROAD_BIN) -exit $::env(SCRIPTS_DIR)/openroad/resizer.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(placement_logs)/rsz_design_optimization.log 0]
        set_def $::env(SAVE_DEF)
        set ::env(CURRENT_SDC) $::env(SAVE_SDC)

        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "resizer design optimizations - openroad"

        write_verilog $::env(placement_results)/$::env(DESIGN_NAME)_rsz_optimized.v -log [index_file $::env(placement_logs)/write_verilog.log 0]
        set_netlist $::env(placement_results)/$::env(DESIGN_NAME)_rsz_optimized.v

        if { $::env(LEC_ENABLE) && [file exists $::env(PREV_NETLIST)] } {
            logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
        }
    } else {
        puts_info "Skipping Resizer Design Optimizations."
    }
}

proc remove_buffers {args} {
    set fbasename [file rootname $::env(CURRENT_DEF)]
    set ::env(SAVE_DEF) ${fbasename}.remove_buffers.def
    try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/dont_buffer.py\
        --input_lef  $::env(MERGED_LEF)
        --input_def $::env(CURRENT_DEF)
        --dont_buffer $::env(DONT_BUFFER_PORTS)
        --output_def $::env(SAVE_DEF)
    |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(placement_logs)/remove_buffers.log 0]

    set_def $::env(SAVE_DEF)
}

package provide openlane 0.9

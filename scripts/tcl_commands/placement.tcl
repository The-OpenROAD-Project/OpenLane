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

proc global_placement_or {args} {
    increment_index
    TIMER::timer_start
    puts_info "Running Global Placement..."
    set ::env(SAVE_DEF) [index_file $::env(placement_tmpfiles)/global.def]

    # random initial placement
    if { $::env(PL_RANDOM_INITIAL_PLACEMENT) } {
        random_global_placement
        set ::env(PL_SKIP_INITIAL_PLACEMENT) 1
    }

    run_openroad_script $::env(SCRIPTS_DIR)/openroad/replace.tcl -indexed_log [index_file $::env(placement_logs)/global.log]
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
    increment_index
    TIMER::timer_start
    puts_info "Performing Random Global Placement..."
    set ::env(SAVE_DEF) [index_file $::env(placement_tmpfiles)/global.def]

    try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/random_place.py --lef $::env(MERGED_LEF_UNPADDED) \
        --input-def $::env(CURRENT_DEF) --output-def $::env(SAVE_DEF) \
        |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(placement_logs)/global.log]

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "global placement - random_place.py"
    set_def $::env(SAVE_DEF)
}

proc detailed_placement_or {args} {
    set options {
        {-log required}
        {-def required}
    }
    set flags {}
    parse_key_args "detailed_placement_or" args arg_values $options flags_map $flags

    increment_index
    TIMER::timer_start
    puts_info "Running Detailed Placement..."
    set ::env(SAVE_DEF) $arg_values(-def)
    set log [index_file $arg_values(-log)]

    run_openroad_script $::env(SCRIPTS_DIR)/openroad/opendp.tcl -indexed_log $log
    set_def $::env(SAVE_DEF)

    if {[catch {exec grep -q -i "fail" $log}] == 0}  {
        puts "Error: Check $log"
        puts stderr "\[ERROR\]: Check $log"
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
    increment_index
    puts_info "Performing Manual Macro Placement..."
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
    increment_index
    TIMER::timer_start
    puts_info "Running basic macro placement..."

    set fbasename [file rootname $::env(CURRENT_DEF)]
    set ::env(SAVE_DEF) ${fbasename}.macro_placement.def

    run_openroad_script $::env(SCRIPTS_DIR)/openroad/basic_mp.tcl -indexed_log [index_file $::env(placement_logs)/basic_mp.log]

    check_macro_placer_num_solns

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "macro placement - basic_mp.tcl"
    set_def $::env(SAVE_DEF)
}

proc run_placement {args} {
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

    detailed_placement_or -def $::env(placement_results)/$::env(DESIGN_NAME).def -log $::env(placement_logs)/detailed.log

    scrot_klayout -layout $::env(CURRENT_DEF) -log $::env(placement_logs)/screenshot.log
}

proc run_resizer_design {args} {
    if { $::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) == 1} {
        increment_index
        TIMER::timer_start
        puts_info "Running Placement Resizer Design Optimizations..."
        set ::env(SAVE_DEF) [index_file $::env(placement_tmpfiles)/resizer.def]
        set ::env(SAVE_SDC) [index_file $::env(placement_tmpfiles)/resizer.sdc]
        run_openroad_script $::env(SCRIPTS_DIR)/openroad/resizer.tcl -indexed_log [index_file $::env(placement_logs)/resizer.log]
        set_def $::env(SAVE_DEF)
        set ::env(CURRENT_SDC) $::env(SAVE_SDC)

        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "resizer design optimizations - openroad"

        write_verilog $::env(placement_results)/$::env(DESIGN_NAME).resized.v -log $::env(placement_logs)/write_verilog.log
        set_netlist $::env(placement_results)/$::env(DESIGN_NAME).resized.v

        if { $::env(LEC_ENABLE) && [file exists $::env(PREV_NETLIST)] } {
            logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
        }
    } else {
        puts_info "Skipping Placement Resizer Design Optimizations."
    }
}

proc remove_buffers {args} {
    increment_index
    puts_info "Removing buffers..."
    set fbasename [file rootname $::env(CURRENT_DEF)]
    set ::env(SAVE_DEF) ${fbasename}.remove_buffers.def
    try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/dont_buffer.py\
        --input_lef  $::env(MERGED_LEF)\
        --input_def $::env(CURRENT_DEF)\
        --dont_buffer $::env(DONT_BUFFER_PORTS)\
        --output_def $::env(SAVE_DEF)\
        |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(LOG_DIR)/placement/remove_buffers.log]

    set_def $::env(SAVE_DEF)
}

package provide openlane 0.9

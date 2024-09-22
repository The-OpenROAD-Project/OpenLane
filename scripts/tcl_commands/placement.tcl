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

proc global_placement_or {args} {
    increment_index
    TIMER::timer_start
    set log [index_file $::env(placement_logs)/global.log]
    puts_info "Running Global Placement (log: [relpath . $log])..."
    # random initial placement
    if { $::env(PL_RANDOM_INITIAL_PLACEMENT) } {
        random_global_placement
        set ::env(PL_SKIP_INITIAL_PLACEMENT) 1
    }

    run_openroad_script $::env(SCRIPTS_DIR)/openroad/gpl.tcl\
        -indexed_log [index_file $::env(placement_logs)/global.log]\
        -save "to=$::env(placement_tmpfiles),name=global,def,odb,netlist,powered_netlist"

    check_replace_divergence

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "global placement - openroad"

    run_sta -pre_cts -estimate_placement -no_save -log $::env(placement_logs)/gpl_sta.log
}

proc global_placement {args} {
    global_placement_or args
}

proc random_global_placement {args} {
    increment_index
    TIMER::timer_start
    set log [index_file $::env(placement_logs)/global.log]
    puts_info "Performing Random Global Placement (log: [relpath . $log])..."
    set ::env(SAVE_DEF) [index_file $::env(placement_tmpfiles)/global.def]

    set save_def [index_file $::env(placement_tmpfiles)/global.def]
    set save_odb [index_file $::env(placement_tmpfiles)/global.odb]
    manipulate_layout $::env(SCRIPTS_DIR)/odbpy/random_place.py\
        -indexed_log [index_file $::env(placement_logs)/global.log]\
        -output_def $save_def\
        -output $save_odb\
        -input $::env(CURRENT_ODB)

    set_odb $save_odb
    set_def $save_def

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "random global placement - openlane"
}

proc detailed_placement_or {args} {
    set options {
        {-log optional}
        {-outdir optional}
        {-name optional}
    }
    set flags {}
    parse_key_args "detailed_placement_or" args arg_values $options flags_map $flags

    set_if_unset arg_values(-name) $::env(DESIGN_NAME)
    set_if_unset arg_values(-log) $::env(placement_logs)/detailed.log
    set_if_unset arg_values(-outdir) $::env(placement_results)

    increment_index
    TIMER::timer_start
    set log [index_file $arg_values(-log)]
    puts_info "Running Detailed Placement (log: [relpath . $log])..."

    run_openroad_script $::env(SCRIPTS_DIR)/openroad/dpl.tcl\
        -indexed_log $log\
        -save "to=$arg_values(-outdir),name=$arg_values(-name),noindex,def,odb,netlist,powered_netlist"

    if {[catch {exec grep -q -i "fail" $log}] == 0}  {
        puts "Error: Check $log"
        puts stderr "\[ERROR\]: Check $log"
        exit 1
    }

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "detailed placement - openroad"
}

proc detailed_placement {args} {
    detailed_placement_or ${*}args
}

proc add_macro_placement {args} {
    puts_info "Adding Macro Placement..."
    set ori "NONE"
    if { [llength $args] == 4 } {
        set ori [lindex $args 3]
    }
    try_exec echo [lindex $args 0] [lindex $args 1] [lindex $args 2] $ori >> $::env(placement_tmpfiles)/macro_placement.cfg
}

proc manual_macro_placement {args} {
    set options {}
    set flags {-f}
    parse_key_args "manual_macro_placement" args arg_values $options flags_map $flags


    increment_index
    TIMER::timer_start
    set log [index_file $::env(placement_logs)/macro_placement.log]
    puts_info "Performing Manual Macro Placement (log: [relpath . $log])..."

    set fbasename [file rootname $::env(CURRENT_ODB)]

    set prev_db $::env(CURRENT_ODB)
    set save_def ${fbasename}.macro_placement.def
    set save_db ${fbasename}.macro_placement.odb

    set arg_list [list]
    lappend arg_list --config $::env(placement_tmpfiles)/macro_placement.cfg
    if { [info exists flags_map(-f)] } {
        lappend arg_list --fixed
    }

    manipulate_layout $::env(SCRIPTS_DIR)/odbpy/manual_macro_place.py\
        -indexed_log $log \
        -output_def $save_def \
        -output $save_db \
        -input $prev_db \
        {*}$arg_list

    set_odb $save_db
    set_def $save_def
}

proc basic_macro_placement {args} {
    increment_index
    TIMER::timer_start
    set log [index_file $::env(placement_logs)/basic_mp.log]
    puts_info "Running basic macro placement (log: [relpath . $log])..."

    set fbasename [file rootname $::env(CURRENT_DEF)]

    run_openroad_script $::env(SCRIPTS_DIR)/openroad/basic_mp.tcl\
        -indexed_log [index_file $::env(placement_logs)/basic_mp.log]\
        -save "to=$::env(placement_tmpfiles),name=macros_placed,def,odb"

    check_macro_placer_num_solns

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "macro placement - basic_mp.tcl"
}

proc run_placement {args} {
    # |----------------------------------------------------|
    # |----------------   3. PLACEMENT   ------------------|
    # |----------------------------------------------------|

    if { $::env(DPL_CELL_PADDING) > $::env(GPL_CELL_PADDING) } {
        puts_warn "DPL_CELL_PADDING is set higher than GPL_CELL_PADDING ($::env(DPL_CELL_PADDING) > $::env(GPL_CELL_PADDING)). This may result in inconsistent behavior."
    }

    if { $::env(PL_RANDOM_GLB_PLACEMENT) } {
        # useful for very tiny designs
        random_global_placement
    } else {
        global_placement_or
    }

    run_resizer_design

    detailed_placement_or

    scrot_klayout -layout $::env(CURRENT_DEF) -log $::env(placement_logs)/screenshot.log
    run_sta -pre_cts -estimate_placement -no_save -log $::env(placement_logs)/dpl_sta.log
}

proc run_resizer_design {args} {
    if { $::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) == 1 } {
        increment_index
        TIMER::timer_start
        set log [index_file $::env(placement_logs)/resizer.log]
        puts_info "Running Placement Resizer Design Optimizations (log: [relpath . $log])..."

        run_openroad_script $::env(SCRIPTS_DIR)/openroad/resizer.tcl\
            -indexed_log [index_file $::env(placement_logs)/resizer.log]\
            -save "to=$::env(placement_tmpfiles),name=resizer,def,odb,sdc,netlist,powered_netlist"

        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "resizer design optimizations - openroad"
    } else {
        puts_info "Skipping Placement Resizer Design Optimizations."
    }
}

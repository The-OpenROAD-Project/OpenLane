# Copyright 2020-2022 Efabless Corporation
# ECO Flow Copyright 2021 The University of Michigan
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

proc global_routing_or {args} {
    handle_deprecated_command global_routing
}

proc groute_antenna_extract {args} {
    set options {
        {-from_log required}
    }
    set flags {}
    parse_key_args "groute_antenna_extract" args arg_values $options flags_map $flags

    set value [exec python3 $::env(SCRIPTS_DIR)/extract_antenna_count.py < $arg_values(-from_log)]

    return $value
}

proc global_routing_fastroute {args} {
    increment_index
    TIMER::timer_start
    set log [index_file $::env(routing_logs)/global.log]
    puts_info "Running Global Routing (log: [relpath . $log])..."

    set initial_def [index_file $::env(routing_tmpfiles)/global.def]
    set initial_guide [index_file $::env(routing_tmpfiles)/global.guide]
    set initial_odb [index_file $::env(routing_tmpfiles)/global.odb]

    run_openroad_script $::env(SCRIPTS_DIR)/openroad/groute.tcl\
        -indexed_log $log\
        -save "def=$initial_def,guide=$initial_guide,odb=$initial_odb"\
        -no_update_current

    if { ($::env(DIODE_INSERTION_STRATEGY) == 3) || ($::env(DIODE_INSERTION_STRATEGY) == 6) } {
        puts_info "Starting OpenROAD Antenna Repair Iterations..."
        set iter 1

        set minimum_def $initial_def
        set minimum_guide $initial_guide
        set minimum_odb $initial_odb
        set minimum_antennae [groute_antenna_extract -from_log $log]

        while {$iter <= $::env(GRT_MAX_DIODE_INS_ITERS) && $minimum_antennae > 0} {
            set log [index_file $::env(routing_logs)/antenna_diodes_$iter.log]
            puts_info "Starting antenna repair iteration $iter with $minimum_antennae violations..."

            manipulate_layout $::env(SCRIPTS_DIR)/odbpy/defutil.py replace_instance_prefixes\
                -indexed_log $log\
                -output_def $::env(CURRENT_DEF)\
                --original-prefix "ANTENNA"\
                --new-prefix "INSDIODE$iter"

            set log [index_file $::env(routing_logs)/antenna_route_$iter.log]
            run_openroad_script $::env(SCRIPTS_DIR)/openroad/groute.tcl\
                -indexed_log $log\
                -save "to=$::env(routing_tmpfiles),name=global_$iter,def,guide,odb"\
                -no_update_current

            set antennae [groute_antenna_extract -from_log $log]

            if { $antennae >= $minimum_antennae } {
                puts_info "\[Iteration $iter\] Failed to reduce antenna violations ($minimum_antennae -> $antennae), stopping iterations..."
                set ::env(SAVE_DEF) $minimum_def
                set ::env(SAVE_GUIDE) $minimum_guide
                set ::env(SAVE_ODB) $minimum_odb
                break
            } else {
                puts_info "\[Iteration $iter\] Reduced antenna violations ($minimum_antennae -> $antennae)"
                set minimum_def $::env(SAVE_DEF)
                set minimum_guide $::env(SAVE_GUIDE)
                set minimum_odb $::env(SAVE_ODB)
                set minimum_antennae [groute_antenna_extract -from_log [groute_antenna_extract -from_log $log]]
            }
            incr iter
        }
    }

    set_def $::env(SAVE_DEF)
    set_guide $::env(SAVE_GUIDE)
    set_odb $::env(SAVE_ODB)
    unset ::env(SAVE_DEF)
    unset ::env(SAVE_GUIDE)
    unset ::env(SAVE_ODB)

    write_verilog\
        $::env(routing_tmpfiles)/global.nl.v\
        -powered_to $::env(routing_tmpfiles)/global.pnl.v\
        -indexed_log [index_file $::env(routing_logs)/global_write_netlist.log]

    TIMER::timer_stop

    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "global routing - openroad"
}

proc global_routing_cugr {args} {
    handle_deprecated_command global_routing_fastroute
}

proc global_routing {args} {
    if { $::env(GLOBAL_ROUTER) == "cugr" } {
        puts_warn "CU-GR is no longer supported. OpenROAD fastroute will be used instead."
    }

    global_routing_fastroute
}

proc detailed_routing_tritonroute {args} {
    if { !$::env(RUN_DRT) } {
        return
    }

    if { $::env(DETAILED_ROUTER) == "drcu" } {
        puts_warn "DR-CU is no longer supported. OpenROAD's detailed router will be used instead."
        set ::env(DETAILED_ROUTER) "tritonroute"
    }

    increment_index
    TIMER::timer_start
    set log [index_file $::env(routing_logs)/detailed.log]
    puts_info "Running Detailed Routing (log: [relpath . $log])..."

    set ::env(_tmp_drt_file_prefix) $::env(routing_tmpfiles)/drt
    set ::env(_tmp_drt_rpt_prefix) $::env(routing_reports)/drt
    run_openroad_script $::env(SCRIPTS_DIR)/openroad/droute.tcl\
        -indexed_log $log\
        -save "to=$::env(routing_results),noindex,def,odb,netlist,powered_netlist"
    unset ::env(_tmp_drt_file_prefix)
    unset ::env(_tmp_drt_rpt_prefix)

    try_catch python3 $::env(SCRIPTS_DIR)/drc_rosetta.py tr to_klayout \
        -o $::env(routing_reports)/drt.klayout.xml \
        --design-name $::env(DESIGN_NAME) \
        $::env(routing_reports)/drt.drc

    quit_on_tr_drc

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "detailed_routing - openroad"
}

proc detailed_routing_drcu {args} {
    handle_deprecated_command detailed_routing_tritonroute
}

proc detailed_routing {args} {
    detailed_routing_tritonroute {*}$args
}

proc ins_fill_cells_or {args} {
    handle_deprecated_command ins_fill_cells
}

proc ins_fill_cells {args} {
    if {!$::env(FILL_INSERTION)} {
        return
    }
    increment_index
    TIMER::timer_start
    set log [index_file $::env(routing_logs)/fill.log]
    puts_info "Running Fill Insertion (log: [relpath . $log])..."

    run_openroad_script $::env(SCRIPTS_DIR)/openroad/fill.tcl\
        -indexed_log [index_file $::env(routing_logs)/fill.log]\
        -save "to=$::env(routing_tmpfiles),name=fill,def,odb,netlist,powered_netlist"

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "fill insertion - openroad"
}

proc power_routing {args} {
    increment_index
    TIMER::timer_start
    set log [index_file $::env(routing_logs)/power_routing.log]
    puts_info "Routing top-level power nets (log: [relpath . $log])..."

    set options {
        {-lef optional}
        {-odb optional}
        {-power optional}
        {-ground optional}
        {-output_def optional}
        {-output_odb optional}
        {-extra_args optional}
    }
    set flags {}
    parse_key_args "power_routing" args arg_values $options flags_map $flags

    set_if_unset arg_values(-lef) $::env(MERGED_LEF)
    set_if_unset arg_values(-odb) $::env(CURRENT_ODB)
    set_if_unset arg_values(-power) $::env(VDD_PIN)
    set_if_unset arg_values(-ground) $::env(GND_PIN)
    set_if_unset arg_values(-output_def) [index_file $::env(routing_tmpfiles)/$::env(DESIGN_NAME).power_routed.def]
    set_if_unset arg_values(-output_odb) [index_file $::env(routing_tmpfiles)/$::env(DESIGN_NAME).power_routed.odb]
    set_if_unset arg_values(-extra_args) ""


    manipulate_layout $::env(SCRIPTS_DIR)/odbpy/power_utils.py power_route\
        -indexed_log [index_file $::env(routing_logs)/power_routing.log]\
        -output_def $arg_values(-output_def)\
        -output $arg_values(-output_odb)\
        -input $arg_values(-odb)\
        --core-vdd-pin $arg_values(-power)\
        --core-gnd-pin $arg_values(-ground)\
        {*}$arg_values(-extra_args)

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "top level power routing - openlane"
}


proc ins_diode_cells_1 {args} {
    increment_index
    TIMER::timer_start
    set log [index_file $::env(routing_logs)/diodes.log]
    puts_info "Running Diode Insertion (log: [relpath . $log])..."

    run_openroad_script $::env(SCRIPTS_DIR)/openroad/diodes.tcl\
        -indexed_log [index_file $::env(routing_logs)/diodes.log]\
        -save "to=$::env(routing_tmpfiles),name=diodes,def,odb,netlist,powered_netlist"

    TIMER::timer_stop

    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "diode insertion - openroad"
}

proc ins_diode_cells_4 {args} {
    increment_index
    TIMER::timer_start
    set log [index_file $::env(routing_logs)/diodes.log]
    puts_info "Running Diode Insertion (log: [relpath . $log])..."

    # Select diode cell
    if { $::env(DIODE_INSERTION_STRATEGY) == 5 } {
        if { ! [info exists ::env(FAKEDIODE_CELL)] } {
            puts_err "DIODE_INSERTION_STRATEGY $::env(DIODE_INSERTION_STRATEGY) is only valid when FAKEDIODE_CELL is defined."
            puts_err "Please try a different strategy."
            return -code error
        }
        set ::antenna_cell_name $::env(FAKEDIODE_CELL)
    } else {
        set ::antenna_cell_name $::env(DIODE_CELL)
    }

    # Custom script
    set save_def [index_file $::env(routing_tmpfiles)/diodes.def]
    set save_odb [index_file $::env(routing_tmpfiles)/diodes.odb]

    manipulate_layout $::env(SCRIPTS_DIR)/odbpy/diodes.py place\
        -indexed_log [index_file $::env(routing_logs)/diodes.log]\
        -output $save_odb\
        -output_def $save_def\
        --diode-cell $::env(DIODE_CELL)\
        --diode-pin  $::env(DIODE_CELL_PIN)\
        --fake-diode-cell $::antenna_cell_name

    set_def $save_def
    set_odb $save_odb

    # Legalize
    detailed_placement_or\
        -outdir $::env(routing_tmpfiles)\
        -log $::env(routing_logs)/diode_legalization.log\
        -name diodes

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "diode insertion - openlane"
}

proc apply_route_obs {args} {
    increment_index
    TIMER::timer_start
    set log [index_file $::env(routing_logs)/obs.log]
    puts_info "Running Diode Insertion (log: [relpath . $log])..."

    set save_def [file rootname $::env(CURRENT_DEF)].obs.def
    set save_db [file rootname $::env(CURRENT_DEF)].obs.odb

    manipulate_layout $::env(SCRIPTS_DIR)/odbpy/defutil.py add_obstructions\
        -indexed_log $log\
        -output $save_db\
        -output_def $save_def\
        --obstructions $::env(GRT_OBS)

    puts_verbose "Obstructions added over $::env(GRT_OBS)."

    set_def $save_def
    set_odb $save_db

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "adding routing obstructions - openlane"
}

proc add_route_obs {args} {
    if {[info exists ::env(GRT_OBS)]} {
        apply_route_obs
    }
}

proc check_wire_lengths {args} {
    increment_index
    TIMER::timer_start
    set log [index_file $::env(routing_logs)/wire_lengths.log]
    puts_info "Checking Wire Lengths (log: [relpath . $log])..."

    set arg_list [list]
    lappend arg_list --report-out [index_file $::env(routing_reports)/wire_lengths.csv]
    if { [info exists ::env(WIRE_LENGTH_THRESHOLD)] } {
        lappend arg_list --threshold $::env(WIRE_LENGTH_THRESHOLD)
    }
    if { $::env(QUIT_ON_LONG_WIRE) } {
        lappend arg_list --fail
    }

    manipulate_layout $::env(SCRIPTS_DIR)/odbpy/wire_lengths.py\
        -indexed_log $log\
        {*}$arg_list

    TIMER::timer_stop

    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "wire lengths - openlane"
}

proc run_spef_extraction {args} {
    set options {
        {-save required}
        {-log required}
        {-rcx_def optional}
        {-rcx_lib optional}
        {-rcx_lef optional}
        {-rcx_rules optional}
        {-process_corner optional}
    }
    parse_key_args "run_spef_extraction" args arg_values $options

    set_if_unset arg_values(-rcx_lib) $::env(LIB_SYNTH_COMPLETE)
    set_if_unset arg_values(-rcx_lef) $::env(MERGED_LEF)
    set_if_unset arg_values(-rcx_rules) $::env(RCX_RULES)
    set_if_unset arg_values(-rcx_def) $::env(CURRENT_DEF)


    increment_index
    set log [index_file $arg_values(-log)]
    TIMER::timer_start

    set ec_postfix ""
    if { [info exists arg_values(-process_corner)]} {
        set ec_postfix " at the $arg_values(-process_corner) process corner"
    }

    puts_info "Running SPEF Extraction$ec_postfix (log: [relpath . $log])..."

    if { $::env(SPEF_EXTRACTOR) == "def2spef" } {
        puts_warn "def2spef/spef_extractor has been removed. OpenROAD OpenRCX will be used instead."
        set ::env(SPEF_EXTRACTOR) "openrcx"
    }


    set ::env(RCX_DEF) $arg_values(-rcx_def)
    set ::env(RCX_LEF) $arg_values(-rcx_lef)
    set ::env(RCX_LIB) $arg_values(-rcx_lib)
    set ::env(RCX_RULESET) $arg_values(-rcx_rules)
    assert_files_exist "$::env(RCX_RULESET) $::env(RCX_LIB)"
    run_openroad_script $::env(SCRIPTS_DIR)/openroad/rcx.tcl\
        -indexed_log $log\
        -save "odb=/dev/null,spef=$arg_values(-save)"
    unset ::env(RCX_LIB)
    unset ::env(RCX_RULESET)
    unset ::env(RCX_LEF)
    unset ::env(RCX_DEF)

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "parasitics extraction - openroad"
}

proc run_routing {args} {
    puts_verbose "Starting routing process..."

    # |----------------------------------------------------|
    # |----------------   5. ROUTING ----------------------|
    # |----------------------------------------------------|

    run_resizer_timing_routing
    if { $::env(RSZ_USE_OLD_REMOVER) == 1} {
        remove_buffers_from_nets
    }

    if { [info exists ::env(DIODE_CELL)] && ($::env(DIODE_CELL) ne "") } {
        if { ($::env(DIODE_INSERTION_STRATEGY) == 1) || ($::env(DIODE_INSERTION_STRATEGY) == 2) } {
            ins_diode_cells_1
        }
        if { ($::env(DIODE_INSERTION_STRATEGY) == 4) || ($::env(DIODE_INSERTION_STRATEGY) == 5) || ( $::env(DIODE_INSERTION_STRATEGY) == 6) } {
            ins_diode_cells_4
        }
    }

    add_route_obs

    #legalize if not yet legalized
    if { ($::env(DIODE_INSERTION_STRATEGY) != 4) && ($::env(DIODE_INSERTION_STRATEGY) != 5) && ($::env(DIODE_INSERTION_STRATEGY) != 6) } {
        detailed_placement_or\
            -outdir $::env(routing_tmpfiles)\
            -name diode\
            -log $::env(routing_logs)/diode_legalization.log
    }

    # if diode insertion does *not* happen as part of global routing, then
    # we can insert fill cells early on
    if { ($::env(DIODE_INSERTION_STRATEGY) != 3) && ($::env(DIODE_INSERTION_STRATEGY) != 6) && ($::env(ECO_ENABLE) == 0) } {
        ins_fill_cells
    }

    global_routing

    if { (($::env(DIODE_INSERTION_STRATEGY) == 3) || ($::env(DIODE_INSERTION_STRATEGY) == 6)) && ($::env(ECO_ENABLE) == 0) } {
        # Doing this here can be problematic and is something that needs to be
        # addressed in FastRoute since fill cells *might* occupy some of the
        # resources that were already used during global routing causing the
        # detailed router to suffer later.
        ins_fill_cells
    }

    # Detailed Routing
    detailed_routing

    # Print Wire Lengths + Check Thresholds
    check_wire_lengths

    # Screenshot (If Applicable)
    scrot_klayout -layout $::env(CURRENT_DEF) -log $::env(routing_logs)/screenshot.log

    # Calculate Runtime
    set ::env(timer_routed) [clock seconds]
}

proc run_resizer_timing_routing {args} {
    if { $::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) == 1} {
        increment_index
        TIMER::timer_start
        set log [index_file $::env(routing_logs)/resizer.log]
        puts_info "Running Global Routing Resizer Timing Optimizations (log: [relpath . $log])..."

        run_openroad_script $::env(SCRIPTS_DIR)/openroad/resizer_routing_timing.tcl\
            -indexed_log [index_file $::env(routing_logs)/resizer.log]\
            -save "dir=$::env(routing_tmpfiles),def,sdc,odb,netlist,powered_netlist"

        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "resizer timing optimizations - openroad"

    } else {
        puts_info "Skipping Global Routing Resizer Timing Optimizations."
    }
}


package provide openlane 0.9

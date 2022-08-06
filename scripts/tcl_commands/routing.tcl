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
    set log [index_file $::env(routing_logs)/global.log]

    set initial_def [index_file $::env(routing_tmpfiles)/global.def]
    set initial_guide [index_file $::env(routing_tmpfiles)/global.guide]

    run_openroad_script $::env(SCRIPTS_DIR)/openroad/groute.tcl\
        -indexed_log $log\
        -save "def=$initial_def,guide=$initial_guide"\
        -no_update_current

    if { $::env(DIODE_INSERTION_STRATEGY) == 3 } {
        puts_info "Starting OpenROAD Antenna Repair Iterations..."
        set iter 1

        set minimum_def $initial_def
        set minimum_guide $initial_guide
        set minimum_antennae [groute_antenna_extract -from_log $log]

        while {$iter <= $::env(GRT_MAX_DIODE_INS_ITERS) && $minimum_antennae > 0} {
            set log [index_file $::env(routing_logs)/global_$iter.log]
            puts_info "Starting antenna repair iteration $iter with $minimum_antennae violations..."

            try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/odbpy/defutil.py replace_instance_prefixes\
                --output $::env(CURRENT_DEF)\
                --original-prefix "ANTENNA"\
                --new-prefix "INSDIODE$iter"\
                --input-lef $::env(MERGED_LEF)\
                $::env(CURRENT_DEF)

            run_openroad_script $::env(SCRIPTS_DIR)/openroad/groute.tcl\
                -indexed_log $log\
                -save "def=[index_file $::env(routing_tmpfiles)/global_$iter.def],guide=[index_file $::env(routing_tmpfiles)/global_$iter.guide]"\
                -no_update_current

            set antennae [groute_antenna_extract -from_log $log]

            if { $antennae >= $minimum_antennae } {
                puts_info "\[Iteration $iter\] Failed to reduce antenna violations ($minimum_antennae -> $antennae), stopping iterations..."
                set ::env(SAVE_DEF) $minimum_def
                set ::env(SAVE_GUIDE) $minimum_guide
                break
            } else {
                puts_info "\[Iteration $iter\] Reduced antenna violations ($minimum_antennae -> $antennae)"
                set minimum_def $::env(SAVE_DEF) 
                set minimum_guide $::env(SAVE_GUIDE) 
                set minimum_antennae [groute_antenna_extract -from_log [groute_antenna_extract -from_log $log]]
            }
        }
    }

    set_def $::env(SAVE_DEF)
    set_guide $::env(SAVE_GUIDE)
    unset ::env(SAVE_DEF)
    unset ::env(SAVE_GUIDE)
}

proc global_routing_cugr {args} {
    handle_deprecated_command global_routing_fastroute
}

proc global_routing {args} {
    increment_index
    TIMER::timer_start
    puts_info "Running Global Routing..."

    set tool "openroad"
    if { $::env(GLOBAL_ROUTER) == "cugr" } {
        puts_warn "CU-GR is no longer supported. OpenROAD fastroute will be used instead."
        set ::env(GLOBAL_ROUTER) "fastroute"
    }

    global_routing_fastroute

    TIMER::timer_stop

    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "global routing - $tool"
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

    set drt_log [index_file $::env(routing_logs)/detailed.log]
    set drt_log_relative [relpath . $drt_log]

    puts_info "Running Detailed Routing (logging to '$drt_log_relative')..."

    set ::env(_tmp_drt_file_prefix) $::env(routing_tmpfiles)/drt
    set ::env(_tmp_drt_rpt_prefix) $::env(routing_reports)/drt
    run_openroad_script $::env(SCRIPTS_DIR)/openroad/droute.tcl\
        -indexed_log $drt_log\
        -save "def=$::env(routing_results)/$::env(DESIGN_NAME).def"
    unset ::env(_tmp_drt_file_prefix)
    unset ::env(_tmp_drt_rpt_prefix)

    try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/drc_rosetta.py tr to_klayout \
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
    increment_index

    if {$::env(FILL_INSERTION)} {
        TIMER::timer_start
        puts_info "Running Fill Insertion..."
        run_openroad_script $::env(SCRIPTS_DIR)/openroad/fill.tcl\
            -indexed_log [index_file $::env(routing_logs)/fill.log]\
            -save "def=[index_file $::env(routing_tmpfiles)/fill.def]"
        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "fill insertion - openroad"
    }
}

proc power_routing {args} {
    increment_index
    TIMER::timer_start
    puts_info "Routing top-level power nets..."

    set options {
        {-lef optional}
        {-def optional}
        {-power optional}
        {-ground optional}
        {-output_def optional}
        {-extra_args optional}
    }
    set flags {}
    parse_key_args "power_routing" args arg_values $options flags_map $flags

    set_if_unset arg_values(-lef) $::env(MERGED_LEF)
    set_if_unset arg_values(-def) $::env(CURRENT_DEF)
    set_if_unset arg_values(-power) $::env(VDD_PIN)
    set_if_unset arg_values(-ground) $::env(GND_PIN)
    set_if_unset arg_values(-output_def) [index_file $::env(routing_tmpfiles)/$::env(DESIGN_NAME).power_routed.def]
    set_if_unset arg_values(-extra_args) ""


    try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/odbpy/power_utils.py power_route\
        --input-lef $arg_values(-lef)\
        --core-vdd-pin $arg_values(-power)\
        --core-gnd-pin $arg_values(-ground)\
        --output $arg_values(-output_def)\
        {*}$arg_values(-extra_args)\
        $arg_values(-def)\
        |& tee [index_file $::env(routing_logs)/power_routing.log] $::env(TERMINAL_OUTPUT)

    set_def $arg_values(-output_def)

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "top level power routing - openlane"
}

proc gen_pdn {args} {
    increment_index
    TIMER::timer_start
    puts_info "Generating PDN..."

    set ::env(PGA_RPT_FILE) [index_file $::env(floorplan_tmpfiles)/pdn.pga.rpt]

    if { ! [info exists ::env(VDD_NET)] } {
        set ::env(VDD_NET) $::env(VDD_PIN)
    }

    if { ! [info exists ::env(GND_NET)] } {
        set ::env(GND_NET) $::env(GND_PIN)
    }

    run_openroad_script $::env(SCRIPTS_DIR)/openroad/pdn.tcl \
        -indexed_log [index_file $::env(floorplan_logs)/pdn.log] \
        -save "def=[index_file $::env(floorplan_tmpfiles)/pdn.def]"

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "pdn generation - openroad"

    quit_on_unconnected_pdn_nodes
}


proc ins_diode_cells_1 {args} {
    increment_index
    TIMER::timer_start
    puts_info "Running Diode Insertion..."

    run_openroad_script $::env(SCRIPTS_DIR)/openroad/diodes.tcl\
        -indexed_log [index_file $::env(routing_logs)/diodes.log]\
        -save "def=[index_file $::env(routing_tmpfiles)/diodes.def]"

    TIMER::timer_stop

    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "diode insertion - openroad"

    # Update Netlist
    set save_nl $::env(routing_results)/$::env(DESIGN_NAME)_diodes.v
    write_verilog $save_nl -log $::env(routing_logs)/write_verilog.with_diodes.log
}

proc ins_diode_cells_4 {args} {
    increment_index
    TIMER::timer_start
    puts_info "Running Diode Insertion..."

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
    try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/odbpy/diodes.py\
        place\
        --output $save_def\
        --input-lef $::env(MERGED_LEF)\
        --diode-cell $::env(DIODE_CELL)\
        --diode-pin  $::env(DIODE_CELL_PIN)\
        --fake-diode-cell $::antenna_cell_name\
        $::env(CURRENT_DEF) |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(routing_logs)/diodes.log]
    set_def $save_def
    unset ::env(SAVE_DEF)

    # Legalize
    detailed_placement_or -def $::env(CURRENT_DEF) -log $::env(routing_logs)/diode_legalization.log

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "diode insertion - openlane"

    # Update netlist
    set save_nl $::env(routing_results)/$::env(DESIGN_NAME)_diodes.v
    write_verilog $save_nl -log $::env(routing_logs)/write_verilog.with_diodes.log
    if { $::env(LEC_ENABLE) } {
        logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
    }
}

proc apply_route_obs {args} {
    puts_info "Adding routing obstructions..."
    # keep a warning for a while
    puts_warn "Specifying a routing obstruction is now done using the coordinates"
    puts_warn "of its bounding box instead of the now deprecated (x, y, size_x, size_y)."

    try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/odbpy/defutil.py add_def_obstructions\
        --output [file rootname $::env(CURRENT_DEF)].obs.def \
        --input-lef $::env(MERGED_LEF) \
        --obstructions $::env(GRT_OBS) \
        $::env(CURRENT_DEF) |& tee $::env(TERMINAL_OUTPUT) $::env(routing_logs)/obs.log

    puts_info "Obstructions added over $::env(GRT_OBS)."
    set_def [file rootname $::env(CURRENT_DEF)].obs.def
}

proc add_route_obs {args} {
    if {[info exists ::env(GRT_OBS)]} {
        apply_route_obs
    }
}

proc run_spef_extraction {args} {
    set options {
        {-save required}
        {-log required}
        {-rcx_lib optional}
        {-rcx_lef optional}
        {-rcx_rules optional}
        {-process_corner optional}
    }
    parse_key_args "run_spef_extraction" args arg_values $options

    set_if_unset arg_values(-rcx_lib) $::env(LIB_SYNTH_COMPLETE)
    set_if_unset arg_values(-rcx_lef) $::env(MERGED_LEF)
    set_if_unset arg_values(-rcx_rules) $::env(RCX_RULES)

    set ::env(RCX_LIB) $arg_values(-rcx_lib)
    set ::env(RCX_LEF) $arg_values(-rcx_lef)
    set ::env(RCX_RULESET) $arg_values(-rcx_rules)

    assert_files_exist "$::env(RCX_RULESET) $::env(RCX_LEF)"

    increment_index
    TIMER::timer_start
    set log [index_file $arg_values(-log)]

    set ec_postfix ""
    if { [info exists arg_values(-process_corner)]} {
        set ec_postfix " at the $arg_values(-process_corner) process corner"
    }

    puts_info "Running SPEF Extraction$ec_postfix..."

    if { $::env(SPEF_EXTRACTOR) == "def2spef" } {
        puts_warn "def2spef/spef_extractor has been removed. OpenROAD OpenRCX will be used instead."
        set ::env(SPEF_EXTRACTOR) "openrcx"
    }

    run_openroad_script $::env(SCRIPTS_DIR)/openroad/rcx.tcl\
        -indexed_log $log\
        -save "spef=$arg_values(-save)"

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "parasitics extraction - openroad"
}

proc run_routing {args} {
    puts_info "Routing..."

    # |----------------------------------------------------|
    # |----------------   5. ROUTING ----------------------|
    # |----------------------------------------------------|
    set ::env(CURRENT_STAGE) routing
    run_resizer_timing_routing

    if { [info exists ::env(DIODE_CELL)] && ($::env(DIODE_CELL) ne "") } {
        if { ($::env(DIODE_INSERTION_STRATEGY) == 1) || ($::env(DIODE_INSERTION_STRATEGY) == 2) } {
            ins_diode_cells_1
        }
        if { ($::env(DIODE_INSERTION_STRATEGY) == 4) || ($::env(DIODE_INSERTION_STRATEGY) == 5) } {
            ins_diode_cells_4
        }
    }

    add_route_obs

    #legalize if not yet legalized
    if { ($::env(DIODE_INSERTION_STRATEGY) != 4) && ($::env(DIODE_INSERTION_STRATEGY) != 5) } {
        detailed_placement_or -def $::env(CURRENT_DEF) -log $::env(routing_logs)/diode_legalization.log
    }

    # if diode insertion does *not* happen as part of global routing, then
    # we can insert fill cells early on
    if { ($::env(DIODE_INSERTION_STRATEGY) != 3) && ($::env(ECO_ENABLE) == 0) } {
        ins_fill_cells
    }

    global_routing

    if { ($::env(DIODE_INSERTION_STRATEGY) == 3) && ($::env(ECO_ENABLE) == 0) } {
        # Doing this here can be problematic and is something that needs to be
        # addressed in FastRoute since fill cells *might* occupy some of the
        # resources that were already used during global routing causing the
        # detailed router to suffer later.
        ins_fill_cells
    }

    set global_routed_netlist [index_file $::env(routing_tmpfiles)/global.v]
    write_verilog $global_routed_netlist -log $::env(routing_logs)/write_verilog_global.log

    # detailed routing
    detailed_routing

    set detailed_routed_netlist [index_file $::env(routing_tmpfiles)/detailed.v]

    write_verilog $detailed_routed_netlist -log $::env(routing_logs)/write_verilog_detailed.log

    scrot_klayout -layout $::env(CURRENT_DEF) -log $::env(routing_logs)/screenshot.log

    ## Calculate Runtime To Routing
    set ::env(timer_routed) [clock seconds]
}

proc run_resizer_timing_routing {args} {
    if { $::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) == 1} {
        increment_index
        TIMER::timer_start
        puts_info "Running Global Routing Resizer Timing Optimizations..."

        run_openroad_script $::env(SCRIPTS_DIR)/openroad/resizer_routing_timing.tcl\
            -indexed_log [index_file $::env(routing_logs)/resizer.log]\
            -save "def=[index_file $::env(routing_tmpfiles)/resizer_timing.def],sdc=[index_file $::env(routing_tmpfiles)/resizer_timing.sdc]"

        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "resizer timing optimizations - openroad"

        # Update Netlist
        set save_nl $::env(routing_results)/$::env(DESIGN_NAME).resized.v
        write_verilog $save_nl $::env(routing_logs)/write_verilog.log

    } else {
        puts_info "Skipping Global Routing Resizer Timing Optimizations."
    }
}


package provide openlane 0.9

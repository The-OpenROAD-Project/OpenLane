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

proc global_routing_or {args} {
    handle_deprecated_command global_routing
}

proc global_routing_cugr {args} {
	if { $::env(DIODE_INSERTION_STRATEGY) == 3 } {
		puts_err "DIODE_INSERTION_STRATEGY 3 is only valid when OpenROAD is used for global routing."
		puts_err "Please try a different strategy."
		return -code error
	}
	try_catch cugr \
		-lef $::env(MERGED_LEF_UNPADDED) \
		-def $::env(CURRENT_DEF) \
		-output $::env(SAVE_GUIDE) \
		-threads $::env(ROUTING_CORES) \
		|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(routing_logs)/global.log]
	file copy -force $::env(CURRENT_DEF) $::env(SAVE_DEF)
}

proc global_routing_fastroute {args} {
	set saveLOG [index_file $::env(routing_logs)/global.log]
	try_catch $::env(OPENROAD_BIN) -exit $::env(SCRIPTS_DIR)/openroad/groute.tcl |& tee $::env(TERMINAL_OUTPUT) $saveLOG
	if { $::env(DIODE_INSERTION_STRATEGY) == 3 } {
		set_def $::env(SAVE_DEF)
		set_guide $::env(SAVE_GUIDE)
		set iter 2
		set prevDEF1 $::env(SAVE_DEF)
		set prevDEF2 $::env(SAVE_DEF)
		set prevGUIDE1 $::env(SAVE_GUIDE)
		set prevGUIDE2 $::env(SAVE_GUIDE)
		set prevLOG1 $saveLOG
		set prevLOG2 $saveLOG
		set prevAntennaVal [exec grep "INFO GRT-0012\] Antenna violations:" [index_file $::env(routing_logs)/global.log] -s | tail -1 | sed -r "s/.*\[^0-9\]//"]
		while {$iter <= $::env(GLB_RT_MAX_DIODE_INS_ITERS) && $prevAntennaVal > 0} {
			set ::env(SAVE_DEF) [index_file $::env(routing_tmpfiles)/global_$iter.def]
			set ::env(SAVE_GUIDE) [index_file $::env(routing_tmpfiles)/global_$iter.guide]
			set saveLOG [index_file $::env(routing_logs)/global_$iter.log]
			set replaceWith "INSDIODE$iter"
			try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/replace_prefix_from_def_instances.py -op "ANTENNA" -np $replaceWith -d $::env(CURRENT_DEF)
			puts_info "FastRoute Iteration $iter"
			puts_info "Antenna Violations Previous: $prevAntennaVal"
			try_catch $::env(OPENROAD_BIN) -exit $::env(SCRIPTS_DIR)/openroad/groute.tcl |& tee $::env(TERMINAL_OUTPUT) $saveLOG
			set currAntennaVal [exec grep "#Antenna violations:"  $saveLOG -s | tail -1 | sed -r "s/.*\[^0-9\]//"]
			puts_info "Antenna Violations Current: $currAntennaVal"
			if { $currAntennaVal >= $prevAntennaVal } {
				set iter [expr $iter - 1]
				set ::env(SAVE_DEF) $prevDEF1
				set ::env(SAVE_GUIDE) $prevGUIDE1
				set saveLOG $prevLOG1
				break
			} else {
				set prevAntennaVal $currAntennaVal
				set iter [expr $iter + 1]
				set prevDEF1 $prevDEF2
				set prevGUIDE1 $prevGUIDE2
				set prevLOG1 $prevLOG2
				set prevDEF2 $::env(SAVE_DEF)
				set prevGUIDE2 $::env(SAVE_GUIDE)
				set prevLOG2 $saveLOG
			}
			set_def $::env(SAVE_DEF)
			set_guide $::env(SAVE_GUIDE)
		}
	}
}

proc global_routing {args} {
    increment_index
	TIMER::timer_start
	puts_info "Running Global Routing..."
	set ::env(SAVE_GUIDE) [index_file $::env(routing_tmpfiles)/global.guide]
	set ::env(SAVE_DEF) [index_file $::env(routing_tmpfiles)/global.def]

	set tool "openroad"
	if { $::env(GLOBAL_ROUTER) == "cugr" } {
		set tool "cugr"
		global_routing_cugr
	} else {
		global_routing_fastroute
	}

	set_def $::env(SAVE_DEF)
	set_guide $::env(SAVE_GUIDE)

	TIMER::timer_stop

	exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "global routing - $tool"
	puts_info "Current Def is $::env(CURRENT_DEF)"
	puts_info "Current Guide is $::env(CURRENT_GUIDE)"
}

proc detailed_routing_tritonroute {args} {
	set ::env(TRITONROUTE_FILE_PREFIX) $::env(routing_tmpfiles)/detailed
	set ::env(TRITONROUTE_RPT_PREFIX) $::env(routing_reports)/detailed

	try_catch $::env(OPENROAD_BIN) -exit $::env(SCRIPTS_DIR)/openroad/droute.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(routing_logs)/detailed.log]

	try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/tr2klayout.py \
		-i $::env(routing_reports)/detailed.drc \
		-o $::env(routing_reports)/detailed.klayout.xml \
		--design-name $::env(DESIGN_NAME)

	quit_on_tr_drc
}

proc detailed_routing_drcu {args} {
	try_catch drcu \
		-lef $::env(MERGED_LEF_UNPADDED) \
		-def $::env(CURRENT_DEF) \
		-guide $::env(CURRENT_GUIDE) \
		-threads $::env(ROUTING_CORES) \
		-tat 99999999 \
		-output $::env(routing_results)/$::env(DESIGN_NAME)_detailed.def \
		|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(routing_logs)/detailed.log]
}

proc detailed_routing {args} {
	increment_index
    TIMER::timer_start
	puts_info "Running Detailed Routing..."
	set ::env(SAVE_DEF) [index_file $::env(routing_results)/$::env(DESIGN_NAME)_detailed.def]
	set tool "openroad"
	if {$::env(RUN_ROUTING_DETAILED)} {
		if { $::env(DETAILED_ROUTER) == "drcu" } {
			set tool "drcu"
			detailed_routing_drcu
		} else {
			detailed_routing_tritonroute
		}
	} else {
		exec echo "SKIPPED!" >> [index_file $::env(routing_logs)/detailed.log]
	}

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "detailed_routing - $tool"

    set_def $::env(SAVE_DEF)
}

proc ins_fill_cells_or {args} {
    handle_deprecated_command ins_fill_cells
}

proc ins_fill_cells {args} {
	increment_index

    if {$::env(FILL_INSERTION)} {
		TIMER::timer_start
		puts_info "Running Fill Insertion..."
		set ::env(SAVE_DEF) [index_file $::env(routing_tmpfiles)/fill.def]
		try_catch $::env(OPENROAD_BIN) -exit $::env(SCRIPTS_DIR)/openroad/fill.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(routing_logs)/fill.log]
		set_def $::env(SAVE_DEF)
		TIMER::timer_stop
		exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "fill insertion - openroad"
    } else {
		exec echo "SKIPPED!" >> [index_file $::env(routing_logs)/fill.log]
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


    try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/power_route.py\
		--input-lef $arg_values(-lef)\
		--input-def $arg_values(-def)\
		--core-vdd-pin $arg_values(-power)\
		--core-gnd-pin $arg_values(-ground)\
		-o $arg_values(-output_def)\
		{*}$arg_values(-extra_args) |& tee [index_file $::env(routing_logs)/power_routing.log] $::env(TERMINAL_OUTPUT)

    set_def $arg_values(-output_def)
	TIMER::timer_stop
	exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "top level power routing - power_route.py"
}

proc gen_pdn {args} {
	increment_index
    TIMER::timer_start
    puts_info "Generating PDN..."
	
    set ::env(SAVE_DEF) [index_file $::env(floorplan_tmpfiles)/pdn.def]
    set ::env(PGA_RPT_FILE) [index_file $::env(floorplan_tmpfiles)/pdn.pga.rpt]

    try_catch $::env(OPENROAD_BIN) -exit $::env(SCRIPTS_DIR)/openroad/pdn.tcl \
	|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(floorplan_logs)/pdn.log]


    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "pdn generation - openroad"

	quit_on_unconnected_pdn_nodes

    set_def $::env(SAVE_DEF)
}


proc ins_diode_cells_1 {args} {
	increment_index
	TIMER::timer_start
    puts_info "Running Diode Insertion..."
    set ::env(SAVE_DEF) [index_file $::env(routing_tmpfiles)/diodes.def]

    try_catch $::env(OPENROAD_BIN) -exit $::env(SCRIPTS_DIR)/openroad/diodes.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(routing_logs)/diodes.log]

    set_def $::env(SAVE_DEF)

    write_verilog $::env(synthesis_results)/$::env(DESIGN_NAME)_diodes.v -log [index_file $::env(routing_logs)/write_verilog_diodes.log]
    set_netlist $::env(synthesis_results)/$::env(DESIGN_NAME)_diodes.v

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "diode insertion - openroad"
    if { $::env(LEC_ENABLE) } {
		logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
    }
}

proc ins_diode_cells_4 {args} {
	increment_index
	TIMER::timer_start
    puts_info "Running Diode Insertion..."
    set ::env(SAVE_DEF) [index_file $::env(routing_tmpfiles)/diodes.def]

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
	try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/place_diodes.py -l $::env(MERGED_LEF) -id $::env(CURRENT_DEF) -o $::env(SAVE_DEF) --diode-cell $::env(DIODE_CELL)  --diode-pin  $::env(DIODE_CELL_PIN) --fake-diode-cell $::antenna_cell_name  |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(routing_logs)/diodes.log]

    set_def $::env(SAVE_DEF)

	# Legalize
	detailed_placement_or

	# Update netlist
	write_verilog $::env(synthesis_results)/$::env(DESIGN_NAME)_diodes.v -log [index_file $::env(routing_logs)/write_verilog_diodes.log]
	set_netlist $::env(synthesis_results)/$::env(DESIGN_NAME)_diodes.v

	TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "diode insertion - place_diodes.py"
	if { $::env(LEC_ENABLE) } {
		logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
    }
}

proc apply_route_obs {args} {
	puts_info "Adding routing obstructions..."
	# keep a warning for a while
	puts_warn "Specifying a routing obstruction is now done using the coordinates"
	puts_warn "of its bounding box instead of the now deprecated (x, y, size_x, size_y)."

	try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/add_def_obstructions.py \
		--input-def $::env(CURRENT_DEF) \
		--lef $::env(MERGED_LEF) \
		--obstructions $::env(GLB_RT_OBS) \
		--output [file rootname $::env(CURRENT_DEF)].obs.def |& tee $::env(TERMINAL_OUTPUT) $::env(routing_logs)/obs.log
	puts_info "Obstructions added over $::env(GLB_RT_OBS)"
	set_def [file rootname $::env(CURRENT_DEF)].obs.def
}

proc add_route_obs {args} {
    if {[info exists ::env(GLB_RT_OBS)]} {
        apply_route_obs
    }
	if {[info exists ::env(GLB_RT_MAXLAYER)] && [info exists ::env(MAX_METAL_LAYER)] && [info exists ::env(TECH_METAL_LAYERS)] && $::env(GLB_RT_MAXLAYER) < $::env(MAX_METAL_LAYER)} {
		set cnt 0
		set obs ""
		foreach layer $::env(TECH_METAL_LAYERS) {
			set cnt [expr $cnt + 1]
			if { $cnt == $::env(GLB_RT_MAXLAYER) + 1 } {
				set obs "$layer $::env(DIE_AREA)"
			} else {
				if { $cnt > $::env(GLB_RT_MAXLAYER) } {
					set new_obs ",$layer $::env(DIE_AREA)"
					append obs $new_obs
				}
			}
		}
		set obs  [join $obs " "]
		puts_info "Obstructions will be added over the whole die area: $obs"
		if {[info exists ::env(GLB_RT_OBS)]} {
			set store_obs $::env(GLB_RT_OBS)
		}

		set ::env(GLB_RT_OBS) $obs
		apply_route_obs
		if {[info exists store_obs]} {
			set ::env(GLB_RT_OBS) $store_obs
		}
    }
}

proc run_spef_extraction {args} {
	set options {
		{-log required}
		{-rcx_lib optional}
		{-output_spef optional}
	}
	parse_key_args "run_spef_extraction" args arg_values $options
	set_if_unset arg_values(-rcx_lib) $::env(LIB_SYNTH_COMPLETE);
	set_if_unset arg_values(-output_spef) [file rootname $::env(CURRENT_DEF)].spef;
	set ::env(CURRENT_SPEF) $arg_values(-output_spef)
	set ::env(LIB_RCX) $arg_values(-rcx_lib)
	
    if { $::env(RUN_SPEF_EXTRACTION) == 1 } {
		set tool "openroad"
		increment_index
		TIMER::timer_start
		puts_info "Running SPEF Extraction..."
		if { $::env(SPEF_EXTRACTOR) == "def2spef" } {
			set tool "def2spef"
			set ::env(MPLCONFIGDIR) /tmp
			try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/spef_extractor/main.py -l $::env(MERGED_LEF_UNPADDED) -d $::env(CURRENT_DEF) -mw $::env(SPEF_WIRE_MODEL) -ec $::env(SPEF_EDGE_CAP_FACTOR) |& tee $::env(TERMINAL_OUTPUT) $arg_values(-log)
		} else {
			try_catch $::env(OPENROAD_BIN) -exit $::env(SCRIPTS_DIR)/openroad/rcx.tcl |& tee $::env(TERMINAL_OUTPUT) $arg_values(-log)
		}
		TIMER::timer_stop
		exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "parasitics extraction - $tool"
    }
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

    use_original_lefs

    add_route_obs

	#legalize if not yet legalized
	if { ($::env(DIODE_INSERTION_STRATEGY) != 4) && ($::env(DIODE_INSERTION_STRATEGY) != 5) } {
		detailed_placement_or
	}

	# if diode insertion does *not* happen as part of global routing, then
	# we can insert fill cells early on
	if { $::env(DIODE_INSERTION_STRATEGY) != 3 } {
		ins_fill_cells
	}
	
    global_routing

	if { $::env(DIODE_INSERTION_STRATEGY) == 3 } {
		# Doing this here can be problematic and is something that needs to be
		# addressed in FastRoute since fill cells *might* occupy some of the
		# resources that were already used during global routing causing the
		# detailed router to suffer later.
		ins_fill_cells
	}

    # for LVS
    write_verilog $::env(routing_tmpfiles)/global.v -log [index_file $::env(routing_logs)/write_verilog.log]
    set_netlist $::env(routing_tmpfiles)/global.v
    if { $::env(LEC_ENABLE) } {
		logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
    }

    # detailed routing
    detailed_routing
	scrot_klayout -layout $::env(CURRENT_DEF) -log [index_file $::env(routing_logs)/screenshot.log]

	# spef extraction at the three corners 
	set ::env(SPEF_SLOWEST) [file rootname $::env(CURRENT_DEF)].ss.spef;
	set ::env(SPEF_TYPICAL) [file rootname $::env(CURRENT_DEF)].tt.spef;
	set ::env(SPEF_FASTEST) [file rootname $::env(CURRENT_DEF)].ff.spef;

    run_spef_extraction -rcx_lib $::env(LIB_SYNTH_COMPLETE) -output_spef $::env(SPEF_TYPICAL) -log [index_file $::env(routing_logs)/parasitics_extraction.tt.log]
    run_spef_extraction -rcx_lib $::env(LIB_SLOWEST) -output_spef $::env(SPEF_SLOWEST) -log [index_file $::env(routing_logs)/parasitics_extraction.ss.log]
    run_spef_extraction -rcx_lib $::env(LIB_FASTEST) -output_spef $::env(SPEF_FASTEST) -log [index_file $::env(routing_logs)/parasitics_extraction.ff.log]

	# run sta at the typical corner using the extracted spef
	set output_log [index_file $::env(routing_logs)/parasitics_sta.log]
	set ::env(FINAL_TIMING_REPORT_TAG) [index_file $::env(routing_reports)/parasitics_sta]
	set ::env(SAVE_SDF) [file rootname $::env(CURRENT_DEF)].sdf
	run_sta -log $output_log
	
	# run sta at the three corners 
	set output_log [index_file $::env(routing_logs)/parasitics_multi_corner_sta.log] 
	run_sta -log $output_log -multi_corner

	## Calculate Runtime To Routing
	set ::env(timer_routed) [clock seconds]
}

proc run_resizer_timing_routing {args} {
    if { $::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) == 1} {
		increment_index
        TIMER::timer_start
        puts_info "Running Resizer Timing Optimizations..."
        set ::env(SAVE_DEF) [index_file $::env(routing_tmpfiles)/rsz_timing.def]
	    set ::env(SAVE_SDC) [index_file $::env(routing_tmpfiles)/rsz_timing.sdc]
        try_catch $::env(OPENROAD_BIN) -exit $::env(SCRIPTS_DIR)/openroad/resizer_routing_timing.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(routing_logs)/rsz_timing_optimization.log]
        set_def $::env(SAVE_DEF)
		set ::env(CURRENT_SDC) $::env(SAVE_SDC)
		
        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "resizer timing optimizations - openroad"

        write_verilog $::env(routing_results)/$::env(DESIGN_NAME)_rsz_optimized.v -log [index_file $::env(routing_logs)/write_verilog.log]
        set_netlist $::env(routing_results)/$::env(DESIGN_NAME)_rsz_optimized.v

        if { $::env(LEC_ENABLE) && [file exists $::env(PREV_NETLIST)] } {
            logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
        }

    } else {
        puts_info "Skipping Resizer Timing Optimizations."
    }
}


package provide openlane 0.9

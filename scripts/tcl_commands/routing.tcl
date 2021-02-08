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
		puts_err "DIODE_INSERTION_STRATEGY 3 is only valid when FastRoute is used in global routing."
		puts_err "Please try a different strategy."
		return -code error
	}
	try_catch cugr \
		-lef $::env(MERGED_LEF_UNPADDED) \
		-def $::env(CURRENT_DEF) \
		-output $::env(SAVE_GUIDE) \
		-threads $::env(ROUTING_CORES) \
		|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(fastroute_log_file_tag).log 0]
	file copy -force $::env(CURRENT_DEF) $::env(SAVE_DEF)
}

proc global_routing_fastroute {args} {
	set saveLOG [index_file $::env(fastroute_log_file_tag).log 0]
	set report_tag_saver $::env(fastroute_report_file_tag)
	set ::env(fastroute_report_file_tag) [index_file $::env(fastroute_report_file_tag) 0]
	try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_groute.tcl |& tee $::env(TERMINAL_OUTPUT) $saveLOG
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
		set prevAntennaVal [exec grep "#Antenna violations:" [index_file $::env(fastroute_log_file_tag).log 0] -s | tail -1 | sed -r "s/.*\[^0-9\]//"]
		while {$iter <= $::env(GLB_RT_MAX_DIODE_INS_ITERS) && $prevAntennaVal > 0} {
			set ::env(SAVE_DEF) [index_file $::env(fastroute_tmp_file_tag)_$iter.def]
			set ::env(SAVE_GUIDE) [index_file $::env(fastroute_tmp_file_tag)_$iter.guide 0]
			set saveLOG [index_file $::env(fastroute_log_file_tag)_$iter.log 0]
			set replaceWith "INSDIODE$iter"
			try_catch python3 $::env(SCRIPTS_DIR)/replace_prefix_from_def_instances.py -op "ANTENNA" -np $replaceWith -d $::env(CURRENT_DEF)
			puts_info "FastRoute Iteration $iter"
			puts_info "Antenna Violations Previous: $prevAntennaVal"
			set ::env(fastroute_report_file_tag) [index_file $report_tag_saver 0]
			try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_groute.tcl |& tee $::env(TERMINAL_OUTPUT) $saveLOG
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
	set ::env(fastroute_report_file_tag) $report_tag_saver
	file copy -force $saveLOG $::env(fastroute_log_file_tag).log
}

proc global_routing {args} {
	puts_info "Running Global Routing..."
	TIMER::timer_start
	set ::env(SAVE_GUIDE) [index_file $::env(fastroute_tmp_file_tag).guide]
	set ::env(SAVE_DEF) [index_file $::env(fastroute_tmp_file_tag).def 0]

	if { $::env(GLOBAL_ROUTER) == "cugr" } {
		global_routing_cugr
	} else {
		global_routing_fastroute
	}

	set_def $::env(SAVE_DEF)
	set_guide $::env(SAVE_GUIDE)

	TIMER::timer_stop

	exec echo "[TIMER::get_runtime]" >> [index_file $::env(fastroute_log_file_tag)_runtime.txt 0]
	puts_info "Current Def is $::env(CURRENT_DEF)"
	puts_info "Current Guide is $::env(CURRENT_GUIDE)"
}

proc detailed_routing_tritonroute {args} {
	try_catch envsubst < $::env(SCRIPTS_DIR)/tritonRoute.param > $::env(tritonRoute_tmp_file_tag).param

	if { $::env(DETAILED_ROUTER) == "tritonroute" } {
		try_catch TritonRoute \
			$::env(tritonRoute_tmp_file_tag).param \
			|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(tritonRoute_log_file_tag).log 0]
	} else {
		try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_droute.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(tritonRoute_log_file_tag).log 0]
	}


	try_catch python3 $::env(SCRIPTS_DIR)/tr2klayout.py \
		-i $::env(tritonRoute_report_file_tag).drc \
		-o $::env(tritonRoute_report_file_tag).klayout.xml \
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
		-output $::env(tritonRoute_result_file_tag).def \
		|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(tritonRoute_log_file_tag).log 0]
}

proc detailed_routing {args} {
	puts_info "Running Detailed Routing..."
    TIMER::timer_start
	set ::env(SAVE_DEF) [index_file $::env(tritonRoute_result_file_tag).def 0]
    set report_tag_saver $::env(tritonRoute_report_file_tag)
    set ::env(tritonRoute_report_file_tag) [index_file $::env(tritonRoute_report_file_tag)]
    set tmp_tag_saver $::env(tritonRoute_tmp_file_tag)
	set ::env(tritonRoute_tmp_file_tag) [index_file $::env(tritonRoute_tmp_file_tag) 0]
	if {$::env(RUN_ROUTING_DETAILED)} {
		if { $::env(DETAILED_ROUTER) == "drcu" } {
			detailed_routing_drcu
		} else {
			detailed_routing_tritonroute
		}
	} else {
		exec echo "SKIPPED!" >> [index_file $::env(tritonRoute_log_file_tag).log 0]
	}

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> [index_file $::env(tritonRoute_log_file_tag)_runtime.txt 0]

    set_def $::env(tritonRoute_result_file_tag).def


    set ::env(tritonRoute_report_file_tag) $report_tag_saver
    set ::env(tritonRoute_tmp_file_tag) $tmp_tag_saver
}

proc ins_fill_cells_or {args} {
    handle_deprecated_command ins_fill_cells
}

proc ins_fill_cells {args} {
    puts_info "Running Fill Insertion..."
    TIMER::timer_start

    if {$::env(FILL_INSERTION)} {
	set ::env(SAVE_DEF) [index_file $::env(addspacers_tmp_file_tag).def]

	try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_fill.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(addspacers_log_file_tag).log 0]

	set_def $::env(SAVE_DEF)
    } else {
	exec echo "SKIPPED!" >> [index_file $::env(addspacers_log_file_tag).log]
	try_catch cp $::env(CURRENT_DEF) [index_file $::env(addspacers_tmp_file_tag).def 0]

	set_def [index_file $::env(addspacers_tmp_file_tag).def 0]
    }

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> [index_file $::env(addspacers_log_file_tag)_runtime.txt 0]

}

proc power_routing {args} {
    TIMER::timer_start
    puts_info "Routing top-level power"
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
    set_if_unset arg_values(-output_def) [index_file $::env(TMP_DIR)/routing/$::env(DESIGN_NAME).power_routed.def]
    set_if_unset arg_values(-extra_args) ""


    try_catch python3 $::env(SCRIPTS_DIR)/power_route.py\
	--input-lef $arg_values(-lef)\
	--input-def $arg_values(-def)\
	--core-vdd-pin $arg_values(-power)\
	--core-gnd-pin $arg_values(-ground)\
	-o $arg_values(-output_def)\
	{*}$arg_values(-extra_args) |& tee [index_file $::env(LOG_DIR)/routing/power_routed.log 0] $::env(TERMINAL_OUTPUT)

    set_def $arg_values(-output_def)
	TIMER::timer_stop
	exec echo "[TIMER::get_runtime]" >> [index_file $::env(LOG_DIR)/routing/power_routed_runtime.txt 0]
}

proc gen_pdn {args} {
    puts_info "Generating PDN..."
    TIMER::timer_start
    if {![info exists ::env(PDN_CFG)]} {
	set ::env(PDN_CFG) $::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/common_pdn.tcl
    }
    set ::env(SAVE_DEF) [index_file $::env(pdn_tmp_file_tag).def]
    try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_pdn.tcl \
	|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(pdn_log_file_tag).log 0]


    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> [index_file $::env(pdn_log_file_tag)_runtime.txt 0]

	quit_on_unconnected_pdn_nodes

    set_def $::env(SAVE_DEF)
}


proc ins_diode_cells_1 {args} {
    puts_info "Running Diode Insertion..."
	TIMER::timer_start
    set ::env(SAVE_DEF) [index_file $::env(TMP_DIR)/placement/diodes.def]

    try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_diodes.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(LOG_DIR)/placement/diodes.log 0]

    set_def $::env(SAVE_DEF)
    write_verilog $::env(yosys_result_file_tag)_diodes.v
    set_netlist $::env(yosys_result_file_tag)_diodes.v
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> [index_file $::env(LOG_DIR)/placement/diodes_runtime.txt 0]
    if { $::env(LEC_ENABLE) } {
		        logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
    }
}

proc ins_diode_cells_4 {args} {
    puts_info "Running Diode Insertion..."
	TIMER::timer_start
    set ::env(SAVE_DEF) [index_file $::env(TMP_DIR)/placement/diodes.def]

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
	try_catch python3 $::env(SCRIPTS_DIR)/place_diodes.py -l $::env(MERGED_LEF) -id $::env(CURRENT_DEF) -o $::env(SAVE_DEF) --diode-cell $::env(DIODE_CELL)  --diode-pin  $::env(DIODE_CELL_PIN) --fake-diode-cell $::antenna_cell_name  |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(LOG_DIR)/placement/diodes.log 0]

    set_def $::env(SAVE_DEF)

	# Legalize
	detailed_placement_or

	# Update netlist
	write_verilog $::env(yosys_result_file_tag)_diodes.v
	set_netlist $::env(yosys_result_file_tag)_diodes.v
	TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> [index_file $::env(LOG_DIR)/placement/diodes_runtime.txt 0]
	if { $::env(LEC_ENABLE) } {
		logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
    }
}

proc apply_route_obs {args} {
	puts_info "Adding routing obstructions..."
	# keep a warning for a while
	puts_warn "Specifying a routing obstruction is now done using the coordinates"
	puts_warn "of its bounding box instead of the now deprecated (x, y, size_x, size_y)."

	try_catch python3 $::env(SCRIPTS_DIR)/add_def_obstructions.py \
		--input-def $::env(CURRENT_DEF) \
		--lef $::env(MERGED_LEF) \
		--obstructions $::env(GLB_RT_OBS) \
		--output [file rootname $::env(CURRENT_DEF)].obs.def |& tee $::env(TERMINAL_OUTPUT) $::env(LOG_DIR)/obs.log
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
    if { $::env(RUN_SPEF_EXTRACTION) == 1 } {
        puts_info "Running SPEF Extraction..."
		TIMER::timer_start
	    set ::env(MPLCONFIGDIR) /tmp
        try_catch python3 $::env(SCRIPTS_DIR)/spef_extractor/main.py -l $::env(MERGED_LEF_UNPADDED) -d $::env(CURRENT_DEF) -mw $::env(SPEF_WIRE_MODEL) -ec $::env(SPEF_EDGE_CAP_FACTOR) |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(LOG_DIR)/routing/spef_extraction.log]
        set ::env(CURRENT_SPEF) [file rootname $::env(CURRENT_DEF)].spef
		TIMER::timer_stop
		exec echo "[TIMER::get_runtime]" >> [index_file $::env(LOG_DIR)/routing/spef_extraction_runtime.txt 0]
        # Static Timing Analysis using the extracted SPEF
        set report_tag_holder $::env(opensta_report_file_tag)
        set log_tag_holder $::env(opensta_log_file_tag)
        set ::env(opensta_report_file_tag) $::env(opensta_report_file_tag)_spef
        set ::env(opensta_log_file_tag) $::env(opensta_log_file_tag)_spef
        run_sta
        set ::env(opensta_report_file_tag) $report_tag_holder
        set ::env(opensta_log_file_tag) $log_tag_holder
    }
}
proc run_routing {args} {
    puts_info "Routing..."

    # |----------------------------------------------------|
    # |----------------   5. ROUTING ----------------------|
    # |----------------------------------------------------|
    set ::env(CURRENT_STAGE) routing
	if { [info exists ::env(DIODE_CELL)] && ($::env(DIODE_CELL) ne "") } {
		if { ($::env(DIODE_INSERTION_STRATEGY) == 1) || ($::env(DIODE_INSERTION_STRATEGY) == 2) } {
			ins_diode_cells_1
		}
		if { ($::env(DIODE_INSERTION_STRATEGY) == 4) || ($::env(DIODE_INSERTION_STRATEGY) == 5) } {
			ins_diode_cells_4
		}
    }

	# if diode insertion does *not* happen as part of global routing, then
	# we can insert fill cells early on
	if { $::env(DIODE_INSERTION_STRATEGY) != 3 } {
		ins_fill_cells
	}

    use_original_lefs

    add_route_obs

    global_routing

	if { $::env(DIODE_INSERTION_STRATEGY) == 3 } {
		# Doing this here can be problematic and is something that needs to be
		# addressed in FastRoute since fill cells *might* occupy some of the
		# resources that were already used during global routing causing the
		# detailed router to suffer later.
		ins_fill_cells
	}

    # for LVS
    write_verilog $::env(yosys_result_file_tag)_preroute.v
    set_netlist $::env(yosys_result_file_tag)_preroute.v
    if { $::env(LEC_ENABLE) } {
		logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
    }


    # detailed routing
    detailed_routing
	scrot_klayout -layout $::env(CURRENT_DEF)
	# pdngen-related hack
	# remove .extra\d+ "pins" so that magic
	# generates shapes for each stripes without the ".extra" postfix
	# until OpenDB can understand this syntax...
	exec sed \
		-i -E {/^PINS/,/^END PINS/ s/\.extra[[:digit:]]+(.*USE (GROUND|POWER))/\1/g} \
		$::env(CURRENT_DEF)

    run_spef_extraction

    ## Calculate Runtime To Routing
	calc_total_runtime -status "Routing completed" -report $::env(REPORTS_DIR)/routed_runtime.txt
}

package provide openlane 0.9

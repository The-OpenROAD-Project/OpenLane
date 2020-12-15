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

proc global_routing {args} {
    puts_info "Running Global Routing..."
    TIMER::timer_start
    set ::env(SAVE_DEF) $::env(fastroute_tmp_file_tag).def
    try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_route.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(fastroute_log_file_tag).log
    if { $::env(DIODE_INSERTION_STRATEGY) == 3 } {
        set iter 2
        set prevDEF1 $::env(SAVE_DEF)
	set prevDEF2 $::env(SAVE_DEF)
	set prevAntennaVal [exec grep "#Antenna violations:" $::env(fastroute_log_file_tag).log -s | tail -1 | sed -r "s/.*\[^0-9\]//"]
        set_def $::env(SAVE_DEF)
	while {$iter <= $::env(GLB_RT_MAX_DIODE_INS_ITERS) && $prevAntennaVal > 0} {
            set ::env(SAVE_DEF) $::env(fastroute_tmp_file_tag)_$iter.def
            set replaceWith "INSDIODE$iter"
            try_catch python3 $::env(SCRIPTS_DIR)/replace_prefix_from_def_instances.py -op "ANTENNA" -np $replaceWith -d $::env(CURRENT_DEF)
            puts_info "FastRoute Iteration $iter"
            puts_info "Antenna Violations Previous: $prevAntennaVal"
            try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_route.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(fastroute_log_file_tag)_$iter.log
            set currAntennaVal [exec grep "#Antenna violations:"  $::env(fastroute_log_file_tag)_$iter.log -s | tail -1 | sed -r "s/.*\[^0-9\]//"]
            puts_info "Antenna Violations Current: $currAntennaVal"
            if { $currAntennaVal >= $prevAntennaVal } {
                set iter [expr $iter - 1]
                set ::env(SAVE_DEF) $prevDEF1
                break
            } else {
                set prevAntennaVal $currAntennaVal
                set iter [expr $iter + 1]
                set prevDEF1 $prevDEF2
 	        set prevDEF2 $::env(SAVE_DEF)
            }
	    set_def $::env(SAVE_DEF)
        }
        set ::env(DIODE_INSERTION_STRATEGY) 0
        try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_route.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(fastroute_log_file_tag)_post_antenna.log
        set ::env(DIODE_INSERTION_STRATEGY) 3
    }
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> $::env(fastroute_log_file_tag)_runtime.txt
    set_def $::env(SAVE_DEF)
	puts_info "Current Def is $::env(CURRENT_DEF)"
}

proc detailed_routing {args} {
    puts_info "Running Detailed Routing..."
    TIMER::timer_start
    if {$::env(RUN_ROUTING_DETAILED)} {
	try_catch envsubst < $::env(SCRIPTS_DIR)/tritonRoute.param > $::env(tritonRoute_tmp_file_tag).param

    try_catch TritonRoute \
    $::env(tritonRoute_tmp_file_tag).param \
    |& tee $::env(TERMINAL_OUTPUT) $::env(tritonRoute_log_file_tag).log

    } else {
	exec echo "SKIPPED!" >> $::env(tritonRoute_log_file_tag).log
    }
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> $::env(tritonRoute_log_file_tag)_runtime.txt
    set_def $::env(tritonRoute_result_file_tag).def

	try_catch python3 $::env(SCRIPTS_DIR)/tr2klayout.py \
		-i $::env(tritonRoute_report_file_tag).drc \
		-o $::env(tritonRoute_report_file_tag).klayout.xml \
		--design-name $::env(DESIGN_NAME)
}

proc ins_fill_cells_or {args} {
    handle_deprecated_command ins_fill_cells
}

proc ins_fill_cells {args} {
    puts_info "Running Fill Insertion..."
    TIMER::timer_start

    if {$::env(FILL_INSERTION)} {
	set ::env(SAVE_DEF) $::env(addspacers_tmp_file_tag).def

	try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_fill.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(addspacers_log_file_tag).log

	set_def $::env(addspacers_tmp_file_tag).def
    } else {
	exec echo "SKIPPED!" >> $::env(addspacers_log_file_tag).log
	try_catch cp $::env(CURRENT_DEF) $::env(addspacers_tmp_file_tag).def

	set_def $::env(addspacers_tmp_file_tag).def
    }

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> $::env(addspacers_log_file_tag)_runtime.txt

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
    set_if_unset arg_values(-output_def) $::env(TMP_DIR)/routing/$::env(DESIGN_NAME).power_routed.def
    set_if_unset arg_values(-extra_args) ""


    try_catch python3 $::env(SCRIPTS_DIR)/power_route.py\
	--input-lef $arg_values(-lef)\
	--input-def $arg_values(-def)\
	--core-vdd-pin $arg_values(-power)\
	--core-gnd-pin $arg_values(-ground)\
	-o $arg_values(-output_def)\
	{*}$arg_values(-extra_args) |& tee $::env(LOG_DIR)/routing/power_routed.log $::env(TERMINAL_OUTPUT)
    set_def $arg_values(-output_def)
}

proc gen_pdn {args} {
    puts_info "Generating PDN..."
    TIMER::timer_start
    if {![info exists ::env(PDN_CFG)]} {
	set ::env(PDN_CFG) $::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/common_pdn.tcl
    }

    try_catch openroad -exit $::env(SCRIPTS_DIR)/new_pdn.tcl \
	|& tee $::env(TERMINAL_OUTPUT) $::env(pdn_log_file_tag).log

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> $::env(pdn_log_file_tag)_runtime.txt
    set_def $::env(pdn_tmp_file_tag).def
}


proc ins_diode_cells_1 {args} {
    puts_info "Running Diode Insertion..."
    set ::env(SAVE_DEF) $::env(TMP_DIR)/placement/diodes.def

    try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_diodes.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(LOG_DIR)/placement/diodes.log

    set_def $::env(TMP_DIR)/placement/diodes.def
    write_verilog $::env(yosys_result_file_tag)_diodes.v
    set_netlist $::env(yosys_result_file_tag)_diodes.v
    if { $::env(LEC_ENABLE) } {
		        logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
    }
}

proc ins_diode_cells_4 {args} {
    puts_info "Running Diode Insertion..."
    set ::env(SAVE_DEF) $::env(TMP_DIR)/placement/diodes.def

    # Select diode cell
	if { $::env(DIODE_INSERTION_STRATEGY) == 5 && [info exists ::env(FAKEDIODE_CELL)]} {
		set ::antenna_cell_name $::env(FAKEDIODE_CELL)
	} else {
		set ::antenna_cell_name $::env(DIODE_CELL)
	}

	# Custom script
	try_catch python3 $::env(SCRIPTS_DIR)/place_diodes.py -l $::env(MERGED_LEF) -id $::env(CURRENT_DEF) -o $::env(SAVE_DEF) --diode-cell $::env(DIODE_CELL)  --diode-pin  $::env(DIODE_CELL_PIN) --fake-diode-cell $::antenna_cell_name  |& tee $::env(TERMINAL_OUTPUT) $::env(LOG_DIR)/placement/diodes.log

	set_def $::env(TMP_DIR)/placement/diodes.def

	# Legalize
	detailed_placement_or

	# Update netlist
	write_verilog $::env(yosys_result_file_tag)_diodes.v
	set_netlist $::env(yosys_result_file_tag)_diodes.v
	if { $::env(LEC_ENABLE) } {
		logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
    }
}

proc add_route_obs {args} {
    if {![info exists ::env(GLB_RT_OBS)]} {
        return
    }

    puts_info "Adding routing obstructions..."

    set obs_list [split $::env(GLB_RT_OBS) ","]
    set obs_idx 0
    foreach obs $obs_list {
        add_macro_obs \
            -defFile $::env(CURRENT_DEF) \
            -lefFile $::env(MERGED_LEF_UNPADDED) \
            -obstruction "core_obs_${obs_idx}" \
            -placementX [lindex $obs 1] \
            -placementY [lindex $obs 2] \
            -sizeWidth  [lindex $obs 3] \
            -sizeHeight [lindex $obs 4] \
            -fixed 1 \
            -layerNames [lindex $obs 0]
        incr obs_idx
    }
}

proc run_spef_extraction {args} {
    if { $::env(RUN_SPEF_EXTRACTION) == 1 } {
        puts_info "Running SPEF Extraction..."
	set ::env(MPLCONFIGDIR) /tmp
        try_catch python3 $::env(SCRIPTS_DIR)/spef_extractor/main.py -l $::env(MERGED_LEF_UNPADDED) -d $::env(CURRENT_DEF) -mw $::env(SPEF_WIRE_MODEL) -ec $::env(SPEF_EDGE_CAP_FACTOR) |& tee $::env(TERMINAL_OUTPUT) $::env(LOG_DIR)/routing/spef_extraction.log
        set ::env(CURRENT_SPEF) [file rootname $::env(CURRENT_DEF)].spef
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
    use_original_lefs

    global_routing

    # insert fill_cells
    ins_fill_cells

    # for LVS
    write_verilog $::env(yosys_result_file_tag)_preroute.v
    set_netlist $::env(yosys_result_file_tag)_preroute.v
    if { $::env(LEC_ENABLE) } {
		logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
    }


    # detailed routing
    add_route_obs
    detailed_routing

	# pdngen-related hack
	# remove .extra\d+ "pins" so that magic
	# generates shapes for each stripes without the ".extra" postfix
	# until OpenDB can understand this syntax...
	exec sed \
		-i -E {/^PINS/,/^END PINS/ s/\.extra[[:digit:]]+(.*USE (GROUND|POWER))/\1/g} \
		$::env(CURRENT_DEF)

    run_spef_extraction

    ## TIMER END
    set timer_end [clock seconds]
    set timer_start $::env(timer_start)
    set datetime $::env(datetime)

    set runtime_s [expr {($timer_end - $timer_start)}]
    set runtime_h [expr {$runtime_s/3600}]

    set runtime_s [expr {$runtime_s-$runtime_h*3600}]
    set runtime_m [expr {$runtime_s/60}]

    set runtime_s [expr {$runtime_s-$runtime_m*60}]
    set routing_status  "Routing completed for $::env(DESIGN_NAME)/$datetime in ${runtime_h}h${runtime_m}m${runtime_s}s"
    puts_info $routing_status
    set runtime_log [open $::env(REPORTS_DIR)/runtime.txt w]
    puts $runtime_log $routing_status
    close $runtime_log
}

package provide openlane 0.9

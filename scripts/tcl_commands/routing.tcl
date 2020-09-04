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

proc global_routing {args} {
    TIMER::timer_start
    try_catch envsubst < $::env(GLB_RT_SCRIPT) > $::env(fastroute_tmp_file_tag).tcl
    cd $::env(OPENLANE_ROOT)/etc
    try_catch FastRoute -c 1 < $::env(fastroute_tmp_file_tag).tcl \
	|& tee $::env(TERMINAL_OUTPUT) $::env(fastroute_log_file_tag).log
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> $::env(fastroute_log_file_tag)_runtime.txt
    cd $::env(OPENLANE_ROOT)
}

proc global_routing_or {args} {
    TIMER::timer_start
    set ::env(SAVE_DEF) $::env(CURRENT_DEF)
    try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_route.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(fastroute_log_file_tag).log
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> $::env(fastroute_log_file_tag)_runtime.txt
    set_def $::env(SAVE_DEF)
}

proc detailed_routing {args} {
    TIMER::timer_start
    if {$::env(RUN_ROUTING_DETAILED)} {
	try_catch envsubst < $::env(SCRIPTS_DIR)/tritonRoute.param > $::env(tritonRoute_tmp_file_tag).param

	if {$::env(ROUTING_STRATEGY) == 14} {
	    try_catch TritonRoute14 \
		$::env(tritonRoute_tmp_file_tag).param \
		|& tee $::env(TERMINAL_OUTPUT) $::env(tritonRoute_log_file_tag).log
	} else {
	    try_catch TritonRoute \
		$::env(tritonRoute_tmp_file_tag).param \
		|& tee $::env(TERMINAL_OUTPUT) $::env(tritonRoute_log_file_tag).log
	}
    } else {
	exec echo "SKIPPED!" >> $::env(tritonRoute_log_file_tag).log
    }
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> $::env(tritonRoute_log_file_tag)_runtime.txt
    set_def $::env(tritonRoute_result_file_tag).def
}

proc ins_fill_cells {args} {
    TIMER::timer_start
    if {$::env(FILL_INSERTION)} {
	try_catch sh $::env(SCRIPTS_DIR)/addspacers.sh\
	    $::env(DECAP_CELL) $::env(MERGED_LEF_UNPADDED) $::env(CURRENT_DEF) $::env(addspacers_tmp_file_tag)_0.def\
	    |& tee $::env(TERMINAL_OUTPUT) $::env(addspacers_log_file_tag)_0.log
	set_def $::env(addspacers_tmp_file_tag)_0.def

	try_catch sh $::env(SCRIPTS_DIR)/addspacers.sh\
	    $::env(FILL_CELL) $::env(MERGED_LEF_UNPADDED) $::env(CURRENT_DEF) $::env(addspacers_tmp_file_tag)_1.def\
	    |& tee $::env(TERMINAL_OUTPUT) $::env(addspacers_log_file_tag)_1.log
	set_def $::env(addspacers_tmp_file_tag)_1.def
    } else {
	exec echo "SKIPPED!" >> $::env(addspacers_log_file_tag).log
	try_catch cp $::env(CURRENT_DEF) $::env(addspacers_tmp_file_tag).def
	set_def $::env(addspacers_tmp_file_tag).def
    }
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> $::env(addspacers_log_file_tag)_runtime.txt
}

proc ins_fill_cells_or {args} {
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

proc run_routing {args} {
    puts_info "Routing..."

    # |----------------------------------------------------|
    # |----------------   5. ROUTING ----------------------|
    # |----------------------------------------------------|
    set ::env(CURRENT_STAGE) routing
    if { $::env(DIODE_INSERTION_STRATEGY) > 0  && [info exists ::env(DIODE_CELL)] } {
	if { $::env(DIODE_CELL) ne "" } {
	    ins_diode_cells
	}
    }
    use_original_lefs
    # insert fill_cells
    ins_fill_cells_or
    # fastroute global 6_routing
    # li1_hack_start

    # for LVS
    write_verilog $::env(yosys_result_file_tag)_preroute.v
    set_netlist $::env(yosys_result_file_tag)_preroute.v
    if { $::env(LEC_ENABLE) } {
	logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
    }

    if { $::env(LVS_INSERT_POWER_PINS) } {
	write_powered_verilog
	set_netlist $::env(lvs_result_file_tag).powered.v
    }

    # Unmatched ports would be detected. Need another way to check this.
    # if { $::env(LEC_ENABLE) } {
    # 	logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
    # }

    global_routing_or
    # li1_hack_end


    # detailed routing
    detailed_routing

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

proc gen_pdn {args} {
    puts "\[INFO\]: Generating PDN..."
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


proc ins_diode_cells {args} {
    set ::env(SAVE_DEF) $::env(TMP_DIR)/placement/diodes.def


    try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_diodes.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(LOG_DIR)/placement/diodes.log




    set_def $::env(TMP_DIR)/placement/diodes.def
    write_verilog $::env(yosys_result_file_tag)_diodes.v
    set_netlist $::env(yosys_result_file_tag)_diodes.v
    if { $::env(LEC_ENABLE) } {
	logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
    }

}


package provide openlane 0.9

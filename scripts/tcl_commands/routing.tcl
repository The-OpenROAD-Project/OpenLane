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

		try_catch TritonRoute \
			$::env(tritonRoute_tmp_file_tag).param \
			|& tee $::env(TERMINAL_OUTPUT) $::env(tritonRoute_log_file_tag).log
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
	# insert fill_cells
	ins_fill_cells_or
	# fastroute global 6_routing
	# li1_hack_start

	# for LVS
	write_verilog $::env(yosys_result_file_tag)_preroute.v
	set_netlist $::env(yosys_result_file_tag)_preroute.v

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
		set ::env(PDN_CFG) $::env(OPENLANE_ROOT)/pdks/$::env(PDK)/libs.tech/openlane/common_pdn.tcl
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

	
	if { $::env(CHECK_DIODE_PLACEMENT) == 1 } {
		check_diode_placement
	}

	set_def $::env(TMP_DIR)/placement/diodes.def
	set_netlist $::env(yosys_result_file_tag)_diodes.v
}


package provide openlane 0.9

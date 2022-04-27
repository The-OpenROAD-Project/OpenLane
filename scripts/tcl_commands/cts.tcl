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

global script_path
set script_path [ file dirname [ file normalize [ info script ] ] ]

proc simple_cts {args} {
	puts_info "Running Simple CTS..."
	set options {
		{-verilog required}
		{-fanout required}
		{-clk_net required}
		{-root_clk_buf required}
		{-clk_buf required}
		{-clk_buf_input required}
		{-clk_buf_output required}
		{-cell_clk_port required}
		{-output required}
	}
	parse_key_args "simple_cts" args values $options
	global script_path
	set tmp $::env(synthesis_tmpfiles)/$::env(DESIGN_NAME).v
	file copy -force $values(-verilog) $tmp
	set script $script_path/../simple_cts.py
	#set values(-clk_net) [string map {\\ \\\\} $values(-clk_net)]
	try_catch $::env(OPENROAD_BIN) -python $script \
		--fanout $values(-fanout) \
		--clk-net $values(-clk_net) \
		--root-clkbuf $values(-root_clk_buf) \
		--clkbuf $values(-clk_buf) \
		--clkbuf-input-pin $values(-clk_buf_input) \
		--clkbuf-output-pin $values(-clk_buf_output) \
		--clk-port $values(-cell_clk_port) \
		--output $values(-output) \
		$tmp
}


proc run_cts {args} {
	if { ! [info exists ::env(CLOCK_PORT)] && ! [info exists ::env(CLOCK_NET)] } {
		puts_info "::env(CLOCK_PORT) is not set"
		puts_warn "Skipping CTS..."
		set ::env(CLOCK_TREE_SYNTH) 0
	}

	if {$::env(CLOCK_TREE_SYNTH) && !$::env(RUN_SIMPLE_CTS)} {
		increment_index
		puts_info "Running Clock Tree Synthesis..."
		set ::env(CURRENT_STAGE) cts
		TIMER::timer_start

		if { ! [info exists ::env(CLOCK_NET)] } {
			set ::env(CLOCK_NET) $::env(CLOCK_PORT)
		}

		set ::env(SAVE_DEF) $::env(cts_results)/$::env(DESIGN_NAME).def
		set ::env(SAVE_SDC) $::env(cts_results)/$::env(DESIGN_NAME).sdc
		set report_tag_holder $::env(cts_reports)
		set ::env(cts_reports) [ index_file $::env(cts_reports)/cts.rpt ]
		# trim the lib to exclude cells with drc errors
		if { ! [info exists ::env(LIB_CTS) ] } {
			set ::env(LIB_CTS) $::env(cts_tmpfiles)/cts.lib
			trim_lib -input $::env(LIB_SYNTH_COMPLETE) -output $::env(LIB_CTS) -drc_exclude_only
		}
		run_openroad_script $::env(SCRIPTS_DIR)/openroad/cts.tcl -indexed_log [index_file $::env(cts_logs)/cts.log]
		check_cts_clock_nets
		set ::env(cts_reports) $report_tag_holder
		TIMER::timer_stop
		exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "cts"

		set_def $::env(SAVE_DEF)
		set ::env(CURRENT_SDC) $::env(SAVE_SDC)
		write_verilog $::env(cts_results)/$::env(DESIGN_NAME).v -log $::env(cts_logs)/write_verilog.log
		set_netlist $::env(cts_results)/$::env(DESIGN_NAME).v
		if { $::env(LEC_ENABLE) } {
			logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
		}
		scrot_klayout -layout $::env(CURRENT_DEF) -log $::env(cts_logs)/screenshot.log
	} elseif { $::env(RUN_SIMPLE_CTS) } {
		exec echo "Simple CTS was run earlier." >> [index_file $::env(cts_logs)/cts.log]
	} else {
		exec echo "SKIPPED!" >> [index_file $::env(cts_logs)/cts.log]
	}

}

proc run_resizer_timing {args} {
	if { $::env(PL_RESIZER_TIMING_OPTIMIZATIONS) == 1} {
		increment_index
		TIMER::timer_start
		puts_info "Running Placement Resizer Timing Optimizations..."
		set ::env(SAVE_DEF) [index_file $::env(cts_tmpfiles)/resizer_timing.def]
		set ::env(SAVE_SDC) [index_file $::env(cts_tmpfiles)/resizer_timing.sdc]
		run_openroad_script $::env(SCRIPTS_DIR)/openroad/resizer_timing.tcl -indexed_log [index_file $::env(cts_logs)/resizer.log]
		set_def $::env(SAVE_DEF)
		set ::env(CURRENT_SDC) $::env(SAVE_SDC)

		TIMER::timer_stop
		exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "resizer timing optimizations - openroad"

		write_verilog $::env(cts_results)/$::env(DESIGN_NAME).resized.v -log $::env(cts_logs)/write_verilog.log
		set_netlist $::env(cts_results)/$::env(DESIGN_NAME).resized.v

		if { $::env(LEC_ENABLE) && [file exists $::env(PREV_NETLIST)] } {
			logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
		}

	} else {
		puts_info "Skipping Placement Resizer Timing Optimizations."
	}
}


package provide openlane 0.9

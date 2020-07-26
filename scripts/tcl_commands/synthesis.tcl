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

proc get_yosys_bin {} {
	set synth_bin yosys
	if { [info exists ::env(SYNTH_BIN)] } {
		set synth_bin $::env(SYNTH_BIN)
	}
	return $synth_bin
}

proc run_yosys {args} {
	set ::env(CURRENT_STAGE) synthesis
	TIMER::timer_start

	try_catch [get_yosys_bin] \
		-c $::env(SYNTH_SCRIPT) \
		-l $::env(yosys_log_file_tag).log \
		|& tee $::env(TERMINAL_OUTPUT)

	set_netlist $::env(yosys_result_file_tag).v
	if { $::env(LEC_ENABLE) && [file exists $::env(PREV_NETLIST)] } {
		logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
	}

	try_catch sta $::env(SCRIPTS_DIR)/sta.tcl \
		|& tee $::env(TERMINAL_OUTPUT) $::env(opensta_log_file_tag).log

	TIMER::timer_stop
	exec echo "[TIMER::get_runtime]" >> $::env(yosys_log_file_tag)_runtime.txt
}

proc run_synthesis {args} {
	puts "\[INFO\]: Running Synthesis..."
		# in-place insertion
	run_yosys
	if {$::env(RUN_SIMPLE_CTS)} {
		simple_cts \
			-verilog $::env(yosys_result_file_tag).v \
			-fanout $::env(CLOCK_BUFFER_FANOUT) \
			-clk_net $::env(CLOCK_NET) \
			-root_clk_buf $::env(ROOT_CLK_BUFFER) \
			-clk_buf $::env(CLK_BUFFER) \
			-clk_buf_input $::env(CLK_BUFFER_INPUT) \
			-clk_buf_output $::env(CLK_BUFFER_OUTPUT) \
			-cell_clk_port $::env(CELL_CLK_PORT) \
			-output $::env(yosys_result_file_tag).v
	}
#        verilog_to_verilogPower -input $::env(yosys_result_file_tag).v -output $::env(yosys_tmp_file_tag).v -power $::env(VDD_PIN) -ground $::env(GND_PIN) -lef $::env(MERGED_LEF)
#	exec cp $::env(yosys_tmp_file_tag).v $::env(yosys_result_file_tag).v

	if { $::env(CHECK_UNMAPPED_CELLS) == 1 } {
		check_unmapped_cells
	}

	if { $::env(CHECK_ASSIGN_STATEMENTS) == 1 } {
		check_assign_statements
	}

	if { $::env(CHECK_LATCHES_IN_DESIGN) == 1 } {
		check_synthesis_failure
	}

}

proc verilog_elaborate {args} {
	set synth_script_old $::env(SYNTH_SCRIPT)
	set ::env(SYNTH_SCRIPT) $::env(SCRIPTS_DIR)/synth_top.tcl
	run_yosys
	set ::env(SYNTH_SCRIPT) $synth_script_old
}


proc logic_equiv_check {args} {
	set options {\
	  {-lhs required}\
	  {-rhs required}\
	}

	set flags {}

	set args_copy $args
	parse_key_args "logic_equiv_check" args arg_values $options flags_map $flags

	set ::env(LEC_LHS_NETLIST) $arg_values(-lhs)
	set ::env(LEC_RHS_NETLIST) $arg_values(-rhs)

	puts_info "Running LEC: $::env(LEC_LHS_NETLIST) Vs. $::env(LEC_RHS_NETLIST)"

	if { [catch {exec [get_yosys_bin] \
		-c $::env(SCRIPTS_DIR)/logic_equiv_check.tcl \
		-l $::env(yosys_log_file_tag).equiv.log \
		|& tee $::env(TERMINAL_OUTPUT)}] } {

		puts_err "$::env(LEC_LHS_NETLIST) is not logically equivalent to $::env(LEC_RHS_NETLIST)"
		return -code error
	}

	puts_info "$::env(PREV_NETLIST) and $::env(CURRENT_NETLIST) are proven equivalent"
	return -code ok
}

package provide openlane 0.9

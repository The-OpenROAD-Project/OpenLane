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

    set options {
	{-output optional}
    }
    set flags {}
    parse_key_args "run_yosys" args arg_values $options flags_map $flags

    if { [info exists arg_values(-output)] } {
	set ::env(SAVE_NETLIST) $arg_values(-output)
    } else {
	set ::env(SAVE_NETLIST) $::env(yosys_result_file_tag).v
    }

	if { [file exists $::env(SAVE_NETLIST)] } {
		puts_warn "A netlist at $::env(SAVE_NETLIST) already exists..."
		puts_warn "Skipping synthesis"
	} else {
		try_catch [get_yosys_bin] \
			-c $::env(SYNTH_SCRIPT) \
			-l $::env(yosys_log_file_tag).log \
			|& tee $::env(TERMINAL_OUTPUT)
	}

    set_netlist $::env(SAVE_NETLIST)
    if { $::env(LEC_ENABLE) && [file exists $::env(PREV_NETLIST)] } {
	logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
    }

    # The following is a naive workaround to the defparam issue.. it should be handled with
    # an issue to the OpenROAD verilog parser.
    if { [info exists ::env(SYNTH_EXPLORE)] && $::env(SYNTH_EXPLORE) } {
        puts_info "This is a Synthesis Exploration and so no need to remove the defparam lines."
    } else {
        try_catch sed -ie {/defparam/d} $::env(CURRENT_NETLIST)
    }
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> $::env(yosys_log_file_tag)_runtime.txt
}

proc run_sta {args} {
    puts_info "Running Static Timing Analysis..."
    if {[info exists ::env(CLOCK_PORT)]} {
        try_catch sta $::env(SCRIPTS_DIR)/sta.tcl \
        |& tee $::env(TERMINAL_OUTPUT) $::env(opensta_log_file_tag).log
    } else {
        puts_warn "No CLOCK_PORT found. Skipping STA..."
    }
}

proc run_synth_exploration {args} {
    puts_info "Running Synthesis Exploration..."

    set ::env(SYNTH_EXPLORE) 1

    run_yosys

    try_catch perl $::env(SCRIPTS_DIR)/synth_exp/analyze.pl $::env(yosys_log_file_tag).log > $::env(yosys_report_file_tag).exploration.html
    file copy $::env(SCRIPTS_DIR)/synth_exp/table.css $::env(REPORTS_DIR)/synthesis
    file copy $::env(SCRIPTS_DIR)/synth_exp/utils.js $::env(REPORTS_DIR)/synthesis
}

proc run_synthesis {args} {
    puts_info "Running Synthesis..."
    # in-place insertion
    run_yosys

    run_sta

    if {$::env(RUN_SIMPLE_CTS)} {
		if { ! [info exists ::env(CLOCK_NET)] } {
			set ::env(CLOCK_NET) $::env(CLOCK_PORT)
		}
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

    if { $::env(CHECK_ASSIGN_STATEMENTS) == 1 } {
	check_assign_statements
    }

    if { $::env(CHECK_UNMAPPED_CELLS) == 1 } {
	check_synthesis_failure
    }
}

proc verilog_elaborate {args} {
    # usually run on structural verilog (top-level netlists)
    set synth_script_old $::env(SYNTH_SCRIPT)
    set ::env(SYNTH_SCRIPT) $::env(SCRIPTS_DIR)/synth_top.tcl
    run_yosys {*}$args
    set ::env(SYNTH_SCRIPT) $synth_script_old
}

proc yosys_rewrite_verilog {filename} {
    if { ! [file exists $filename] } {
	puts_err "$filename does not exist to be re-written"
	return -code error
    }


    set ::env(SAVE_NETLIST) $filename

    puts_info "Rewriting $filename into $::env(SAVE_NETLIST)"

    try_catch [get_yosys_bin] \
	-c $::env(SCRIPTS_DIR)/yosys_rewrite_verilog.tcl \
	-l $::env(yosys_log_file_tag)_rewrite_verilog.log; # \
	|& tee $::env(TERMINAL_OUTPUT)
}


proc logic_equiv_check {args} {
    set options {
	{-lhs required}
	{-rhs required}
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

    puts_info "$::env(LEC_LHS_NETLIST) and $::env(LEC_RHS_NETLIST) are proven equivalent"
    return -code ok
}

package provide openlane 0.9

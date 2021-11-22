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

global script_path
set script_path [ file dirname [ file normalize [ info script ] ] ]

proc set_core_dims {args} {
	puts_info "Setting Core Dimensions..."
	set options {{-log_path required}}
	parse_key_args "set_core_dims" args values $options
	set log_path $values(-log_path)
	set FpOutDef $::env(CURRENT_DEF)
	set def_units $::env(DEF_UNITS_PER_MICRON)
	set coreinfo [join [exec $::env(SCRIPTS_DIR)/extract_coreinfo.sh $FpOutDef] " "]
	set sites_per_row [lindex $coreinfo 8]
	set step [lindex $coreinfo 9]
	set core_area_llx [expr { [lindex $coreinfo 4]/double($def_units) }]
	set core_area_urx [expr { ([lindex $coreinfo 6]+$step*$sites_per_row)/double($def_units) }]
	set core_area_lly [expr { [lindex $coreinfo 5]/double($def_units) }]
	set core_area_ury [expr { [lindex $coreinfo 7]/double($def_units) }]
	set ::env(CORE_WIDTH) [expr {$core_area_urx - $core_area_llx} ]
	set ::env(CORE_HEIGHT) [expr {$core_area_ury - $core_area_lly} ]
	puts "$::env(CORE_WIDTH) $::env(CORE_HEIGHT)"
}

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
	set script $script_path/../cts/cts_simple.pl
	#set values(-clk_net) [string map {\\ \\\\} $values(-clk_net)]
	try_catch $script \
		$tmp \
		$values(-fanout) \
		$values(-clk_net) \
		$values(-root_clk_buf) \
		$values(-clk_buf) \
		$values(-clk_buf_input) \
		$values(-clk_buf_output) \
		$values(-cell_clk_port) \
		|& tee $values(-output)
}


proc run_cts {args} {
	if { ! [info exists ::env(CLOCK_PORT)] && ! [info exists ::env(CLOCK_NET)] } {
		puts_info "::env(CLOCK_PORT) is not set"
		puts_warn "Skipping CTS..."
		set ::env(CLOCK_TREE_SYNTH) 0
	}

	if {$::env(CLOCK_TREE_SYNTH) && !$::env(RUN_SIMPLE_CTS)} {
		increment_index
		puts_info "Running TritonCTS..."
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
		try_catch $::env(OPENROAD_BIN) -exit $::env(SCRIPTS_DIR)/openroad/cts.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(cts_logs)/cts.log]
		check_cts_clock_nets
		set ::env(cts_reports) $report_tag_holder
		TIMER::timer_stop
		exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "cts"

		set_def $::env(SAVE_DEF)
		set ::env(CURRENT_SDC) $::env(SAVE_SDC)
		write_verilog $::env(cts_results)/$::env(DESIGN_NAME).v -log [index_file $::env(cts_logs)/write_verilog.log]
		set_netlist $::env(cts_results)/$::env(DESIGN_NAME).v
		if { $::env(LEC_ENABLE) } {
			logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
		}
		scrot_klayout -layout $::env(CURRENT_DEF) -log [index_file $::env(cts_logs)/screenshot.log]
	} elseif { $::env(RUN_SIMPLE_CTS) } {
		increment_index
		exec echo "Simple CTS was run earlier." >> [index_file $::env(cts_logs)/cts.log]
	} else {
		increment_index
		exec echo "SKIPPED!" >> [index_file $::env(cts_logs)/cts.log]
	}

}

package provide openlane 0.9

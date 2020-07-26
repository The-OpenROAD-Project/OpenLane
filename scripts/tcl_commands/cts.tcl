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
	set options {{-log_path required}}
	parse_key_args "set_core_dims" args values $options
	set log_path $values(-log_path)
	set FpOutDef $::env(ioPlacer_tmp_file_tag).def
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
	set tmp $::env(yosys_tmp_file_tag).v
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
		puts "\[INFO\]: Running TritonCTS..."
		set ::env(CURRENT_STAGE) cts
		TIMER::timer_start
		if {$::env(CLOCK_TREE_SYNTH)} {
			set ::env(SAVE_DEF) $::env(cts_result_file_tag).def
			try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_cts.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(cts_log_file_tag).log
		} else {
			exec echo "SKIPPED!" >> $::env(cts_log_file_tag).log
			try_catch cp $::env(opendp_result_file_tag).def $::env(cts_result_file_tag).def
		}
		TIMER::timer_stop
		exec echo "[TIMER::get_runtime]" >> $::env(cts_log_file_tag)_runtime.txt

		set_def $::env(SAVE_DEF)
		set_netlist $::env(yosys_result_file_tag)_cts.v
		if { $::env(LEC_ENABLE) } {
			logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
		}
}

package provide openlane 0.9

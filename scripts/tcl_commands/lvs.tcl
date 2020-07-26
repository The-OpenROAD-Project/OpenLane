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

proc verilog_to_verilogPower {args} {
	set options {{-input required} \
			{-output required} \
			{-lef required} \
			{-power required} \
			{-ground required}}
	set flags {}
	parse_key_args "verilog_to_verilogPower" args arg_values $options flags_map $flags
	set bin vlog2Verilog
	set in $arg_values(-input)
	set out $arg_values(-output)
	set power $arg_values(-power)
	set gnd $arg_values(-ground)
	set lef $arg_values(-lef)

	try_catch $bin \
		-v $power \
		-g $gnd \
		-l $lef \
		$in |& tee $out
}

proc run_netgen {args} {
	puts_info "Running LVS..."

	set spice_in $::env(magic_result_file_tag).spice
	set module_name $::env(DESIGN_NAME)
	set verilog_in $::env(lvs_result_file_tag).v
	set setup_file $::env(NETGEN_SETUP_FILE)
	set output $::env(lvs_result_file_tag).log

	puts_info "$spice_in against $::env(CURRENT_NETLIST)"
	 
	verilog_to_verilogPower -input $::env(CURRENT_NETLIST) -output $verilog_in -lef $::env(MERGED_LEF) \
		-power $::env(VDD_PIN) -ground $::env(GND_PIN)
	try_catch netgen -batch lvs \
		"$spice_in $module_name" \
		"$verilog_in $module_name" \
		$setup_file \
		$output \
		-json |& tee $::env(TERMINAL_OUTPUT) $::env(lvs_log_file_tag).log
	exec python3 $::env(SCRIPTS_DIR)/count_lvs.py -f $::env(lvs_result_file_tag).json \
		|& tee $::env(TERMINAL_OUTPUT) $::env(lvs_result_file_tag)_parsed.log
}

package provide openlane 0.9

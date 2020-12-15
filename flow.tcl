#!/usr/bin/tclsh
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


set ::env(OPENLANE_ROOT) [file dirname [file normalize [info script]]]

lappend ::auto_path "$::env(OPENLANE_ROOT)/scripts/"
package require openlane; # provides the utils as well

proc run_non_interactive_mode {args} {
	set options {
		{-design required}
		{-save_path optional}
	}
	set flags {-save}
	parse_key_args "run_non_interactive_mode" args arg_values $options flags_map $flags -no_consume

	prep {*}$args

	run_synthesis
	run_floorplan
	run_placement
	run_cts
	run_routing

	if { ($::env(DIODE_INSERTION_STRATEGY) == 2) || ($::env(DIODE_INSERTION_STRATEGY) == 5) } {
		run_antenna_check
		heal_antenna_violators; # modifies the routed DEF
	}

    if { $::env(LVS_INSERT_POWER_PINS) } {
		write_powered_verilog
		set_netlist $::env(lvs_result_file_tag).powered.v
    }

	run_magic

	run_magic_spice_export

	if {  [info exists flags_map(-save) ] } {
		if { ! [info exists arg_values(-save_path)] } {
			set arg_values(-save_path) ""
		}
		save_views 	-lef_path $::env(magic_result_file_tag).lef \
			-def_path $::env(tritonRoute_result_file_tag).def \
			-gds_path $::env(magic_result_file_tag).gds \
			-mag_path $::env(magic_result_file_tag).mag \
			-maglef_path $::env(magic_result_file_tag).lef.mag \
			-spice_path $::env(magic_result_file_tag).spice \
			-verilog_path $::env(CURRENT_NETLIST) \
			-save_path $arg_values(-save_path) \
			-tag $::env(RUN_TAG)
	}

	# Physical verification

	run_magic_drc

	run_lvs; # requires run_magic_spice_export

	run_antenna_check

	run_lef_cvc

	generate_final_summary_report

	puts_success "Flow Completed Without Fatal Errors."
}

proc run_interactive_mode {args} {
	set options {
		{-design optional}
	}
	set flags {}
	parse_key_args "run_interactive_mode" args arg_values $options flags_map $flags -no_consume

	if { [info exists arg_values(-design)] } {
		prep {*}$args
	}

	set ::env(TCLLIBPATH) $::auto_path
	exec tclsh >&@stdout
}

proc run_magic_drc_batch {args} {
	set options {
		{-magicrc optional}
		{-tech optional}
		{-report required}
		{-design required}
		{-gds required}
	}
	set flags {}
	parse_key_args "run_magic_drc_batch" args arg_values $options flags_mag $flags
	if { [info exists arg_values(-magicrc)] } {
		set magicrc [file normalize $arg_values(-magicrc)]
	}
	if { [info exists arg_values(-tech)] } {
		set ::env(TECH) [file normalize $arg_values(-tech)]
	}
	set ::env(GDS_INPUT) [file normalize $arg_values(-gds)]
	set ::env(REPORT_OUTPUT) [file normalize $arg_values(-report)]
	set ::env(DESIGN_NAME) $arg_values(-design)

	if { [info exists magicrc] } {
		exec magic \
			-noconsole \
			-dnull \
			-rcfile $magicrc \
			$::env(OPENLANE_ROOT)/scripts/magic/drc_batch.tcl \
			</dev/null |& tee /dev/tty
	} else {
		exec magic \
			-noconsole \
			-dnull \
			$::env(OPENLANE_ROOT)/scripts/magic/drc_batch.tcl \
			</dev/null |& /dev/tty
	}
}

proc run_file {args} {
	set ::env(TCLLIBPATH) $::auto_path
	exec tclsh {*}$args >&@stdout
}

set options {
	{-file optional}
}

set flags {-interactive -it -drc -synth_explore}

parse_key_args "flow.tcl" argv arg_values $options flags_map $flags -no_consume

puts_info {
	___   ____   ___  ____   _       ____  ____     ___
	/   \ |    \ /  _]|    \ | |     /    ||    \   /  _]
	|     ||  o  )  [_ |  _  || |    |  o  ||  _  | /  [_
	|  O  ||   _/    _]|  |  || |___ |     ||  |  ||    _]
	|     ||  | |   [_ |  |  ||     ||  _  ||  |  ||   [_
	\___/ |__| |_____||__|__||_____||__|__||__|__||_____|

}
if {[catch {exec git --git-dir $::env(OPENLANE_ROOT)/.git describe --tags} ::env(OPENLANE_VERSION)]} {
	# if no tags yet
	if {[catch {exec git --git-dir $::env(OPENLANE_ROOT)/.git log --pretty=format:'%h' -n 1} ::env(OPENLANE_VERSION)]} {
		set ::env(OPENLANE_VERSION) "N/A"
	}
}

puts_info "Version: $::env(OPENLANE_VERSION)"

if { [info exists flags_map(-interactive)] || [info exists flags_map(-it)] } {
	puts_info "Running interactively"
	if { [info exists arg_values(-file)] } {
		run_file [file normalize $arg_values(-file)] {*}$argv
	} else {
		run_interactive_mode {*}$argv
	}
} elseif { [info exists flags_map(-drc)] } {
	run_magic_drc_batch {*}$argv
} elseif { [info exists flags_map(-synth_explore)] } {
	prep {*}$argv
	run_synth_exploration
} else {
	puts_info "Running non-interactively"
	run_non_interactive_mode {*}$argv
}

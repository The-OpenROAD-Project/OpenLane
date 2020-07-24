#!/usr/bin/tclsh8.5

# Copyright (c) Efabless Corporation. All rights reserved.
# See LICENSE file in the project root for full license information.

set ::env(OPENLANE_ROOT) [file dirname [file normalize [info script]]]

lappend ::auto_path "$::env(OPENLANE_ROOT)/scripts/"
package require openlane; # provides the utils as well

proc run_non_interactive_mode {args} {
	set args_copy $args
	set options {\
	    {-design required}\
	    {-save_path optional}\
	}
	set flags {-save}
	parse_key_args "run_non_interactive_mode" args_copy arg_values $options flags_map $flags

	prep {*}$args

	run_synthesis
	run_floorplan
	run_placement
	run_cts
	gen_pdn
	run_routing

	run_magic_spice_export

	if { $::env(DIODE_INSERTION_STRATEGY) == 2 } {
	    run_magic_antenna_check; # produces a report of violators; extraction!
	    heal_antenna_violators; # modifies the routed DEF
	}

	run_magic

	run_magic_drc
	run_netgen
	run_magic_antenna_check; # to verify the above and get a final report





	#export_magic_view \
		-def $::env(CURRENT_DEF) \
		-output $::env(magic_result_file_tag).mag
	if {  [info exists flags_map(-save) ] } {
		if { [info exists arg_values(-save_path)] } {
			save_views 	-lef_path $::env(magic_result_file_tag).lef \
					-def_path $::env(tritonRoute_result_file_tag).def \
					-gds_path $::env(magic_result_file_tag).gds \
					-mag_path $::env(magic_result_file_tag).mag \
					-save_path $arg_values(-save_path) \
					-tag $::env(RUN_TAG)
		} else  {
			save_views 	-lef_path $::env(magic_result_file_tag).lef \
					-def_path $::env(tritonRoute_result_file_tag).def \
					-mag_path $::env(magic_result_file_tag).mag \
					-gds_path $::env(magic_result_file_tag).gds \
					-tag $::env(RUN_TAG)
			}
	}
}

proc run_interactive_mode {args} {
	set ::env(TCLLIBPATH) $::auto_path
	exec tclsh >&@stdout
}

proc run_magic_drc_batch {args} {
	set options {{-magicrc optional} \
			{-tech optional} \
			{-report required} \
			{-design required} \
			{-gds required}}
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
			$::env(OPENLANE_ROOT)/scripts/magic_drc_batch.tcl \
			</dev/null |& tee /dev/tty
	} else {
		exec magic \
			-noconsole \
			-dnull \
			$::env(OPENLANE_ROOT)/scripts/magic_drc_batch.tcl \
			</dev/null |& /dev/tty
	}
}

proc run_file {args} {
	set ::env(TCLLIBPATH) $::auto_path
	exec tclsh $args >&@stdout
}

set options {\
    {-file optional}\
}

set flags {-interactive -it -drc}

set argv_copy $argv
parse_key_args "flow.tcl" argv arg_values $options flags_map $flags

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

if { [info exists flags_map(-interactive)] ||\
    [info exists flags_map(-it)] } {
	if { [info exists arg_values(-file)] } {
		run_file [file normalize $arg_values(-file)]
	} else {
		run_interactive_mode "$argv_copy"
	}
} elseif { [info exists flags_map(-drc)] } {
	run_magic_drc_batch {*}$argv_copy
} else {
	run_non_interactive_mode {*}$argv_copy
}

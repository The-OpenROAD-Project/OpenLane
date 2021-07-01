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
if { ! [info exists ::env(OPENROAD_BIN) ] } {
	set ::env(OPENROAD_BIN) openroad
}
lappend ::auto_path "$::env(OPENLANE_ROOT)/scripts/"
package require openlane; # provides the utils as well

proc run_placement_step {args} {
    # set pdndef_dirname [file dirname $::env(pdn_tmp_file_tag).def]
    # set pdndef [lindex [glob $pdndef_dirname/*pdn*] 0]
    # set_def $pdndef
    if { ! [ info exists ::env(PLACEMENT_CURRENT_DEF) ] } {
        set ::env(PLACEMENT_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(PLACEMENT_CURRENT_DEF)
    }

    run_placement
}

proc run_cts_step {args} {
    # set_def $::env(opendp_result_file_tag).def
    if { ! [ info exists ::env(CTS_CURRENT_DEF) ] } {
        set ::env(CTS_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(CTS_CURRENT_DEF)
    }

    run_cts
    run_resizer_timing
}

proc run_routing_step {args} {
    # set resizerdef_dirname [file dirname $::env(resizer_tmp_file_tag)_timing.def]
    # set resizerdef [lindex [glob $resizerdef_dirname/*resizer*] 0]
    # set_def $resizerdef
    if { ! [ info exists ::env(ROUTING_CURRENT_DEF) ] } {
        set ::env(ROUTING_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(ROUTING_CURRENT_DEF)
    }
    run_routing
}

proc run_diode_insertion_2_5_step {args} {
    # set_def $::env(tritonRoute_result_file_tag).def
    if { ! [ info exists ::env(DIODE_INSERTION_CURRENT_DEF) ] } {
        set ::env(DIODE_INSERTION_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(DIODE_INSERTION_CURRENT_DEF)
    }
	if { ($::env(DIODE_INSERTION_STRATEGY) == 2) || ($::env(DIODE_INSERTION_STRATEGY) == 5) } {
		run_antenna_check
		heal_antenna_violators; # modifies the routed DEF
	}

}

proc run_power_pins_insertion_step {args} {
    # set_def $::env(tritonRoute_result_file_tag).def
    if { ! [ info exists ::env(POWER_PINS_INSERTION_CURRENT_DEF) ] } {
        set ::env(POWER_PINS_INSERTION_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(POWER_PINS_INSERTION_CURRENT_DEF)
    }
    if { $::env(LVS_INSERT_POWER_PINS) } {
		write_powered_verilog
		set_netlist $::env(lvs_result_file_tag).powered.v
    }

}

proc run_lvs_step {{ lvs_enabled 1 }} {
    # set_def $::env(tritonRoute_result_file_tag).def
    if { ! [ info exists ::env(LVS_CURRENT_DEF) ] } {
        set ::env(LVS_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(LVS_CURRENT_DEF)
    }
	if { $lvs_enabled } {
		run_magic_spice_export
		run_lvs; # requires run_magic_spice_export
	}

}

proc run_drc_step {{ drc_enabled 1 }} {
    if { ! [ info exists ::env(DRC_CURRENT_DEF) ] } {
        set ::env(DRC_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(DRC_CURRENT_DEF)
    }
	if { $drc_enabled } {
		run_magic_drc
		run_klayout_drc
	}
}

proc run_antenna_check_step {{ antenna_check_enabled 1 }} {
    if { ! [ info exists ::env(ANTENNA_CHECK_CURRENT_DEF) ] } {
        set ::env(ANTENNA_CHECK_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(ANTENNA_CHECK_CURRENT_DEF)
    }
	if { $antenna_check_enabled } {
		run_antenna_check
	}
}

	

proc run_non_interactive_mode {args} {
	set options {
		{-design required}
		{-from optional}
		{-to optional}
		{-save_path optional}
		{-no_lvs optional}
	    {-no_drc optional}
	    {-no_antennacheck optional}
	}
	set flags {-save}
	parse_key_args "run_non_interactive_mode" args arg_values $options flags_map $flags -no_consume

	prep {*}$args
    # signal trap SIGINT save_state;

    set LVS_ENABLED [expr ![info exists flags_map(-no_lvs)] ]
    set DRC_ENABLED [expr ![info exists flags_map(-no_drc)] ]
    set ANTENNACHECK_ENABLED [expr ![info exists flags_map(-no_antennacheck)] ]

    set steps [dict create "synthesis" {run_synthesis "" } \
                "floorplan" {run_floorplan ""} \
                "placement" {run_placement_step ""} \
                "cts" {run_cts_step ""} \
                "routing" {run_routing_step ""}\
                "diode_insertion" {run_diode_insertion_2_5_step ""} \
                "power_pins_insertion" {run_power_pins_insertion_step ""} \
                "gds_magic" {run_magic ""} \
                "gds_drc_klayout" {run_klayout ""} \
                "gds_xor_klayout" {run_klayout_gds_xor ""} \
                "lvs" "run_lvs_step $LVS_ENABLED" \
                "drc" "run_drc_step $DRC_ENABLED" \
                "antenna_check" "run_antenna_check_step $ANTENNACHECK_ENABLED" \
                "cvc" {run_lef_cvc}
        ]

    set_if_unset arg_values(-to) "cvc";

	if {  [info exists ::env(CURRENT_STEP) ] } {
        puts "\[INFO\]:Picking up where last execution left off"
        puts [format "\[INFO\]:Current stage is %s " $::env(CURRENT_STEP)]
    } else {
        set ::env(CURRENT_STEP) "synthesis";
    }

    set_if_unset arg_values(-from) $::env(CURRENT_STEP);
    set exe 0;
    dict for {step_name step_exe} $steps {
        if { [ string equal $arg_values(-from) $step_name ] } {
            set exe 1;
        }

        if { $exe } {
            # For when it fails
            set ::env(CURRENT_STEP) $step_name
            [lindex $step_exe 0] [lindex $step_exe 1] ;
        }

        if { [ string equal $arg_values(-to) $step_name ] } {
            set exe 0:
            break;
        }

    }

    # for when it resumes
    set steps_as_list [dict keys $steps]
    set next_idx [expr [lsearch $steps_as_list $::env(CURRENT_STEP)] + 1]
    set ::env(CURRENT_STEP) [lindex $steps_as_list $next_idx]

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



	calc_total_runtime
	generate_final_summary_report
    save_state

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

proc run_lvs_batch {args} {
	# runs device level lvs on -gds/CURRENT_GDS and -net/CURRENT_NETLIST
	# extracts gds only if EXT_NETLIST does not exist
	set options {
		{-design required}
		{-gds optional}
		{-net optional}
	}
	set flags {}
	parse_key_args "run_lvs_batch" args arg_values $options flags_lvs $flags -no_consume

	prep {*}$args

	if { [info exists arg_values(-gds)] } {
		set ::env(CURRENT_GDS) [file normalize $arg_values(-gds)]
	} else {
		set ::env(CURRENT_GDS) $::env(RESULTS_DIR)/magic/$::env(DESIGN_NAME).gds
	}
	if { [info exists arg_values(-net)] } {
		set ::env(CURRENT_NETLIST) [file normalize $arg_values(-net)]
	}
	if { ! [file exists $::env(CURRENT_GDS) ] } {
		puts_err "Could not find GDS file \"$::env(CURRENT_GDS)\""
		exit 1
	}
	if { ! [file exists $::env(CURRENT_NETLIST) ] } {
		puts_err "Could not find NET file \"$::env(CURRENT_NETLIST)\""
		exit 1
	}

	set ::env(MAGIC_EXT_USE_GDS) 1
	set ::env(EXT_NETLIST) $::env(RESULTS_DIR)/magic/$::env(DESIGN_NAME).gds.spice
	if { [file exists $::env(EXT_NETLIST)] } {
		puts_warn "Reusing $::env(EXT_NETLIST). Delete to remake."
	} else {
		run_magic_spice_export
	}

	run_lvs; # requires run_magic_spice_export
}


proc run_file {args} {
	set ::env(TCLLIBPATH) $::auto_path
	exec tclsh {*}$args >&@stdout
}

set options {
	{-file optional}
}

set flags {-interactive -it -drc -lvs -synth_explore}

parse_key_args "flow.tcl" argv arg_values $options flags_map $flags -no_consume

puts_info {
	 ___   ____   ___  ____   _       ____  ____     ___
	/   \ |    \ /  _]|    \ | |     /    ||    \   /  _]
	|   | |  o  )  [_ |  _  || |    |  o  ||  _  | /  [_
	| O | |   _/    _]|  |  || |___ |     ||  |  ||    _]
	|   | |  | |   [_ |  |  ||     ||  _  ||  |  ||   [_
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
} elseif { [info exists flags_map(-lvs)] } {
	run_lvs_batch {*}$argv
} elseif { [info exists flags_map(-synth_explore)] } {
	prep {*}$argv
	run_synth_exploration
} else {
	puts_info "Running non-interactively"
	run_non_interactive_mode {*}$argv
}

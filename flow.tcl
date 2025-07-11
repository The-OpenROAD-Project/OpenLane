#!/usr/bin/env tclsh
# Copyright 2020-2022 Efabless Corporation
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

if { [file exists $::env(OPENLANE_ROOT)/install/env.tcl ] } {
    source $::env(OPENLANE_ROOT)/install/env.tcl
}

if { ! [info exists ::env(OPENROAD_BIN) ] } {
    set ::env(OPENROAD_BIN) openroad
}
if { [info exists ::env(TCL8_5_TM_PATH)] } {
    set ::env(TCL8_5_TM_PATH) "$::env(OPENLANE_ROOT)/scripts:$::env(TCL8_5_TM_PATH)"
} else {
    set ::env(TCL8_5_TM_PATH) "$::env(OPENLANE_ROOT)/scripts"
}
package require openlane; # provides the utils as well

proc run_placement_step {args} {
    if { ! [ info exists ::env(PLACEMENT_CURRENT_DEF) ] } {
        set ::env(PLACEMENT_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(PLACEMENT_CURRENT_DEF)
    }

    run_placement
}

proc run_cts_step {args} {
    if { ! [ info exists ::env(CTS_CURRENT_DEF) ] } {
        set ::env(CTS_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(CTS_CURRENT_DEF)
    }

    run_cts
    run_resizer_timing
}

proc run_routing_step {args} {
    if { ! [ info exists ::env(ROUTING_CURRENT_DEF) ] } {
        set ::env(ROUTING_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(ROUTING_CURRENT_DEF)
    }
    run_routing
}

proc run_parasitics_sta_step {args} {
    if { ! [ info exists ::env(PARSITICS_CURRENT_DEF) ] } {
        set ::env(PARSITICS_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(PARSITICS_CURRENT_DEF)
    }

    if { $::env(RUN_SPEF_EXTRACTION)} {
        run_parasitics_sta
    }
}

proc run_irdrop_report_step {args} {
    if { $::env(RUN_IRDROP_REPORT) } {
        run_irdrop_report
    }
}

proc run_lvs_step {{ lvs_enabled 1 }} {
    if { ! [ info exists ::env(LVS_CURRENT_DEF) ] } {
        set ::env(LVS_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(LVS_CURRENT_DEF)
    }

    if { $lvs_enabled && $::env(RUN_LVS) } {
        run_magic_spice_export;
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
        if { $::env(RUN_MAGIC_DRC) } {
            run_magic_drc
        }
        if {$::env(RUN_KLAYOUT_DRC)} {
            run_klayout_drc
        }
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

proc run_erc_step {args} {
    if { $::env(RUN_CVC) } {
        run_erc
    }
}

proc run_magic_step {args} {
    if {$::env(RUN_MAGIC)} {
        run_magic
    }
}

proc run_klayout_step {args} {
    if {$::env(RUN_KLAYOUT)} {
        run_klayout
    }
    if {$::env(RUN_KLAYOUT_XOR)} {
        run_klayout_gds_xor
    }
}

proc run_timing_check_step {args} {
    check_timing_violations\
        -quit_on_hold_vios [expr $::env(QUIT_ON_TIMING_VIOLATIONS) && $::env(QUIT_ON_HOLD_VIOLATIONS)]\
        -quit_on_setup_vios [expr $::env(QUIT_ON_TIMING_VIOLATIONS) && $::env(QUIT_ON_SETUP_VIOLATIONS)]
}

proc run_verilator_step {} {
    if { $::env(RUN_LINTER) } {
        run_verilator
    }
}

proc run_non_interactive_mode {args} {
    set options {
        {-design optional}
        {-from optional}
        {-to optional}
        {-save_path optional}
        {-override_env optional}
    }
    set flags {-save -run_hooks -no_lvs -no_drc -no_antennacheck -gui}
    parse_key_args "run_non_interactive_mode" args arg_values $options flags_map $flags -no_consume

    if { [info exists arg_values(-from) ] || [info exists arg_values(-to)] } {
        puts_err "-from and -to are no longer supported."
        exit -1
    }

    if { [info exists flags_map(-gui)] } {
        puts_err "Flag -gui is now deprecated. Refer to https://openlane.readthedocs.io/en/latest/reference/gui.html to view files graphically."
        throw_error
    }

    prep {*}$args
    # signal trap SIGINT save_state;

    if { [info exists arg_values(-override_env)] } {
        load_overrides $arg_values(-override_env)
    }

    set LVS_ENABLED [expr ![info exists flags_map(-no_lvs)] ]
    set DRC_ENABLED [expr ![info exists flags_map(-no_drc)] ]

    set ANTENNACHECK_ENABLED [expr ![info exists flags_map(-no_antennacheck)] ]

    set steps [dict create \
        "verilator_lint_check" "run_verilator_step" \
        "synthesis" "run_synthesis" \
        "floorplan" "run_floorplan" \
        "placement" "run_placement_step" \
        "cts" "run_cts_step" \
        "routing" "run_routing_step" \
        "parasitics_sta" "run_parasitics_sta_step" \
        "irdrop" "run_irdrop_report_step" \
        "gds_magic" "run_magic_step" \
        "gds_klayout" "run_klayout_step" \
        "lvs" "run_lvs_step $LVS_ENABLED " \
        "drc" "run_drc_step $DRC_ENABLED " \
        "antenna_check" "run_antenna_check_step $ANTENNACHECK_ENABLED " \
        "cvc_rv" "run_erc_step"
    ]

    set ::env(CURRENT_STEP) "verilator_lint_check"

    set start_step $::env(CURRENT_STEP)
    set end_step "cvc_rv"

    set failed 0;
    set exe 0;
    dict for {step_name step_exe} $steps {
        if { [ string equal $start_step $step_name ] } {
            set exe 1;
        }

        if { $exe } {
            # For when it fails
            set ::env(CURRENT_STEP) $step_name

            set step_result [catch [lindex $step_exe 0] [lindex $step_exe 1] err];
            if { $step_result } {
                set failed 1;
                puts_err "Step $::env(CURRENT_INDEX) ($step_name) failed with error:\n$err"
                set exe 0;
                break;
            }
        }

        if { [ string equal $end_step $step_name ] } {
            set exe 0:
            break;
        }

    }

    # for when it resumes
    set steps_as_list [dict keys $steps]
    set next_idx [expr [lsearch $steps_as_list $::env(CURRENT_STEP)] + 1]
    set ::env(CURRENT_STEP) [lindex $steps_as_list $next_idx]

    if { $failed } {
        flow_fail
    }
    # Saves to <RUN_DIR>/results/final
    save_final_views

    # Saves to design directory or custom
    if {  [info exists flags_map(-save) ] } {
        if { ! [info exists arg_values(-save_path)] } {
            set arg_values(-save_path) $::env(DESIGN_DIR)
        }
        save_final_views -save_path $arg_values(-save_path) -tag $::env(RUN_TAG)
    }
    calc_total_runtime
    save_state
    generate_final_summary_report

    if { [catch run_timing_check_step] } {
        flow_fail
    }

    if { [info exists arg_values(-save_path)] && $arg_values(-save_path) != "" } {
        set ::env(HOOK_OUTPUT_PATH) "[file normalize $arg_values(-save_path)]"
    } else {
        set ::env(HOOK_OUTPUT_PATH) $::env(RESULTS_DIR)/final
    }

    if {[info exists flags_map(-run_hooks)]} {
        run_post_run_hooks
    }

    puts_success "Flow complete."

    show_warnings "Note that the following warnings have been generated:"
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
            $::env(OPENLANE_ROOT)/scripts/magic/gds/drc_batch.tcl \
            </dev/null |& tee /dev/tty
    } else {
        exec magic \
            -noconsole \
            -dnull \
            $::env(OPENLANE_ROOT)/scripts/magic/gds/drc_batch.tcl \
            </dev/null |& tee /dev/tty
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
        set ::env(CURRENT_GDS) $::env(signoff_results)/$::env(DESIGN_NAME).gds
    }
    if { [info exists arg_values(-net)] } {
        set ::env(CURRENT_POWERED_NETLIST) [file normalize $arg_values(-net)]
    }

    assert_files_exist "$::env(CURRENT_GDS) $::env(CURRENT_POWERED_NETLIST)"

    set ::env(MAGIC_EXT_USE_GDS) 1
    set ::env(EXT_NETLIST) $::env(signoff_results)/$::env(DESIGN_NAME).gds.spice
    if { [file exists $::env(EXT_NETLIST)] } {
        puts_warn "The file $::env(EXT_NETLIST) will be used. If you would like the file re-exported, please delete it."
    } else {
        run_magic_spice_export
    }

    set ::env(LVS_INSERT_POWER_PINS) 0
    run_lvs

    calc_total_runtime
    save_state
    generate_final_summary_report
    puts_success "LVS success."
    show_warnings "Note that the following warnings have been generated:"
}


proc run_file {args} {
    set ::env(TCLLIBPATH) $::auto_path
    exec env EXIT_ON_ERROR=1 tclsh {*}$args >&@stdout
}

set options {
    {-file optional}
}

set flags {-interactive -it -drc -lvs -synth_explore -run_hooks}

parse_key_args "flow.tcl" argv arg_values $options flags_map $flags -no_consume

if {[catch {exec cat $::env(OPENLANE_ROOT)/install/installed_version} ::env(OPENLANE_COMMIT)]} {
    if {[catch {exec cat /git_version} ::env(OPENLANE_COMMIT)]} {
        if {[catch {exec git --git-dir $::env(OPENLANE_ROOT)/.git rev-parse HEAD} ::env(OPENLANE_COMMIT)]} {
            set ::env(OPENLANE_COMMIT) "UNKNOWN"
        }
    }
}

if { [file isdirectory $::env(OPENLANE_ROOT)/.git] } {
    if {![catch {exec git --git-dir $::env(OPENLANE_ROOT)/.git rev-parse HEAD} ::env(OPENLANE_MOUNTED_SCRIPTS_VERSION)]} {
        if { $::env(OPENLANE_COMMIT) == $::env(OPENLANE_MOUNTED_SCRIPTS_VERSION)} {
            unset ::env(OPENLANE_MOUNTED_SCRIPTS_VERSION)
        }
    }
}

puts "OpenLane v[package version openlane] ($::env(OPENLANE_COMMIT))"
if { [info exists ::env(OPENLANE_MOUNTED_SCRIPTS_VERSION)] } {
    puts "(with mounted scripts from $::env(OPENLANE_MOUNTED_SCRIPTS_VERSION))"
}
puts "All rights reserved. (c) 2020-2025 Efabless Corporation and contributors."
puts "Available under the Apache License, version 2.0. See the LICENSE file for more details."
puts ""

if { [info exists flags_map(-interactive)] || [info exists flags_map(-it)] } {
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
    run_non_interactive_mode {*}$argv
}

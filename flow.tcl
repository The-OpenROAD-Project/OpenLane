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
set ::env(SCRIPTS_DIR) "$::env(OPENLANE_ROOT)/scripts"

if { [file exists $::env(OPENLANE_ROOT)/install/env.tcl ] } {
    source $::env(OPENLANE_ROOT)/install/env.tcl
}

if { ! [info exists ::env(OPENROAD_BIN) ] } {
    set ::env(OPENROAD_BIN) openroad
}
lappend ::auto_path "$::env(OPENLANE_ROOT)/scripts/"
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
    if { $::env(RSZ_USE_OLD_REMOVER) == 1} {
        remove_buffers_from_nets
    }
}

proc run_routing_step {args} {
    if { ! [ info exists ::env(ROUTING_CURRENT_DEF) ] } {
        set ::env(ROUTING_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(ROUTING_CURRENT_DEF)
    }
    if { $::env(ECO_ENABLE) == 0 } {
        run_routing
    }
}

proc run_parasitics_sta_step {args} {
    if { ! [ info exists ::env(PARSITICS_CURRENT_DEF) ] } {
        set ::env(PARSITICS_CURRENT_DEF) $::env(CURRENT_DEF)
    } else {
        set ::env(CURRENT_DEF) $::env(PARSITICS_CURRENT_DEF)
    }

    if { $::env(RUN_SPEF_EXTRACTION) && ($::env(ECO_ENABLE) == 0)} {
        run_parasitics_sta
    }
}

proc run_diode_insertion_2_5_step {args} {
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

proc run_eco_step {args} {
    if { $::env(ECO_ENABLE) == 1 } {
        run_eco_flow
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

proc run_post_run_hooks {} {
    if { [file exists $::env(DESIGN_DIR)/hooks/post_run.py]} {
        puts_info "Running post run hook"
        set result [exec $::env(OPENROAD_BIN) -exit -python $::env(DESIGN_DIR)/hooks/post_run.py]
        puts_info "$result"
    } else {
        puts_info "hooks/post_run.py not found, skipping"
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

    prep {*}$args
    # signal trap SIGINT save_state;

    if { [info exists flags_map(-gui)] } {
        or_gui
        return
    }
    if { [info exists arg_values(-override_env)] } {
        load_overrides $arg_values(-override_env)
    }

    set LVS_ENABLED [expr ![info exists flags_map(-no_lvs)] ]
    set DRC_ENABLED [expr ![info exists flags_map(-no_drc)] ]

    set ANTENNACHECK_ENABLED [expr ![info exists flags_map(-no_antennacheck)] ]

    set steps [dict create \
        "synthesis" "run_synthesis" \
        "floorplan" "run_floorplan" \
        "placement" "run_placement_step" \
        "cts" "run_cts_step" \
        "routing" "run_routing_step" \
        "parasitics_sta" "run_parasitics_sta_step" \
        "eco" "run_eco_step" \
        "diode_insertion" "run_diode_insertion_2_5_step" \
        "irdrop" "run_irdrop_report_step" \
        "gds_magic" "run_magic_step" \
        "gds_klayout" "run_klayout_step" \
        "lvs" "run_lvs_step $LVS_ENABLED " \
        "drc" "run_drc_step $DRC_ENABLED " \
        "antenna_check" "run_antenna_check_step $ANTENNACHECK_ENABLED " \
        "cvc" "run_lef_cvc"
    ]

    if { [info exists arg_values(-from) ]} {
        puts_info "Starting flow at $arg_values(-from)..."
        set ::env(CURRENT_STEP) $arg_values(-from)
    } elseif {  [info exists ::env(CURRENT_STEP) ] } {
        puts_info "Resuming flow from $::env(CURRENT_STEP)..."
    } else {
        set ::env(CURRENT_STEP) "synthesis"
    }

    set_if_unset arg_values(-from) $::env(CURRENT_STEP)
    set_if_unset arg_values(-to) "cvc"

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

    # Saves to <RUN_DIR>/results/final
    save_final_views

    # Saves to design directory or custom
    if {  [info exists flags_map(-save) ] } {
        if { ! [info exists arg_values(-save_path)] } {
            set arg_values(-save_path) $::env(DESIGN_DIR)
        }
        save_final_views\
            -save_path $arg_values(-save_path)\
            -tag $::env(RUN_TAG)
    }
    calc_total_runtime
    save_state
    generate_final_summary_report

    check_timing_violations

    if { [info exists arg_values(-save_path)]\
        && $arg_values(-save_path) != "" } {
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
        set ::env(CURRENT_NETLIST) [file normalize $arg_values(-net)]
    }

    assert_files_exist "$::env(CURRENT_GDS) $::env(CURRENT_NETLIST)"

    set ::env(MAGIC_EXT_USE_GDS) 1
    set ::env(EXT_NETLIST) $::env(signoff_results)/$::env(DESIGN_NAME).gds.spice
    if { [file exists $::env(EXT_NETLIST)] } {
        puts_warn "The file $::env(EXT_NETLIST) will be used. If you would like the file re-exported, please delete it."
    } else {
        run_magic_spice_export
    }

    run_lvs
}


proc run_file {args} {
    set ::env(TCLLIBPATH) $::auto_path
    exec tclsh {*}$args >&@stdout
}

set options {
    {-file optional}
}

set flags {-interactive -it -drc -lvs -synth_explore -run_hooks}

parse_key_args "flow.tcl" argv arg_values $options flags_map $flags -no_consume

if {[catch {exec cat $::env(OPENLANE_ROOT)/install/installed_version} ::env(OPENLANE_VERSION)]} {
    if {[catch {exec cat /git_version} ::env(OPENLANE_VERSION)]} {
        if {[catch {exec git --git-dir $::env(OPENLANE_ROOT)/.git rev-parse HEAD} ::env(OPENLANE_VERSION)]} {
            set ::env(OPENLANE_VERSION) "UNKNOWN"
        }
    }
}

if {![catch {exec git --git-dir $::env(OPENLANE_ROOT)/.git rev-parse HEAD} ::env(OPENLANE_MOUNTED_SCRIPTS_VERSION)]} {
    if { $::env(OPENLANE_VERSION) == $::env(OPENLANE_MOUNTED_SCRIPTS_VERSION)} {
        unset ::env(OPENLANE_MOUNTED_SCRIPTS_VERSION)
    }
}

puts "OpenLane $::env(OPENLANE_VERSION)"
if { [info exists ::env(OPENLANE_MOUNTED_SCRIPTS_VERSION)] } {
    puts "(with mounted scripts from $::env(OPENLANE_MOUNTED_SCRIPTS_VERSION))"
}
puts "All rights reserved. (c) 2020-2022 Efabless Corporation and contributors."
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

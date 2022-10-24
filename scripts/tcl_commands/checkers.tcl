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



proc check_assign_statements {args} {
    set checker [count_matches assign $::env(synthesis_results).v]

    if { $checker != 0 } {
        puts_err "There are assign statements in the netlist"
        flow_fail
    } else {
        puts_info "No assign statement in netlist"
    }
}

proc check_synthesis_failure {args} {
    set checker [catch {exec grep "\\\$" [index_file $::env(synthesis_reports)/2.stat.rpt]}]

    if { ! $checker } {
        puts_err "Synthesis failed"
        flow_fail
    }
}

proc check_timing_violations {args} {
    if { [info exists ::env(LAST_TIMING_REPORT_TAG)] } {
        set hold_report $::env(LAST_TIMING_REPORT_TAG).min.rpt
        set setup_report $::env(LAST_TIMING_REPORT_TAG).max.rpt
        set slew_report $::env(LAST_TIMING_REPORT_TAG).slew.rpt

        foreach file [ list $hold_report $setup_report $slew_report] {
            if {![file exist $file]} {
                puts_err "File $file doesn't exist."
                flow_fail
            }
        }

        check_slew_violations -report_file $slew_report -corner "typical"
        check_hold_violations -report_file $hold_report -corner "typical" -quit_on_vios [expr $::env(QUIT_ON_TIMING_VIOLATIONS) && $::env(QUIT_ON_HOLD_VIOLATIONS)]
        check_setup_violations -report_file $setup_report -corner "typical" -quit_on_vios [expr $::env(QUIT_ON_TIMING_VIOLATIONS) && $::env(QUIT_ON_HOLD_VIOLATIONS)]
    }
}

proc check_hold_violations {args} {
    set options {
        {-report_file required}
        {-corner required}
        {-quit_on_vios optional}
    }
    parse_key_args "check_hold_violations" args arg_values $options
    set_if_unset arg_values(-quit_on_vios) 0
    set report_file $arg_values(-report_file)
    set quit_on_vios $arg_values(-quit_on_vios)
    set corner $arg_values(-corner)

    set checker [catch {exec grep "VIOLATED" $report_file }]
    if { ! $checker } {
        set report_file_relative [relpath . $report_file]
        if { $quit_on_vios } {
            puts_err "There are hold violations in the design at the $corner corner. Please refer to '$report_file_relative'."
            flow_fail
        } else {
            puts_warn "There are hold violations in the design at the $corner corner. Please refer to '$report_file_relative'."
        }
    } else {
        puts_info "There are no hold violations in the design at the $corner corner."
    }
}

proc check_setup_violations {args} {
    set options {
        {-report_file required}
        {-corner required}
        {-quit_on_vios optional}
    }
    parse_key_args "check_setup_violations" args arg_values $options
    set_if_unset arg_values(-quit_on_vios) 0
    set report_file $arg_values(-report_file)
    set quit_on_vios $arg_values(-quit_on_vios)
    set corner $arg_values(-corner)

    set checker [catch {exec grep "VIOLATED" $report_file }]
    if { ! $checker } {
        set report_file_relative [relpath . $report_file]
        if { $quit_on_vios } {
            puts_err "There are setup violations in the design at the $corner corner. Please refer to '$report_file_relative'."
            flow_fail
        } else {
            puts_warn "There are setup violations in the design at the $corner corner. Please refer to '$report_file_relative'."
        }
    } else {
        puts_info "There are no setup violations in the design at the $corner corner."
    }
}

proc check_slew_violations {args} {
    # Perhaps counterintuitively, this also checks max fanout and max capacitance.
    set options {
        {-report_file required}
        {-corner required}
        {-quit_on_vios optional}
    }
    parse_key_args "check_slew_violations" args arg_values $options
    set_if_unset arg_values(-quit_on_vios) 0
    set report_file $arg_values(-report_file)
    set quit_on_vios $arg_values(-quit_on_vios)
    set corner $arg_values(-corner)

    set report_file_relative [relpath . $report_file]

    set violated 0

    set check_slew [catch {exec grep "slew violation count 0" $report_file}]
    if { $check_slew } {
        set violated 1
        if { $quit_on_vios } {
            puts_err "There are max slew violations in the design at the $corner corner. Please refer to '$report_file_relative'."
        } else {
            puts_warn "There are max slew violations in the design at the $corner corner. Please refer to '$report_file_relative'."
        }
    }

    set check_fanout [catch {exec grep "fanout violation count 0" $report_file}]
    if { $check_fanout } {
        set violated 1
        if { $quit_on_vios } {
            puts_err "There are max fanout violations in the design at the $corner corner. Please refer to '$report_file_relative'."
        } else {
            puts_warn "There are max fanout violations in the design at the $corner corner. Please refer to '$report_file_relative'."
        }
    }

    set check_capacitance [catch {exec grep "cap violation count 0" $report_file}]
    if { $check_capacitance } {
        set violated 1
        if { $quit_on_vios } {
            puts_err "There are max capacitance violations in the design at the $corner corner. Please refer to '$report_file_relative'."
        } else {
            puts_warn "There are max capacitance violations in the design at the $corner corner. Please refer to '$report_file_relative'."
        }
    }

    if { $violated } {
        if { $quit_on_vios } {
            flow_fail
        }
    } else {
        puts_info "There are no max slew, max fanout or max capacitance violations in the design at the $corner corner."
    }
}

proc check_floorplan_missing_lef {args} {
    set checker [catch {exec grep -E -o "module \[^\[:space:]]+ not found" [index_file $::env(floorplan_logs)/initial_fp.log]} missing_lefs]

    if { ! $checker } {
        puts_err "Floorplanning failed"
        set lines [split $missing_lefs "\n"]
        foreach line $lines {
            puts_err "$line in $::env(MERGED_LEF)"
        }
        puts_err "Check whether EXTRA_LEFS is set appropriately"
        flow_fail
    }
}

proc check_floorplan_missing_pins {args} {
    set checker [catch {exec grep -E -o "instance \[^\[:space:]]+ port \[^\[:space:]]+ not found" [index_file $::env(floorplan_logs)/openroad.log]} mismatches]

    if { ! $checker } {
        set lines [split $mismatches "\n"]
        foreach line $lines {
            puts_err "$line in $::env(MERGED_LEF)"
        }
        puts_err "Check whether EXTRA_LEFS is set appropriately and if they have the referenced pins."
        flow_fail
    }
}

proc check_cts_clock_nets {args} {
    set checker [catch {exec grep -E -o "Error: No clock nets have been found." [index_file $::env(cts_logs)/cts.log]} error]

    if { ! $checker } {
        puts_err "Clock Tree Synthesis failed"
        puts_err $error
        puts_err "TritonCTS failed to find clock nets and/or sinks in the design; check whether the synthesized netlist contains flip-flops."
        flow_fail
    }
}

proc check_replace_divergence {args} {
    set checker [catch {exec grep -E -o "RePlAce diverged. Please tune the parameters again" [index_file $::env(placement_logs)/global.log]} error]

    if { ! $checker } {
        puts_err "Global placement failed"
        puts_err $error
        flow_fail
    }
}

proc check_macro_placer_num_solns {args} {
    set checker [catch {exec grep -E -o "NumFinalSols = 0" [index_file $::env(placement_logs)/basic_mp.log]} error]

    if { ! $checker } {
        puts_err "Macro placement failed"
        puts_err "$error; you may need to adjust the HALO"
        flow_fail
    }
}

proc quit_on_tr_drc {args} {
    if { $::env(QUIT_ON_TR_DRC) } {
        set checker [count_matches violation $::env(routing_reports)/drt.drc]

        if { $checker != 0 } {
            puts_err "There are violations in the design after detailed routing."
            puts_err "Total Number of violations is $checker"
            flow_fail
        } else {
            puts_info "No DRC violations after detailed routing."
        }
    }
}

proc quit_on_magic_drc {args} {
    if { [info exists ::env(QUIT_ON_MAGIC_DRC)] && $::env(QUIT_ON_MAGIC_DRC) } {
        set options {
            {-log required}
        }
        parse_key_args "quit_on_magic_drc" args arg_values $options

        set checker [count_matches violation $arg_values(-log)]

        if { $checker != 0 } {
            puts_err "There are violations in the design after Magic DRC."
            puts_err "Total Number of violations is $checker"
            flow_fail
        } else {
            puts_info "No DRC violations after GDS streaming out."
        }
    }
}

proc quit_on_lvs_error {args} {
    if { [info exists ::env(QUIT_ON_LVS_ERROR)] && $::env(QUIT_ON_LVS_ERROR) } {
        set options {
            {-rpt required}
            {-log required}
        }
        parse_key_args "quit_on_lvs_error" args arg_values $options
        set checker [catch {exec grep -E -o "Total errors = 0" $arg_values(-rpt)} error]

        if { $checker != 0 } {
            set rpt_relative [relpath . $arg_values(-rpt)]
            set log_relative [relpath . $arg_values(-log)]
            puts_err "There are LVS errors in the design: See '$rpt_relative' for a summary and '$log_relative' for details."
            flow_fail
        }
    }
}

proc quit_on_illegal_overlaps {args} {
    if { [info exists ::env(QUIT_ON_ILLEGAL_OVERLAPS)] && $::env(QUIT_ON_ILLEGAL_OVERLAPS) } {
        set options {
            {-log required}
        }
        parse_key_args "quit_on_illegal_overlaps" args arg_values $options

        set checker [catch {exec grep -E -o "Illegal overlap" $arg_values(-log)} error]
        if { ! $checker } {
            puts_err "There are illegal overlaps (e.g., routes over obstructions) in your design."
            puts_err "See $arg_values(-log) for more."
            flow_fail
        }
    }
}

proc quit_on_unconnected_pdn_nodes {args} {
    set log_file [index_file $::env(floorplan_logs)/pdn.log]
    set checker [catch {exec grep -E "Unconnected PDN node" $log_file} error]

    if { ! $checker } {
        puts_err "PDN generation failed."
        puts_err "You may need to adjust your macro placements or PDN \
            offsets/pitches to power all standard cell rails (or other PDN stripes) \
            in your design."
        flow_fail
    }
}

package provide openlane 0.9

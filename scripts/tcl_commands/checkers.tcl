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

proc check_synth_misc {report} {
    if { ![file exists $report] } {
        puts_info "Yosys synthesis checks not conducted- continuing."
        return
    }
    set arg_list [list]
    if { $::env(SYNTH_CHECKS_ALLOW_TRISTATE) } {
        lappend arg_list --tristate-okay
    }
    if { [info exists ::env(TRISTATE_CELL_PREFIX)] } {
        lappend arg_list "--tristate-cell-prefix"
        lappend arg_list "$::env(TRISTATE_CELL_PREFIX)"
    }
    if { [catch {exec python3 $::env(SCRIPTS_DIR)/parse_yosys_check.py {*}$arg_list $report} err] } {
        puts_err "Yosys checks have failed: $err"
        puts_err "See the full report here: [relpath . $report]"
        throw_error
    }
}

proc check_latches {log} {
    set match {\$LATCH}
    set checker [exec bash -c "grep '$match' \
        $log || true"]

    if { $checker ne "" } {
        puts_err "Synthesis failed. There are latches during synthesis."
        throw_error
    }
}

proc check_out_of_bound {log} {
    set match {out of bounds on signal}
    set checker [exec bash -c "grep '$match' \
        $log || true"]

    if { $checker ne "" } {
        puts_err "Synthesis failed. Range select out of bounds on some signals. Search for '$match' in $log"
        throw_error
    }
}

proc check_resizing_cell_port {log} {
    set match {Resizing cell port}
    set checker [exec bash -c "grep '$match' \
        $log || true"]

    if { $checker ne "" } {
        puts_err "Synthesis failed. Signal not matching port size. Search for '$match' in $log"
        throw_error
    }
}

proc run_synthesis_checkers {log report} {
    check_latches $log
    check_out_of_bound $log
    check_resizing_cell_port $log
    check_synth_misc $report
}

proc check_assign_statements {args} {
    set checker [count_matches assign $::env(synthesis_results).v]

    if { $checker != 0 } {
        puts_err "There are assign statements in the netlist."
        throw_error
    } else {
        puts_verbose "No assign statement in netlist, continuing..."
    }
}

proc check_unmapped_cells {stat_file} {
    set match {\$}
    set checker [exec bash -c "grep '$match' \
        $stat_file || true"]

    if { $checker ne "" } {
        puts_err "Synthesis failed. There are unmapped cells after synthesis."
        throw_error
    }
}

proc check_timing_violations {args} {
    set options {
        {-quit_on_setup_vios optional}
        {-quit_on_hold_vios optional}
    }
    parse_key_args "check_timing_violations" args arg_values $options

    set_if_unset arg_values(-quit_on_setup_vios) 0
    set_if_unset arg_values(-quit_on_hold_vios) 0

    if { [info exists ::env(LAST_TIMING_REPORT_TAG)] } {
        set hold_report $::env(LAST_TIMING_REPORT_TAG).min.rpt
        set setup_report $::env(LAST_TIMING_REPORT_TAG).max.rpt
        set misc_report $::env(LAST_TIMING_REPORT_TAG).checks.rpt

        assert_files_exist "$hold_report $setup_report $misc_report"

        check_misc_violations -report_file $misc_report -corner "typical"
        check_hold_violations -report_file $hold_report -corner "typical" -quit_on_vios $arg_values(-quit_on_hold_vios)
        check_setup_violations -report_file $setup_report -corner "typical" -quit_on_vios $arg_values(-quit_on_setup_vios)
    } else {
        puts_warn "::env(LAST_TIMING_REPORT_TAG) not found."
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
            throw_error
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
            throw_error
        } else {
            puts_warn "There are setup violations in the design at the $corner corner. Please refer to '$report_file_relative'."
        }
    } else {
        puts_info "There are no setup violations in the design at the $corner corner."
    }
}

proc check_misc_violations {args} {
    # Perhaps counterintuitively, this also checks max fanout and max capacitance.
    set options {
        {-report_file required}
        {-corner required}
        {-quit_on_vios optional}
    }
    parse_key_args "check_misc_violations" args arg_values $options
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
            throw_error
        }
    } else {
        puts_info "There are no max slew, max fanout or max capacitance violations in the design at the $corner corner."
    }
}

proc check_slew_violations {args} {
    handle_deprecated_command check_misc_violations
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
        throw_error
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
        throw_error
    }
}

proc check_cts_clock_nets {args} {
    set checker [catch {exec grep -E -o "Error: No clock nets have been found." [index_file $::env(cts_logs)/cts.log]} error]

    if { ! $checker } {
        puts_err "Clock Tree Synthesis failed"
        puts_err $error
        puts_err "TritonCTS failed to find clock nets and/or sinks in the design; check whether the synthesized netlist contains flip-flops."
        throw_error
    }
}

proc check_replace_divergence {args} {
    set checker [catch {exec grep -E -o "RePlAce diverged. Please tune the parameters again" [index_file $::env(placement_logs)/global.log]} error]

    if { ! $checker } {
        puts_err "Global placement failed"
        puts_err $error
        throw_error
    }
}

proc check_macro_placer_num_solns {args} {
    set checker [catch {exec grep -E -o "NumFinalSols = 0" [index_file $::env(placement_logs)/basic_mp.log]} error]

    if { ! $checker } {
        puts_err "Macro placement failed"
        puts_err "$error; you may need to adjust the HALO"
        throw_error
    }
}

proc quit_on_tr_drc {args} {
    set checker [count_matches violation $::env(routing_reports)/drt.drc]

    if { $checker != 0 } {
        puts_err "There are violations in the design after detailed routing."
        puts_err "Total Number of violations is $checker"
        throw_error
    } else {
        puts_info "No DRC violations after detailed routing."
    }
}

proc quit_on_magic_drc {args} {
    set options {
        {-log required}
    }
    parse_key_args "quit_on_magic_drc" args arg_values $options

    set checker [count_matches violation $arg_values(-log)]

    if { $checker != 0 } {
        puts_err "There are violations in the design after Magic DRC."
        puts_err "Total Number of violations is $checker"
        throw_error
    } else {
        puts_info "No DRC violations after GDS streaming out."
    }
}

proc quit_on_lvs_error {args} {
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
        throw_error
    }
}

proc quit_on_xor_error {args} {
    set options {
        {-log required}
    }
    parse_key_args "quit_on_xor_error" args arg_values $options
    set checker [catch {exec grep -E -o "Total XOR differences = 0" $arg_values(-log)} error]

    if { $checker != 0 } {
        set log_relative [relpath . $arg_values(-log)]
        puts_err "There are XOR differences in the design: See '$log_relative' for details."
        throw_error
    } else {
        puts_info "No XOR differences between KLayout and Magic gds."
    }
}

proc quit_on_illegal_overlaps {args} {
    set options {
        {-log required}
    }
    parse_key_args "quit_on_illegal_overlaps" args arg_values $options

    set checker [catch {exec grep -E -o "Illegal overlap" $arg_values(-log)} error]
    if { ! $checker } {
        puts_err "There are illegal overlaps (e.g., routes over obstructions) in your design."
        puts_err "See $arg_values(-log) for more."
        throw_error
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
        throw_error
    }
}

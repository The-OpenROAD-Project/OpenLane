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
    set checker [ exec sh $::env(SCRIPTS_DIR)/grepCount.sh assign $::env(yosys_result_file_tag).v ]

    if { $checker != 0 } {
        puts_err "There are assign statements in the netlist"
        flow_fail
        return -code error
    } else {
        puts_info "No assign statement in netlist"
    }
}

proc check_synthesis_failure {args} {
    set checker [catch {exec grep "\\\$" [index_file $::env(yosys_report_file_tag)_2.stat.rpt 0]}]


    if { ! $checker } {
        puts_err "Synthesis failed"
        flow_fail
        return -code error
    } else {
        puts_info "Synthesis was successful"
    }
}

proc check_floorplan_missing_lef {args} {
    set checker [catch {exec grep -E -o "module \[^\[:space:]]+ not found" [index_file $::env(verilog2def_log_file_tag).openroad.log 0]} missing_lefs]

    if { ! $checker } {
        puts_err "Floorplanning failed"
        set lines [split $missing_lefs "\n"]
        foreach line $lines {
            puts_err "$line in $::env(MERGED_LEF)"
        }
        puts_err "Check whether EXTRA_LEFS is set appropriately"
        flow_fail
        return -code error
    }
}

proc check_floorplan_missing_pins {args} {
    set checker [catch {exec grep -E -o "instance \[^\[:space:]]+ port \[^\[:space:]]+ not found" [index_file $::env(verilog2def_log_file_tag).openroad.log 0]} mismatches]

    if { ! $checker } {
        set lines [split $mismatches "\n"]
        foreach line $lines {
            puts_err "$line in $::env(MERGED_LEF)"
        }
        puts_err "Check whether EXTRA_LEFS is set appropriately and if they have the referenced pins."
        flow_fail
        return -code error
    }
}

proc check_cts_clock_nets {args} {
    set checker [catch {exec grep -E -o "Error: No clock nets have been found." [index_file $::env(cts_log_file_tag).log 0]} error]

    if { ! $checker } {
        puts_err "Clock Tree Synthesis failed"
        puts_err $error
        puts_err "TritonCTS failed to find clock nets and/or sinks in the design; check whether the synthesized netlist contains flip-flops."
        flow_fail
        return -code error
    } else {
        puts_info "Clock Tree Synthesis was successful"
    }
}

proc check_replace_divergence {args} {
    set checker [catch {exec grep -E -o "RePlAce diverged. Please tune the parameters again" [index_file $::env(replaceio_log_file_tag).log 0]} error]

    if { ! $checker } {
        puts_err "Global placement failed"
        puts_err $error
        flow_fail
        return -code error
    } else {
        puts_info "Global placement was successful"
    }
}

proc check_macro_placer_num_solns {args} {
    set checker [catch {exec grep -E -o "NumFinalSols = 0" [index_file $::env(LOG_DIR)/placement/basic_mp.log 0]} error]

    if { ! $checker } {
        puts_err "Macro placement failed"
        puts_err "$error; you may need to adjust the HALO"
        flow_fail
        return -code error
    } else {
        puts_info "Macro placement was successful"
    }
}

proc quit_on_tr_drc {args} {
    if { [info exists ::env(QUIT_ON_TR_DRC)] && $::env(QUIT_ON_TR_DRC) } {
        set checker [ exec sh $::env(SCRIPTS_DIR)/grepCount.sh violation $::env(tritonRoute_report_file_tag).drc ]

        if { $checker != 0 } {
            puts_err "There are violations in the design after detailed routing."
            puts_err "Total Number of violations is $checker"
            flow_fail
            return -code error
        } else {
            puts_info "No DRC violations after detailed routing."
        }
    }
}

proc quit_on_magic_drc {args} {
    if { [info exists ::env(QUIT_ON_MAGIC_DRC)] && $::env(QUIT_ON_MAGIC_DRC) } {
        set checker [ exec sh $::env(SCRIPTS_DIR)/grepCount.sh violation $::env(magic_report_file_tag).tr.drc ]

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
				{-log required}
			}
		parse_key_args "quit_on_lvs_error" args arg_values $options
        set checker [catch {exec grep -E -o "Total errors = 0" $arg_values(-log)} error]

        if { $checker != 0 } {
            puts_err "There are LVS errors in the design according to Netgen LVS."
            flow_fail
            return -code error
        } else {
            puts_info "No LVS mismatches."
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
            return -code error
        } else {
            puts_info "No Illegal overlaps detected during extraction."
        }
    }
}

proc quit_on_unconnected_pdn_nodes {args} {
    set log_file [index_file $::env(pdn_log_file_tag).log 0]
    set checker [catch {exec grep -E "Unconnected PDN node" $log_file} error]

    if { ! $checker } {
        puts_err "PDN generation failed."
        puts_err "You may need to adjust your macro placements or PDN \
            offsets/pitches to power all standard cell rails (or other PDN stripes) \
            in your design."
        flow_fail
        return -code error
    } else {
        puts_info "PDN generation was successful."
    }
}

package provide openlane 0.9

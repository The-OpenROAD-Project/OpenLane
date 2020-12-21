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
        return -code error
    } else {
        puts_info "No assign statement in netlist"
    }
}

proc check_synthesis_failure {args} {
    set checker [catch {exec grep "\\\$" $::env(yosys_report_file_tag)_2.stat.rpt}]


    if { ! $checker } {
        puts_err "Synthesis failed"
        return -code error
    } else {
        puts_info "Synthesis was successful"
    }
}

proc check_floorplan_missing_lef {args} {
    set checker [catch {exec grep -E -o "module \[^\[:space:]]+ not found" $::env(verilog2def_log_file_tag).openroad.log} missing_lefs]

    if { ! $checker } {
        puts_err "Floorplanning failed"
        set lines [split $missing_lefs "\n"]
        foreach line $lines {
            puts_err "$line in $::env(MERGED_LEF)"
        }
        puts_err "Check whether EXTRA_LEFS is set appropriately"
        return -code error
    }
}

proc check_floorplan_missing_pins {args} {
    set checker [catch {exec grep -E -o "instance \[^\[:space:]]+ port \[^\[:space:]]+ not found" $::env(verilog2def_log_file_tag).openroad.log} mismatches]

    if { ! $checker } {
        set lines [split $mismatches "\n"]
        foreach line $lines {
            puts_err "$line in $::env(MERGED_LEF)"
        }
        puts_err "Check whether EXTRA_LEFS is set appropriately and if they have the referenced pins."
        return -code error
    }
}

proc check_cts_clock_nets {args} {
    set checker [catch {exec grep -E -o "Error: No clock nets have been found." $::env(cts_log_file_tag).log} error]

    if { ! $checker } {
        puts_err "Clock Tree Synthesis failed"
        puts_err $error
        puts_err "TritonCTS failed to find clock nets and/or sinks in the design; check whether the synthesized netlist contains flip-flops."
        return -code error
    } else {
        puts_info "Clock Tree Synthesis was successful"
    }
}

proc check_replace_divergence {args} {
    set checker [catch {exec grep -E -o "RePlAce diverged. Please tune the parameters again" $::env(replaceio_log_file_tag).log} error]

    if { ! $checker } {
        puts_err "Global placement failed"
        puts_err $error
        return -code error
    } else {
        puts_info "Global placement was successful"
    }
}

proc check_macro_placer_num_solns {args} {
    set checker [catch {exec grep -E -o "NumFinalSols = 0" $::env(LOG_DIR)/placement/basic_mp.log} error]

    if { ! $checker } {
        puts_err "Macro placement failed"
        puts_err "$error; you may need to adjust the HALO"
        return -code error
    } else {
        puts_info "Macro placement was successful"
    }
}

package provide openlane 0.9

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


proc check_diode_placement {args} {
    #set st {detailed placement failed on}
    set checker [catch {exec grep "detailed placement failed" $::env(LOG_DIR)/placement/diodes.log}]

    if { ! $checker } {
        puts_err "Diode placement failed"
        puts_err "Existing..."
        exit
    } else {
        puts_info "Diode placement passed."
    }

}

proc check_unmapped_cells {args} {

    set checker [ exec sh $::env(SCRIPTS_DIR)/grepCount.sh unmapped $::env(yosys_log_file_tag).log ]
  
    if { $checker != 0 } {
        puts_err "Unmapped cells in design."
        puts_err "Existing..."
        exit
    } else {
        puts_info "No unmapped cells."
    }

}

proc check_assign_statements {args} {

    set checker [ exec sh $::env(SCRIPTS_DIR)/grepCount.sh assign $::env(yosys_result_file_tag).v ]
  
    if { $checker != 0 } {
        puts_err "There are assign statements in the netlist"
        puts_err "Existing..."
        exit
    } else {
        puts_info "No assign statement in netlist"
    }

}


proc check_synthesis_failure {args} {

    set checker [catch {exec grep "\\\$" $::env(yosys_report_file_tag)_2.stat.rpt}]


    if { ! $checker } {
        puts_err "Synthesis failed"
        puts_err "Existing..."
        exit
    } else {
        puts_info "Synthesis was successful"
    }


}
package provide openlane 0.9

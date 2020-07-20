# Copyright (c) Efabless Corporation. All rights reserved.
# See LICENSE file in the project root for full license information.

proc check_diode_placement {args} {
    #set st {detailed placement failed on}
    set checker [catch {exec grep "detailed placement failed" $::env(LOG_DIR)/placement/diodes.log}]

    if { ! $checker } {
        puts_err "\[ERROR:\] diode placement failed"
        puts_err "Existing..."
        exit
    } else {
        puts_info "\[INFO:\] diode placement passed."
    }

}

proc check_unmapped_cells {args} {

    set checker [ exec sh $::env(SCRIPTS_DIR)/grepCount.sh unmapped $::env(yosys_log_file_tag).log ]
  
    if { $checker != 0 } {
        puts_err "\[ERROR:\] unmapped cells in design."
        puts_err "Existing..."
        exit
    } else {
        puts_info "\[INFO:\] no unmapped cells."
    }

}

proc check_assign_statements {args} {

    set checker [ exec sh $::env(SCRIPTS_DIR)/grepCount.sh assign $::env(yosys_result_file_tag).v ]
  
    if { $checker != 0 } {
        puts_err "\[ERROR:\] There are assign statements in the netlist"
        puts_err "Existing..."
        exit
    } else {
        puts_info "\[INFO:\] No assign statement in netlist"
    }

}


proc check_synthesis_failure {args} {

    set checker [catch {exec grep "\\\$" $::env(yosys_report_file_tag)_2.stat.rpt}]


    if { ! $checker } {
        puts_err "\[ERROR:\] synthesis failed."
        puts_err "Existing..."
        exit
    } else {
        puts_info "\[INFO:\] synthesis success."
    }


}
package provide openlane 0.9

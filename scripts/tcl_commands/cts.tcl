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

global script_path
set script_path [ file dirname [ file normalize [ info script ] ] ]

proc run_cts {args} {
    if { ! [info exists ::env(CLOCK_PORT)] && ! [info exists ::env(CLOCK_NET)] } {
        puts_info "::env(CLOCK_PORT) is not set"
        puts_warn "Skipping CTS..."
        set ::env(RUN_CTS) 0
    }

    if {$::env(RUN_CTS)} {
        increment_index
        TIMER::timer_start
        set log [index_file $::env(cts_logs)/cts.log]
        puts_info "Running Clock Tree Synthesis (log: [relpath . $log])..."

        if { ! [info exists ::env(CLOCK_NET)] } {
            set ::env(CLOCK_NET) $::env(CLOCK_PORT)
        }

        set report_tag_holder $::env(cts_reports)
        set ::env(cts_reports) [ index_file $::env(cts_reports)/cts.rpt]

        run_openroad_script $::env(SCRIPTS_DIR)/openroad/cts.tcl\
            -indexed_log $log\
            -save "to=$::env(cts_results),noindex,def,sdc,odb"

        check_cts_clock_nets

        set ::env(cts_reports) $report_tag_holder
        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "cts - openroad"

        scrot_klayout -layout $::env(CURRENT_DEF) -log $::env(cts_logs)/screenshot.log

        if { [info exists ::env(CTS_REPORT_TIMING)] && $::env(CTS_REPORT_TIMING) } {
            run_sta -estimate_placement -no_save $::env(cts_results) -log $::env(cts_logs)/cts_sta.log
        }
    }
}

proc run_resizer_timing {args} {
    if { $::env(PL_RESIZER_TIMING_OPTIMIZATIONS) == 1} {
        increment_index
        TIMER::timer_start
        set log [index_file $::env(cts_logs)/resizer.log]
        puts_info "Running Placement Resizer Timing Optimizations (log: [relpath . $log])..."

        run_openroad_script $::env(SCRIPTS_DIR)/openroad/resizer_timing.tcl\
            -indexed_log [index_file $::env(cts_logs)/resizer.log]\
            -save "to=$::env(cts_tmpfiles),name=$::env(DESIGN_NAME).resized,def,sdc,odb,netlist,powered_netlist"

        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "resizer timing optimizations - openroad"

    } else {
        puts_info "Skipping Placement Resizer Timing Optimizations."
    }
}

# Copyright 2020-2021 Efabless Corporation
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
        set ::env(CLOCK_TREE_SYNTH) 0
    }

    if {$::env(CLOCK_TREE_SYNTH) } {
        set ::env(CURRENT_STAGE) cts
        increment_index
        TIMER::timer_start

        set cts_log [index_file $::env(cts_logs)/cts.log]
        set cts_log_rel [relpath . $cts_log]
        puts_info "Running Clock Tree Synthesis (logging to '$cts_log_rel')..."

        if { ! [info exists ::env(CLOCK_NET)] } {
            set ::env(CLOCK_NET) $::env(CLOCK_PORT)
        }

        set report_tag_holder $::env(cts_reports)
        set ::env(cts_reports) [ index_file $::env(cts_reports)/cts.rpt]

        run_openroad_script $::env(SCRIPTS_DIR)/openroad/cts.tcl\
            -indexed_log $cts_log\
            -save "def=$::env(cts_results)/$::env(DESIGN_NAME).def,sdc=$::env(cts_results)/$::env(DESIGN_NAME).sdc"

        check_cts_clock_nets

        set ::env(cts_reports) $report_tag_holder

        write_verilog $::env(cts_results)/$::env(DESIGN_NAME).v\
            -log $::env(cts_logs)/write_verilog.log

        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "cts"

        scrot_klayout -layout $::env(CURRENT_DEF) -log $::env(cts_logs)/screenshot.log
    }
}

proc run_resizer_timing {args} {
    if { $::env(PL_RESIZER_TIMING_OPTIMIZATIONS) == 1} {
        increment_index
        TIMER::timer_start
        puts_info "Running Placement Resizer Timing Optimizations..."

        run_openroad_script $::env(SCRIPTS_DIR)/openroad/resizer_timing.tcl\
            -indexed_log [index_file $::env(cts_logs)/resizer.log]\
            -save "def=[index_file $::env(cts_tmpfiles)/resizer_timing.def],sdc=[index_file $::env(cts_tmpfiles)/resizer_timing.sdc]"

        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "resizer timing optimizations - openroad"

        write_verilog $::env(cts_results)/$::env(DESIGN_NAME).resized.v -log $::env(cts_logs)/write_verilog.log

    } else {
        puts_info "Skipping Placement Resizer Timing Optimizations."
    }
}


package provide openlane 0.9

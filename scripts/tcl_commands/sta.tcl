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

proc run_sta {args} {
    set options {
        {-log required}
    }
    set flags {
        -multi_corner
        -pre_cts
    }
    parse_key_args "run_sta" args arg_values $options flags_map $flags
    set multi_corner [info exists flags_map(-multi_corner)]
    set pre_cts [info exists flags_map(-pre_cts)]
    set ::env(RUN_STANDALONE) 1

    increment_index
    TIMER::timer_start
    puts_info "Running Static Timing Analysis..."

    set ::env(STA_PRE_CTS) $pre_cts

    set log [index_file $arg_values(-log)]

    if {[info exists ::env(CLOCK_PORT)]} {
        if { $multi_corner == 1 } {
            run_openroad_script $::env(SCRIPTS_DIR)/openroad/sta_multi_corner.tcl \
                -indexed_log $log
        } else {
            run_openroad_script $::env(SCRIPTS_DIR)/openroad/sta.tcl \
                -indexed_log $log
        }
    } else {
        puts_warn "CLOCK_PORT is not set. STA will be skipped..."
    }
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "sta - openroad"
}

proc parasitics_sta {args} {
    set options {
        {-sdf_out optional}
    }
    set flags {}
    parse_key_args "parasitics_sta" args arg_values $options flags_map $flags

    set_if_unset arg_values(-sdf_out) [file rootname $::env(CURRENT_DEF)].sdf

    puts_info "Running parasitics-based static timing analysis..."

    run_spef_extraction -rcx_lib $::env(LIB_SYNTH_COMPLETE) -output_spef $::env(SPEF_TYPICAL) -log $::env(routing_logs)/parasitics_extraction.tt.log
    run_spef_extraction -rcx_lib $::env(LIB_SLOWEST) -output_spef $::env(SPEF_SLOWEST) -log $::env(routing_logs)/parasitics_extraction.ss.log
    run_spef_extraction -rcx_lib $::env(LIB_FASTEST) -output_spef $::env(SPEF_FASTEST) -log $::env(routing_logs)/parasitics_extraction.ff.log

    set ::env(SAVE_SDF) $arg_values(-sdf_out)

    # run sta at the typical corner using the extracted spef
    run_sta -log $::env(routing_logs)/parasitics_sta.log
    set ::env(LAST_TIMING_REPORT_TAG) [index_file $::env(routing_reports)/parasitics_sta]

    set ::env(CURRENT_SDF) $::env(SAVE_SDF)

    # run sta at the three corners
    run_sta -log $::env(routing_logs)/parasitics_multi_corner_sta.log -multi_corner
}

package provide openlane 0.9

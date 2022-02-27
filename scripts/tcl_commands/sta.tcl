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
        {-runtime_log -required} 
    }
    set flags {
        -multi_corner
    }
    parse_key_args "run_sta" args arg_values $options flags_map $flags
    set multi_corner [info exists flags_map(-multi_corner)]
    set ::env(RUN_STANDALONE) 1

    increment_index
    TIMER::timer_start
    puts_info "Running Static Timing Analysis..."

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

package provide openlane 0.9

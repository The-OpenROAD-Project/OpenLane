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
        {-lef optional}
        {-process_corner optional}
    }
    set flags {
        -multi_corner
        -pre_cts
    }
    parse_key_args "run_sta" args arg_values $options flags_map $flags
    set multi_corner [info exists flags_map(-multi_corner)]
    set pre_cts [info exists flags_map(-pre_cts)]

    set_if_unset arg_values(-lef) $::env(MERGED_LEF)
    set ::env(STA_LEF) $arg_values(-lef)
    set ::env(RUN_STANDALONE) 1

    increment_index
    TIMER::timer_start

    set corner_prefix "Single-Corner"
    if { $multi_corner } {
        set corner_prefix "Multi-Corner"
    }
    set process_corner_postfix ""
    if { [info exists arg_values(-process_corner)]} {
        set process_corner_postfix " at the $arg_values(-process_corner) process corner"
    }
    puts_info "Running $corner_prefix Static Timing Analysis$process_corner_postfix..."

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

proc run_parasitics_sta {args} {
    set options {
        {-sdf_out optional}
        {-spef_out_prefix optional}
    }
    set flags {}
    parse_key_args "parasitics_sta" args arg_values $options flags_map $flags

    set_if_unset arg_values(-sdf_out) [file rootname $::env(CURRENT_DEF)].sdf
    set_if_unset arg_values(-spef_out_prefix) [file rootname $::env(CURRENT_DEF)]

    set ::env(SPEF_PREFIX) $arg_values(-spef_out_prefix)
    set ::env(SAVE_SDF) $arg_values(-sdf_out)

    puts_info "Running parasitics-based static timing analysis..."

    # Nom last so CURRENT_SPEF is the nom current SPEF after the loop is done
    foreach {process_corner lef ruleset} {
        min MERGED_LEF_MIN RCX_RULES_MIN
        max MERGED_LEF_MAX RCX_RULES_MAX
        nom MERGED_LEF RCX_RULES
    } {
        if { [info exists ::env($lef)] } {
            set ::env(SAVE_SPEF) "$::env(SPEF_PREFIX).$process_corner.spef"

            run_spef_extraction\
                -log $::env(signoff_logs)/parasitics_extraction.$process_corner.log\
                -rcx_lib $::env(LIB_SYNTH_COMPLETE)\
                -rcx_rules $::env($ruleset)\
                -rcx_lef $::env($lef)\
                -process_corner $process_corner

            set ::env(CURRENT_SPEF) $::env(SAVE_SPEF)

            set log_name $::env(signoff_logs)/parasitics_multi_corner_sta.$process_corner.log

            if { $process_corner == "nom" } {
                # First, we need this for the reports:
                set log_name $::env(signoff_logs)/parasitics_multi_corner_sta.log

                # We also need to run a single-corner STA at the tt timing corner
                run_sta\
                    -log $::env(signoff_logs)/parasitics_sta.log\
                    -process_corner $process_corner

                set ::env(LAST_TIMING_REPORT_TAG) [index_file $::env(signoff_reports)/rcx_sta]

                set ::env(CURRENT_SDF) $::env(SAVE_SDF)
            }

            run_sta\
                -lef $::env($lef)\
                -log $log_name\
                -process_corner $process_corner\
                -multi_corner
        }
    }
}

package provide openlane 0.9

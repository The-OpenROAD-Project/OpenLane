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

proc run_sta {args} {
    set options {
        {-log required}
        {-process_corner optional}
        {-save_to optional}
        {-tool optional}
        {-estimate_global optional}
        {-estimate_placement optional}
    }
    set flags {
        -multi_corner
        -pre_cts
        -netlist_in
        -blackbox_check
        -no_save
        -propagate_all_clocks
    }
    parse_key_args "run_sta" args arg_values $options flags_map $flags

    set_if_unset arg_values(-save_to) "$::env(signoff_results)"
    set_if_unset arg_values(-tool) "openroad"

    set multi_corner [info exists flags_map(-multi_corner)]
    set pre_cts [info exists flags_map(-pre_cts)]

    set ::env(RUN_STANDALONE) 1

    set corner_prefix "Single-Corner"
    if { $multi_corner } {
        set corner_prefix "Multi-Corner"
    }

    if { [info exists flags_map(-propagate_all_clocks)] } {
        set ::env(_PROPAGATE_ALL_CLOCKS) 1
    } else {
        set ::env(_PROPAGATE_ALL_CLOCKS) 0
    }

    set ::env(PROCESS_CORNER) nom
    set process_corner_postfix ""
    if { [info exists arg_values(-process_corner)]} {
        set process_corner_postfix " at the $arg_values(-process_corner) process corner"
        set ::env(PROCESS_CORNER) $arg_values(-process_corner)
    }

    increment_index
    TIMER::timer_start
    set log [index_file $arg_values(-log)]
    puts_info "Running $corner_prefix Static Timing Analysis$process_corner_postfix (log: [relpath . $log])..."

    set ::env(STA_PRE_CTS) $pre_cts
    set lib_option ""
    if { $::env(STA_WRITE_LIB) } {
        set lib_option "lib"
    }

    set arg_list [list]
    lappend arg_list -indexed_log $log
    if { ![info exist flags_map(-no_save)] } {
        lappend arg_list -save "to=$arg_values(-save_to),noindex,sdf,$lib_option"
    }
    if { [info exists flags_map(-netlist_in)] } {
        lappend arg_list -netlist_in
    }
    if { [info exists arg_values(-estimate_global)] && $::env(GRT_ESTIMATE_PARASITICS) } {
        set ::env(ESTIMATE_PARASITICS) -global
    }
    if { [info exists arg_values(-estimate_placement)] && $::env(PL_ESTIMATE_PARASITICS) } {
        set ::env(ESTIMATE_PARASITICS) -placement
    }

    proc blackbox_modules_check {file_path} {
        set fp [open $file_path r]
        set file_path [read $fp]
        set modules [list]
        set ignore_patterns "$::env(FILL_CELL) $::env(DECAP_CELL) $::env(FP_WELLTAP_CELL)"
        foreach line [split $file_path "\n"] {
            if { [regexp {module\s+(\S+)\s+not\s+found} $line match first_group] } {
                set ignored 0
                foreach pattern $ignore_patterns {
                    if { [string match $pattern $first_group] != -1 } {
                        set ignored 1
                    }
                }
                if { $ignored != 1 } {
                    lappend modules $first_group
                }
            }
        }
        if { [llength $modules] > 0 } {
            puts_warn "The following modules were black-boxed for STA as there was no timing information found:"
            foreach {m} $modules {
                puts_warn "\t* $m"
            }
        }
        close $fp
    }

    set ::env(STA_MULTICORNER) 0
    if { $multi_corner == 1 } {
        set ::env(STA_MULTICORNER) 1
        run_$arg_values(-tool)_script $::env(SCRIPTS_DIR)/openroad/sta/multi_corner.tcl \
            -no_update_current\
            {*}$arg_list

        if { $::env(STA_WRITE_LIB) } {
            unset ::env(SAVE_LIB)
        }
        unset ::env(SAVE_SDF)
    } else {
        run_$arg_values(-tool)_script $::env(SCRIPTS_DIR)/openroad/sta/multi_corner.tcl {*}$arg_list
    }
    if { [info exists flags_map(-blackbox_check)] } {
        blackbox_modules_check $log
    }
    unset ::env(STA_MULTICORNER)
    set ::env(_PROPAGATE_ALL_CLOCKS) 0
    unset -nocomplain ::env(ESTIMATE_PARASITICS)
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "sta - openroad"
}


proc run_parasitics_sta {args} {
    set options {
        {-out_directory optional}
    }
    set flags {}
    parse_key_args "parasitics_sta" args arg_values $options flags_map $flags

    set_if_unset arg_values(-out_directory) [file dirname $::env(CURRENT_DEF)]

    # The nom corner is last so:
    # * CURRENT_SPEF is the nom SPEF after the loop is done
    # * CURRENT_LIB is the nom/nom LIB after the loop is done
    # * CURRENT_SDF is the nom/nom SDF after the loop is done

    set mca_results_dir "$arg_values(-out_directory)/mca"
    set ::env(MC_SPEF_DIR) "$mca_results_dir/spef"
    set ::env(MC_SDF_DIR) "$mca_results_dir/sdf"

    file delete -force $::env(MC_SPEF_DIR)
    file delete -force $::env(MC_SDF_DIR)

    foreach {process_corner lef ruleset} {
        min MERGED_LEF_MIN RCX_RULES_MIN
        max MERGED_LEF_MAX RCX_RULES_MAX
        nom MERGED_LEF RCX_RULES
    } {
        if { [info exists ::env($lef)] } {
            set directory "$mca_results_dir/process_corner_$process_corner"
            file mkdir $directory

            run_spef_extraction\
                -log $::env(signoff_logs)/parasitics_extraction.$process_corner.log\
                -rcx_lib $::env(LIB_SYNTH_COMPLETE)\
                -rcx_rules $::env($ruleset)\
                -rcx_lef $::env($lef)\
                -process_corner $process_corner \
                -save "$directory/$::env(DESIGN_NAME).spef"

            set log_name $::env(signoff_logs)/rcx_mcsta.$process_corner.log

            set sta_flags [list]
            lappend sta_flags -log $log_name
            lappend sta_flags -process_corner $process_corner
            lappend sta_flags -multi_corner
            lappend sta_flags -propagate_all_clocks
            lappend sta_flags -save_to $directory
            lappend sta_flags -tool sta

            if { $process_corner == "nom" } {
                lappend sta_flags -blackbox_check
            }

            run_sta {*}$sta_flags

            if { $process_corner == "nom" } {
                set ::env(LAST_TIMING_REPORT_TAG) "[index_file $::env(signoff_reports)/sta-rcx_$process_corner]/multi_corner_sta"
            }

            file mkdir $::env(MC_SPEF_DIR)
            file copy -force "$directory/$::env(DESIGN_NAME).spef" "$::env(MC_SPEF_DIR)/$::env(DESIGN_NAME).$process_corner.spef"

            set sdf_folder "$::env(MC_SDF_DIR)/$process_corner"
            file mkdir $sdf_folder
            file copy -force {*}[glob $directory/$::env(DESIGN_NAME).*.sdf] $sdf_folder
        }
    }
}

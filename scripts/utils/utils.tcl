# Copyright 2020-2022 Efabless Corporation
# ECO Flow Copyright 2021 The University of Michigan
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

# warn about deprecated configs and preserve backwards compatibility
proc handle_deprecated_config {old new} {
    if { [info exists ::env($old)] } {
        puts_warn "$old is now deprecated; use $new instead."

        if { ! [info exists ::env($new)] } {
            set ::env($new) $::env($old)
        }
        if { $::env($new) != $::env($old) } {
            puts_err "Conflicting values of $new and $old; please remove $old from your design configurations"
            return -code error
        }
    }
}

proc find_all {ext} {
    if { ! [info exists ::env(RUN_DIR)] } {
        puts_err "You are not currently running a design. Perhaps you forgot to run 'prep'?"
        return -code error
    }
    return [exec find $::env(RUN_DIR) -name "*.$ext" | sort | xargs realpath --relative-to=$::env(PWD)]
}

proc handle_deprecated_command {args} {
    set new [lindex $args 0]
    set insert_args [lrange $args 1 end]

    set invocation [info level -1]
    set caller [lindex $invocation 0]
    set caller_args [lrange $invocation 1 end]

    set final_args [list {*}$insert_args {*}$caller_args]

    puts_warn "The command $caller is now deprecated; use $new $insert_args instead."
    eval {$new {*}$final_args}
}

proc set_if_unset {var default_value} {
    upvar $var x
    if {! [info exists x] } {
        set x $default_value
    }
}

# create an array out of a list

proc add_to_env {my_array} {
    foreach {key value} [array get my_array] {
        set $::env($key) $value
    }
}

# helper function for argument parsing
proc is_keyword_arg { arg } {
    if { [string length $arg] >= 2 \
        && [string index $arg 0] == "-" \
            && [string is alpha [string index $arg 1]] } {
            return 1
    } else {
        return 0
    }
}

proc extract_pins_from_yosys_netlist {netlist_file} {
    # This sed command works because the module herader in a
    # yosys-generated netlist is on one line.
    return [list [exec sed -E -n {/^module/ s/module[[:space:]]+[^[:space:]]+[[:space:]]*\((.*)\);/\1/pg}\
        $netlist_file \
        | tr -d ',']]

}

# parse arguments
# adopted from https://github.com/The-OpenROAD-Project/OpenSTA/blob/77f22e482e8d48d29f2810d871a22847f1bdd74a/tcl/Util.tcl#L31

proc parse_key_args {cmd arg_var key_var options {flag_var ""} {flags {}} {consume_args_flag "-consume"}} {
    upvar 1 $arg_var args
    upvar 1 $key_var key_value
    upvar 1 $flag_var flag_present
    set args_copy $args
    set keys {}
    foreach option $options {
        set option_name [lindex $option 0]
        if { [lsearch -exact $option required ] >= 0} {
            set key_index [lsearch -exact $args [lindex $option 0]]
            if {$key_index < 0} {
                puts_err "$cmd missing required $option_name"
                return -code error
            }
        }
        lappend keys $option_name
    }

    set args_rtn {}
    while { $args != "" } {
        set arg [lindex $args 0]
        if { [is_keyword_arg $arg] } {
            set key_index [lsearch -exact $keys $arg]
            if { $key_index >= 0 } {
                set key $arg
                if { [llength $args] == 1 } {
                    puts_err "$cmd $key missing value."
                    return -code error
                }
                set key_value($key) [lindex $args 1]
                set args [lrange $args 1 end]
            } else {
                set flag_index [lsearch -exact $flags $arg]
                if { $flag_index >= 0 } {
                    set flag_present($arg) 1
                }
            }
        } else {
            lappend args_rtn $arg
        }
        set args [lrange $args 1 end]
    }

    if { $consume_args_flag == "-no_consume" } {
        set args $args_copy
    } else {
        set args $args_rtn
    }
    return -code ok
}

# puts a variable in a log file
proc set_log {var val filepath log_flag} {
    set cmd "set ${var} \{${val}\}"
    uplevel #0 ${cmd}
    set global_cfg_file [open $filepath a+]
    if { $log_flag } {
        puts $global_cfg_file $cmd
    }
    close $global_cfg_file
}

# a minimal try catch block
proc try_catch {args} {
    # puts_info "Executing \"$args\"\n"
    if { ! [catch { set cmd_log_file [open $::env(RUN_DIR)/cmds.log a+] } ]} {
        set timestamp [clock format [clock seconds]]
        puts $cmd_log_file "$timestamp - Executing \"$args\"\n"
        close $cmd_log_file
    }
    set exit_code [catch {eval exec $args} error_msg]
    if { $exit_code } {
        set tool [string range $args 0 [string first " " $args]]
        set print_error_msg "during executing: \"$args\""

        puts_err "$print_error_msg"
        puts_err "Exit code: $exit_code"
        puts_err "Last 10 lines:\n[exec tail -10 << $error_msg]\n"

        flow_fail
    }
}

proc relpath {args} {
    set from [lindex $args 0]
    set to [lindex $args 1]
    return [exec python3 -c "import os; print(os.path.relpath('$to', '$from'), end='')"]
}

proc run_openroad_script {args} {
    run_tcl_script -tool openroad -no_consume {*}$args
}

proc run_magic_script {args} {
    run_tcl_script -tool magic -no_consume {*}$args
}

proc increment_index {args} {
    set ::env(CURRENT_INDEX) [expr 1 + $::env(CURRENT_INDEX)]
    puts "\[STEP $::env(CURRENT_INDEX)\]"
}

proc index_file {args} {
    set file_full_name [lindex $args 0]

    if { $file_full_name == "/dev/null" } {
        # Can't index that :)
        return $file_full_name
    }

    set file_path [file dirname $file_full_name]
    set fbasename [file tail $file_full_name]
    set fbasename "$::env(CURRENT_INDEX)-$fbasename"

    set new_file_full_name "$file_path/$fbasename"
    set replace [string map {/ \\/} $::env(CURRENT_INDEX)]
    if { [info exists ::env(GLB_CFG_FILE)]} {
        exec sed -i -e "s/\\(set ::env(CURRENT_INDEX)\\).*/\\1 $replace/" "$::env(GLB_CFG_FILE)"
    }
    return $new_file_full_name
}

proc flow_fail {args} {
    if { ! [info exists ::env(FLOW_FAILED)] || ! $::env(FLOW_FAILED) } {
        set ::env(FLOW_FAILED) 1
        calc_total_runtime -status "flow failed"
        save_final_views
        generate_final_summary_report
        save_state
        puts_err "Flow failed."
        show_warnings "The failure may have been because of the following warnings:"
        return -code error
    }
}

proc calc_total_runtime {args} {
    ## Calculate Total Runtime
    if {[info exists ::env(timer_start)] && [info exists ::env(START_TIME)]} {
        puts_verbose "Calculating runtime..."
        set ::env(timer_end) [clock seconds]
        set options {
            {-report optional}
            {-status optional}
        }
        parse_key_args "calc_total_runtime" args arg_values $options
        set_if_unset arg_values(-report) $::env(REPORTS_DIR)/total_runtime.txt
        set_if_unset arg_values(-status) "flow completed"

        exec python3 $::env(SCRIPTS_DIR)/write_runtime.py --conclude --seconds --time-in $::env(timer_end) $arg_values(-status)
    }
}

# Value	Color
# 0	Black
# 1	Red *******
# 2	Green *******
# 3	Yellow *******
# 4	Blue
# 5	Magenta
# 6	Cyan *******
# 7	White
# 8	Not used
# 9	Reset to default color
proc color_text {color txt} {
    if {[info exists ::env(TERM)] && $::env(TERM) != ""} {
        return [exec tput setaf $color]$txt[exec tput setaf 9]
    } else {
        return $txt
    }
}

proc puts_err {txt} {
    set message "\[ERROR\]: $txt"
    puts "[color_text 1 "$message"]"
    if { [info exists ::env(RUN_DIR)] } {
        exec echo $message >> $::env(RUN_DIR)/openlane.log
        exec echo $message >> $::env(RUN_DIR)/errors.log
    }
}

proc puts_success {txt} {
    set message "\[SUCCESS\]: $txt"
    puts "[color_text 2 "$message"]"
    if { [info exists ::env(RUN_DIR)] } {
        exec echo $message >> $::env(RUN_DIR)/openlane.log
    }
}

proc puts_warn {txt} {
    set message "\[WARNING\]: $txt"
    puts "[color_text 3 "$message"]"
    if { [info exists ::env(RUN_DIR)] } {
        exec echo $message >> $::env(RUN_DIR)/openlane.log
        exec echo $message >> $::env(RUN_DIR)/warnings.log
    }
}

proc puts_info {txt} {
    set message "\[INFO\]: $txt"
    puts "[color_text 6 "$message"]"
    if { [info exists ::env(RUN_DIR)] } {
        exec echo $message >> $::env(RUN_DIR)/openlane.log
    }
}

proc puts_verbose {txt} {
    global global_verbose_level
    if { $global_verbose_level } {
        set message "\[INFO\]: $txt"
        puts "[color_text 6 "$message"]"
        if { [info exists ::env(RUN_DIR)] } {
            exec echo $message >> $::env(RUN_DIR)/openlane.log
        }
    }
}

proc show_warnings {msg} {
    if { [info exists ::env(RUN_DIR)] && [file exists $::env(RUN_DIR)/warnings.log] } {
        puts_info $msg
        set warnings_file [open $::env(RUN_DIR)/warnings.log "r"]
        set warnings [read $warnings_file]
        close $warnings_file
        puts $warnings
    }
}

proc generate_routing_report {args} {
    puts_info "Generating a partial report for routing..."

    try_catch python3 $::env(SCRIPTS_DIR)/gen_report_routing.py -d $::env(DESIGN_DIR) \
        --design_name $::env(DESIGN_NAME) \
        --tag $::env(RUN_TAG) \
        --run_path $::env(RUN_DIR)
}


proc generate_final_summary_report {args} {
    if { $::env(GENERATE_FINAL_SUMMARY_REPORT) == 0 } {
        return
    }
    puts_info "Generating final set of reports..."
    set options {
        {-output optional}
        {-man_report optional}
    }
    set flags {}
    parse_key_args "generate_final_summary_report" args arg_values $options flags_map $flags

    set_if_unset arg_values(-output) $::env(REPORTS_DIR)/metrics.csv
    set_if_unset arg_values(-man_report) $::env(REPORTS_DIR)/manufacturability.rpt

    try_catch python3 $::env(OPENLANE_ROOT)/scripts/generate_reports.py -d $::env(DESIGN_DIR) \
        --design_name $::env(DESIGN_NAME) \
        --tag $::env(RUN_TAG) \
        --output_file $arg_values(-output) \
        --man_report $arg_values(-man_report) \
        --run_path $::env(RUN_DIR)

    set man_report_rel [relpath . $arg_values(-man_report)]
    set metrics_report_rel [relpath . $arg_values(-output)]

    puts_info "Created manufacturability report at '$man_report_rel'."
    puts_info "Created metrics report at '$metrics_report_rel'."
}

namespace eval TIMER {
    variable timer_start
    variable timer_end

    proc timer_start {} {
        variable timer_start
        set timer_start [clock milliseconds]
    }
    proc timer_stop {} {
        variable timer_end
        set timer_end [clock milliseconds]
    }

    proc get_runtime {} {
        variable timer_start
        variable timer_end
        set total_ms [expr {$timer_end - $timer_start }]
        set runtime_ms   [expr { int($total_ms) % 1000 }]
        set runtime_s [expr { int(floor($total_ms) / 1000) % 60 }]
        set runtime_m [expr { int(floor($total_ms / (1000*60))) % 60 }]
        set runtime_h  [expr { int(floor($total_ms / (1000*3600))) % 24 }]
        set runtime "${runtime_h}h${runtime_m}m${runtime_s}s${runtime_ms}ms"
        return $runtime
    }
}

proc assert_files_exist {files} {
    foreach f $files {
        if { ! [file exists $f] } {
            puts_err "$f doesn't exist."
            flow_fail
        } else {
            puts_verbose "$f existence verified."
        }
    }
}

proc count_matches {pattern search_file} {
    set count [exec bash -c "grep $pattern $search_file | wc -l"]
    return $count
}

proc cat {args} {
    set res {}
    foreach file $args {
        set f [open $file r]
        set tmp [read $f]
        close $f
        append res $tmp
    }
    return $res
}

proc manipulate_layout {args} {
    # Requires at least one non-flag/option arg, which is the path to the script.
    set options {
        {-indexed_log optional}
        {-input optional}
        {-output optional}
        {-output_def optional}
    }

    set flags {}

    parse_key_args "manipulate_layout" args arg_values $options flag_map $flags

    set_if_unset arg_values(-indexed_log) /dev/null
    set_if_unset arg_values(-input) $::env(CURRENT_ODB)
    set_if_unset arg_values(-output) $arg_values(-input)
    set_if_unset arg_values(-output_def) /dev/null

    try_catch $::env(OPENROAD_BIN) -exit -no_init -python\
        {*}$args \
        --input-lef $::env(MERGED_LEF) \
        --output-def $arg_values(-output_def) \
        --output $arg_values(-output) \
        $arg_values(-input) \
        |& tee $::env(TERMINAL_OUTPUT) $arg_values(-indexed_log)
}

proc run_tcl_script {args} {
    # -tool: openroad/magic
    # -indexed_log: a log that is already pre-indexed
    # -save:
    #     OpenROAD only. A list of commands to handle saving views.
    #     The commands are comma delimited, and can either be in the format
    #     command or command=value. Here is a list of commands:
    #          * def/sdc/netlist/powered_netlist/sdf/spef/odb=: Saves a view to
    #            the qualified path.
    #          * def/sdc/netlist/powered_netlist/sdf/spef/odb: Saves a view to a
    #            default path with a default name.
    #          * to=: Replace the default save directory for unqualified views,
    #            which is $::env(TMP_DIR) by default. Must be set before
    #            any unqualified views.
    #          * name=: Replace the default name for unqualified views,
    #            which is $::env(DESIGN_NAME) by default. Must be set before
    #            any unqualified views.
    #          * index=: Turns running [index_file] for unqualified views on
    #            or off. Must be set before any unqualified views.
    #          * index: alias for index=1
    #          * noindex: alias for index=0
    #
    set options {
        {-tool required}
        {-indexed_log optional}
        {-save optional}
    }

    # -netlist_in: Specify that the input is CURRENT_NETLIST and not the ODB file.
    # -def_in: Specify that the input is CURRENT_DEF and not the ODB file.
    # -gui: Launch the GUI (OpenROAD Only)
    # -no_update_current: See '-save'
    set flags {-netlist_in -gui -no_update_current}

    parse_key_args "run_tcl_script" args arg_values $options flag_map $flags

    set_if_unset arg_values(-indexed_log) /dev/null
    set_if_unset arg_values(-save) ""

    set create_reproducible 0
    set script [lindex $args 0]
    set tool $arg_values(-tool)

    set save_list [list]
    set save_dir "$::env(TMP_DIR)"
    set metrics_path ""
    set index 1
    set name $::env(DESIGN_NAME)

    set saved_values [split $arg_values(-save) ","]

    # C-style for loop because Tcl foreach cannot handle the list being
    # dynamically modified
    set layout_saved 0
    set odb_saved 0
    for {set i 0} {$i < [llength $saved_values]} {incr i} {
        set value [lindex $saved_values $i]
        set kv [split $value "="]
        set element [lindex $kv 0]
        set value [lindex $kv 1]

        if { $element == "to" } {
            set save_dir $value
        } elseif { $element == "name" } {
            set name $value
        } elseif { $element == "index" } {
            if { $value == "0" || $value == "1" } {
                set index $value
            } elseif { $value == "" } {
                set index "1"
            } else {
                puts_err "Invalid value $value for \"index\" command."
                flow_fail
            }
        } elseif { $element == "noindex" } {
            set index 0
        } elseif { $element != "" } {
            set extension $element

            if { $element == "netlist" } {
                set extension "nl.v"
            } elseif { $element == "powered_netlist" } {
                set extension "pnl.v"
            } elseif { $element == "metrics" } {
                set extension ".json"
            } elseif { $element == "odb" } {
                set odb_saved 1
            } elseif { $element == "def" } {
                set layout_saved 1
            }

            if { $value != "/dev/null" } {
                if { $value == "" } {
                    set value "$save_dir/$name.$extension"
                    if { $index } {
                        set value [index_file $value]
                    }
                }

                if { $element == "metrics" } {
                    set metrics_path $value
                } else {
                    lappend save_list $element $value
                }
            }
        }
    }

    if { $layout_saved && !$odb_saved } {
        puts_err "The layout was saved, but not the ODB format was not. This is a bug with OpenLane. Please file an issue."
        flow_fail
    }

    if { $tool == "openroad" } {
        set args [list]
        lappend args $::env(OPENROAD_BIN)
        if { [info exists flag_map(-gui)] } {
            lappend args -gui
        } else {
            lappend args -exit
        }
        if { $metrics_path != "" } {
            lappend args -metrics $metrics_path
        }
        lappend args $script
        lappend args |& tee $::env(TERMINAL_OUTPUT) $arg_values(-indexed_log)
        foreach {element value} $save_list {
            set cap [string toupper $element]
            set ::env(SAVE_${cap}) $value
        }
    } elseif { $arg_values(-tool) == "magic" } {
        set args "magic -noconsole -dnull -rcfile $::env(MAGIC_MAGICRC) < $script |& tee $::env(TERMINAL_OUTPUT) $arg_values(-indexed_log)"
    } else {
        puts_err "run_tcl_script only supports '-tool magic' and '-tool openroad' for now."
        return -code error
    }

    if { ! [catch { set cmd_log_file [open $::env(RUN_DIR)/cmds.log a+] } ]} {
        set timestamp [clock format [clock seconds]]
        puts $cmd_log_file "$timestamp - Executing \"$args\"\n"
        close $cmd_log_file
    }

    set script_relative [relpath . $script]

    set exit_code 0

    if { [info exists ::env(CREATE_REPRODUCIBLE_FROM_SCRIPT)] && [string match *$::env(CREATE_REPRODUCIBLE_FROM_SCRIPT) $script] } {
        puts_info "Script $script matches $::env(CREATE_REPRODUCIBLE_FROM_SCRIPT), creating reproducible..."
        set create_reproducible 1
    } else {
        puts_verbose "Executing $tool with Tcl script '$script_relative'..."

        set exit_code [catch {exec {*}$args} error_msg]

        if { $exit_code } {
            set print_error_msg "during executing $tool script $script"
            set log_relpath [relpath $::env(PWD) $arg_values(-indexed_log)]

            puts_err "$print_error_msg"
            puts_err "Log: $log_relpath"
            puts_err "Last 10 lines:\n[exec tail -10 << $error_msg]\n"

            set create_reproducible 1
            puts_err "Creating issue reproducible..."
        }
    }

    if { $create_reproducible } {
        save_state

        set reproducible_dir $::env(RUN_DIR)/issue_reproducible
        set reproducible_dir_relative [relpath $::env(PWD) $reproducible_dir]

        set or_issue_arg_list [list]

        lappend or_issue_arg_list --tool $tool
        lappend or_issue_arg_list --output-dir $reproducible_dir
        lappend or_issue_arg_list --script $script
        lappend or_issue_arg_list --run-path $::env(RUN_DIR)

        if { [info exists flag_map(-netlist_in)] } {
            lappend or_issue_arg_list --input-type "netlist" $::env(CURRENT_NETLIST)
        } elseif { $tool != "openroad" || [info exists flag_map(-def_in)]} {
            lappend or_issue_arg_list --input-type "def" $::env(CURRENT_DEF)
        } else {
            lappend or_issue_arg_list --input-type "odb" $::env(CURRENT_ODB)
        }

        if {![catch {exec -ignorestderr python3 $::env(SCRIPTS_DIR)/or_issue.py {*}$or_issue_arg_list} result] == 0} {
            puts_err "Failed to package reproducible."
            flow_fail
        }

        if { $exit_code } {
            puts_info "Reproducible packaged: Please tarball and upload '$reproducible_dir_relative' if you're going to submit an issue."
            flow_fail
        } else {
            puts_info "Reproducible packaged at '$reproducible_dir_relative'."
            exit 0
        }
    }

    if { ![info exist flag_map(-no_update_current)]} {
        foreach {element value} $save_list {
            set cap [string toupper $element]

            set save_env SAVE_$cap
            set current_env CURRENT_$cap

            if { $element == "def" } {
                set_def $::env(SAVE_DEF)
            } elseif { $element == "odb" } {
                set_odb $::env(SAVE_ODB)
            } elseif { $element == "sdc" } {
                set_sdc $::env(SAVE_SDC)
            } elseif { $element == "netlist" } {
                set_netlist -lec $::env(SAVE_NETLIST)
            } else {
                set ::env(${current_env}) $::env(${save_env})
            }
            unset ::env(${save_env})
        }
    }
}


package provide openlane_utils 0.9

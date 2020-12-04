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

proc handle_deprecated_command {new} {
  set invocation [info level -1]
  set caller [lindex $invocation 0]
  set args [lrange $invocation 1 end]

  puts_warn "$caller is now deprecated; use $new instead."
  eval {$new {*}$args}
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
        set cmd "set ${var} \"${val}\""
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
        puts_err "Please check ${tool} log file"


        if { ! [catch { set error_log_file [open $::env(RUN_DIR)/error.log a+] } ]} {
            puts_err "Dumping to $::env(RUN_DIR)/error.log"
            puts $error_log_file "$print_error_msg"
            puts $error_log_file "Last 10 lines:\n[exec tail -10 << $error_msg]\n"
            close $error_log_file
        }

        return -code error
    }
}

proc make_array {pesudo_dict prefix} {
	foreach element $pesudo_dict {
		set key [lindex $element 0]
		set value [lindex $element 1]
		set returned_array($key) ${prefix}${value}
	}
	return [array get returned_array]
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
      return [exec tput setaf $color]$txt[exec tput setaf 7]
    } else {
      return $txt
    }
}

proc puts_err {txt} {
  puts "[color_text 1 "\[ERROR\]: $txt"]"
}

proc puts_success {txt} {
  puts "[color_text 2 "\[SUCCESS\]: $txt"]"
}

proc puts_warn {txt} {
  puts "[color_text 3 "\[WARNING\]: $txt"]"
}

proc puts_info {txt} {
  puts "[color_text 6 "\[INFO\]: $txt"]"
}

proc generate_final_summary_report {args} {
    puts_info "Generating Final Summary Report..."
	set options {
        {-output optional}
    }
    set flags {}
    parse_key_args "generate_final_summary_report" args arg_values $options flags_map $flags
    
    set_if_unset arg_values(-output) $::env(REPORTS_DIR)/final_summary_report.csv

    if { $::env(GENERATE_FINAL_SUMMARY_REPORT) == 1 } {
        try_catch python3 $::env(OPENLANE_ROOT)/report_generation_wrapper.py -d $::env(DESIGN_DIR) -dn $::env(DESIGN_NAME) -t $::env(RUN_TAG) -o $arg_values(-output) -r $::env(RUN_DIR)
    }
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

package provide openlane_utils 0.9

# Copyright 2020-2023 Efabless Corporation
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
proc convert_pg_pins {lib_in lib_out} {
    try_exec sed -E {s/^([[:space:]]+)pg_pin(.*)/\1pin\2\n\1    direction : "inout";/g} $lib_in > $lib_out
}

proc run_yosys {args} {
    set options {
        {-output optional}
        {-log optional}
        {-indexed_log optional}
    }
    set flags {
        -no_set_netlist
    }

    parse_key_args "run_yosys" args arg_values $options flags_map $flags

    if { [info exists arg_values(-log)] } {
        puts_warn "run_yosys -log is deprecated: replace -log with -indexed_log."
        set arg_values(-indexed_log) $arg_values(-log)
    }

    set_if_unset arg_values(-output) $::env(synthesis_results)/$::env(DESIGN_NAME).v
    set_if_unset arg_values(-indexed_log) /dev/null

    set ::env(synth_report_prefix) [index_file $::env(synthesis_reports)/synthesis]

    set ::env(LIB_SYNTH_COMPLETE_NO_PG) [list]
    foreach lib $::env(LIB_SYNTH_COMPLETE) {
        set fbasename [file rootname [file tail $lib]]
        set lib_path [index_file $::env(synthesis_tmpfiles)/$fbasename.no_pg.lib]
        convert_pg_pins $lib $lib_path
        lappend ::env(LIB_SYNTH_COMPLETE_NO_PG) $lib_path
    }

    set ::env(LIB_SYNTH_NO_PG) [list]
    foreach lib $::env(LIB_SYNTH) {
        set fbasename [file rootname [file tail $lib]]
        set lib_path [index_file $::env(synthesis_tmpfiles)/$fbasename.no_pg.lib]
        convert_pg_pins $lib $lib_path
        lappend ::env(LIB_SYNTH_NO_PG) $lib_path
    }

    set ::env(SAVE_NETLIST) $arg_values(-output)
    run_yosys_script $::env(SYNTH_SCRIPT) -indexed_log $arg_values(-indexed_log)


    if { ! [info exists flags_map(-no_set_netlist)] } {
        set_netlist $::env(SAVE_NETLIST)
    }

    # The following is a naive workaround to OpenROAD not accepting defparams.
    # It *should* be handled with a fix to the OpenROAD Verilog parser.
    if { [info exists ::env(SYNTH_EXPLORE)] && $::env(SYNTH_EXPLORE) } {
        puts_info "This is a Synthesis Exploration and so no need to remove the defparam lines."
    } else {
        try_exec sed -i.bak {/defparam/d} $arg_values(-output)
        exec rm -f $arg_values(-output).bak
    }
    unset ::env(SAVE_NETLIST)
}

proc run_synth_exploration {args} {
    if { $::env(SYNTH_NO_FLAT) } {
        puts_err "Cannot run synthesis exploration with SYNTH_NO_FLAT."
        throw_error
    }

    puts_info "Running Synthesis Exploration..."

    set ::env(SYNTH_EXPLORE) 1
    set log [index_file $::env(synthesis_logs)/synthesis.log]

    run_yosys -indexed_log $log

    set exploration_report [index_file $::env(synthesis_reports)/exploration_analysis.html]

    puts_info "Generating exploration report..."
    try_exec python3 $::env(SCRIPTS_DIR)/synth_exp/analyze.py\
        --output $exploration_report\
        [index_file $::env(synthesis_logs)/synthesis.log]

    set exploration_report_relative [relpath . $exploration_report]

    puts_success "Done with synthesis exploration: See report at '$exploration_report_relative'."

    # Following two cannot be indexed- referenced by path in the HTML file.
    file copy $::env(SCRIPTS_DIR)/synth_exp/table.css $::env(synthesis_reports)
    file copy $::env(SCRIPTS_DIR)/synth_exp/utils.js $::env(synthesis_reports)
}

proc run_synthesis {args} {
    increment_index
    TIMER::timer_start
    set log [index_file $::env(synthesis_logs)/synthesis.log]
    puts_info "Running Synthesis (log: [relpath . $log])..."

    set ::env(CURRENT_SDC) $::env(BASE_SDC_FILE)
    # in-place insertion
    if { [file exists $::env(synthesis_results)/$::env(DESIGN_NAME).v] } {
        puts_warn "A netlist at $::env(synthesis_results)/$::env(DESIGN_NAME).v already exists. Synthesis will be skipped."
        set_netlist $::env(synthesis_results)/$::env(DESIGN_NAME).v
    } else {
        run_yosys -indexed_log $log
        if { $::env(QUIT_ON_SYNTH_CHECKS) } {
            set pre_synth_report $::env(synth_report_prefix)_pre_synth.chk.rpt
            if { [info exists ::env(SYNTH_ELABORATE_ONLY)] \
                && $::env(SYNTH_ELABORATE_ONLY) == 1 } {
                set pre_synth_report $::env(synth_report_prefix).chk.rpt
            }
            run_synthesis_checkers $log $pre_synth_report
        }
    }
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "synthesis - yosys"

    if { [info exists ::env(CLOCK_PORT)] && $::env(CLOCK_PORT) != "" } {
        set missing_clock_ports [exec\
            python3 $::env(SCRIPTS_DIR)/check_clock_ports.py\
            --top $::env(DESIGN_NAME)\
            --netlist-in $::env(synthesis_tmpfiles)/$::env(DESIGN_NAME).json\
            {*}$::env(CLOCK_PORT)]
        set ports_not_found 0
        foreach {clock_port} $missing_clock_ports {
            puts_err "The specified clock port '$clock_port' is not a valid input or inout port in the top level module."
            set ports_not_found 1
        }
        if { $ports_not_found } {
            throw_error
        }
    }

    if { $::env(QUIT_ON_ASSIGN_STATEMENTS) == 1 } {
        check_assign_statements $::env(CURRENT_NETLIST)
    }

    if { $::env(QUIT_ON_UNMAPPED_CELLS) == 1 } {
        set strategy_escaped [string map {" " _} $::env(SYNTH_STRATEGY)]
        set final_stat_file $::env(synth_report_prefix).$strategy_escaped.stat.rpt
        if { [info exists ::env(SYNTH_ELABORATE_ONLY)] \
            && $::env(SYNTH_ELABORATE_ONLY) == 1 } {
            set final_stat_file $::env(synth_report_prefix).stat
        }
        check_unmapped_cells $final_stat_file
    }

    run_sta\
        -log $::env(synthesis_logs)/sta.log \
        -netlist_in \
        -pre_cts \
        -save_to $::env(synthesis_results) \
        -tool sta

    set ::env(LAST_TIMING_REPORT_TAG) [index_file $::env(synthesis_reports)/syn_sta]

    if { [info exists ::env(SYNTH_USE_PG_PINS_DEFINES)] } {
        puts_info "Creating a netlist with power/ground pins."
        if { ! [info exists ::env(SYNTH_DEFINES)] } {
            set ::env(SYNTH_DEFINES) [list]
        }
        lappend ::env(SYNTH_DEFINES) {*}$::env(SYNTH_USE_PG_PINS_DEFINES)
        run_yosys -output $::env(synthesis_tmpfiles)/pg_define.v -no_set_netlist
    }

}

proc verilog_elaborate {args} {
    # usually run on structural verilog (top-level netlists)
    set synth_script_old $::env(SYNTH_SCRIPT)
    set ::env(SYNTH_SCRIPT) $::env(SCRIPTS_DIR)/yosys/elaborate.tcl
    run_yosys {*}$args
    set ::env(SYNTH_SCRIPT) $synth_script_old
}

proc yosys_rewrite_verilog {filename} {
    if { !$::env(YOSYS_REWRITE_VERILOG) } {
        puts_verbose "Skipping Verilog rewrite..."
        return
    }

    increment_index
    TIMER::timer_start
    set log [index_file $::env(synthesis_logs)/rewrite_verilog.log]
    puts_info "Rewriting $filename to $::env(SAVE_NETLIST) using Yosys (log: [relpath . $log])..."

    assert_files_exist $filename

    set ::env(SAVE_NETLIST) $filename

    run_yosys_script $::env(SCRIPTS_DIR)/yosys/rewrite_verilog.tcl -indexed_log $log

    unset ::env(SAVE_NETLIST)

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "verilog rewrite - yosys"
}

proc generate_blackbox_verilog {inputs output {defines ""}} {
    set defines_flag ""
    set ::env(YOSYS_IN) $inputs
    set ::env(YOSYS_OUT) $output
    if { $defines != "" } {
        set ::env(YOSYS_DEFINES) $defines
    }
    try_exec yosys -c $::env(SCRIPTS_DIR)/yosys/blackbox.tcl

    set out_str [cat $output]
    set f [open $output w]
    puts $f "/* verilator lint_off UNDRIVEN */\n/* verilator lint_off UNUSEDSIGNAL */\n$out_str\n/* verilator lint_on UNUSEDSIGNAL */\n/* verilator lint_on UNDRIVEN */\n"
    close $f

    set inputs_rel [list]
    foreach input $inputs {
        lappend inputs_rel [relpath . $input]
    }

    puts_verbose "Generated black-box model ([relpath . $output]) from ($inputs_rel)."
}

proc run_verilator {} {
    set bb_dir $::env(synthesis_tmpfiles)/blackbox
    file mkdir $bb_dir

    set pdk_model_blackbox [list]
    set included_blackbox_models [glob -nocomplain "$::env(PDK_ROOT)/$::env(PDK)/libs.ref/$::env(STD_CELL_LIBRARY)/verilog/*__blackbox.v"]
    if { [llength $included_blackbox_models]} {
        foreach model $included_blackbox_models {
            set output_file "$bb_dir/[file rootname [file tail $model]].v"
            generate_blackbox_verilog $model $output_file
            lappend pdk_model_blackbox $output_file
        }
    } else {
        # No black-box model in PDK: gotta try our best here
        set pdk_models [glob -nocomplain "$::env(PDK_ROOT)/$::env(PDK)/libs.ref/$::env(STD_CELL_LIBRARY)/verilog/*.v"]
        foreach model $pdk_models {
            set output_file "$bb_dir/[file rootname [file tail $model]].v"

            set patched_file "$bb_dir/[file rootname [file tail $model]].patched.v"
            try_exec python3 $::env(SCRIPTS_DIR)/clean_models.py\
                --output $patched_file\
                $model

            generate_blackbox_verilog $patched_file $output_file FUNCTIONAL
            lappend pdk_model_blackbox $output_file
        }
    }
    set log $::env(synthesis_logs)/linter.log
    set arg_list [list]
    if { $::env(LINTER_INCLUDE_PDK_MODELS) } {
        lappend arg_list {*}$pdk_model_blackbox
    }
    if { [info exists ::env(VERILOG_FILES_BLACKBOX)] } {
        set output_file "$bb_dir/extra.v"
        if { [info exists ::env(LINTER_DEFINES)] } {
            generate_blackbox_verilog $::env(VERILOG_FILES_BLACKBOX) $output_file "$::env(LINTER_DEFINES)"
        } else {
            generate_blackbox_verilog $::env(VERILOG_FILES_BLACKBOX) $output_file
        }

        lappend arg_list {*}$output_file
    }
    lappend arg_list {*}$::env(VERILOG_FILES)

    set incdirs ""
    if { [info exists ::env(VERILOG_INCLUDE_DIRS)] } {
        foreach incdir $::env(VERILOG_INCLUDE_DIRS) {
            set incdirs "$incdirs +incdir+$incdir"
        }
    }
    lappend arg_list {*}$incdirs

    lappend arg_list -Wno-fatal
    if { $::env(LINTER_RELATIVE_INCLUDES) } {
        lappend arg_list "--relative-includes"
    }

    set defines ""
    if { [info exists ::env(LINTER_DEFINES)] } {
        foreach define $::env(LINTER_DEFINES) {
            set defines "$defines +define+$define"
        }
    } elseif { [info exists ::env(SYNTH_DEFINES)] } {
        foreach define $::env(SYNTH_DEFINES) {
            set defines "$defines +define+$define"
        }
    }
    lappend arg_list {*}$defines

    puts_info "Running linter (Verilator) (log: [relpath . $log])..."
    catch_exec verilator \
        -Wall \
        --lint-only \
        --Wno-DECLFILENAME \
        --top-module $::env(DESIGN_NAME) \
        {*}$arg_list |& tee $log $::env(TERMINAL_OUTPUT)

    set timing_errors [exec bash -c "grep -i 'Error-NEEDTIMINGOPT' $log || true"]
    if { $timing_errors ne "" } {
        set msg "Timing constructs found in the RTL. Please remove them or add a preprocessor guard. It is heavily discouraged to rely on timing constructs in synthesis."
        if { $::env(QUIT_ON_LINTER_ERRORS) } {
            puts_err $msg
            throw_error
        } else {
            puts_warn $msg
        }
    }

    set errors_count [exec bash -c "grep -i '%Error' $log | wc -l"]
    if { [expr $errors_count > 0] } {
        if { $::env(QUIT_ON_LINTER_ERRORS) } {
            puts_err "$errors_count errors found by linter"
            throw_error
        }
        puts_warn "$errors_count errors found by linter"
    } else {
        puts_info "$errors_count errors found by linter"
    }
    set warnings_count [exec bash -c "grep -i '%Warning' $log | wc -l"]
    if { [expr $warnings_count > 0] } {
        if { $::env(QUIT_ON_LINTER_WARNINGS) } {
            puts_err "$warnings_count warnings found by linter"
            throw_error
        }
        puts_warn "$warnings_count warnings found by linter"
    } else {
        puts_info "$warnings_count warnings found by linter"
    }
}

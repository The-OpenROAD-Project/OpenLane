# Copyright 2021 The University of Michigan
# Copyright 2022 Efabless Corporation
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

proc insert_buffer {args} {
    set options {
        {-at_pin required}
        {-buffer_cell required}
        {-net_name optional}
        {-inst_name optional}
    }
    set flags {-block -place}

    parse_key_args "insert_buffer" args arg_values $options flags_map $flags

    if { ![info exists ::env(INSERT_BUFFER_COUNTER)]} {
        set ::env(INSERT_BUFFER_COUNTER) 0
    }

    set_if_unset arg_values(-net_name) "inserted_buffer_$::env(INSERT_BUFFER_COUNTER)_net"
    set_if_unset arg_values(-inst_name) "inserted_buffer_$::env(INSERT_BUFFER_COUNTER)"

    set pin_type "ITerm"
    if { [info exists flags_map(-block)] } {
        set pin_type "BTerm"
    }

    if { ![info exists flags_map(-place)] } {
        set ::env(INSERT_BUFFER_NO_PLACE) "1"
    }


    set ::env(INSERT_BUFFER_COMMAND) "$arg_values(-at_pin) $pin_type $arg_values(-buffer_cell) $arg_values(-net_name) $arg_values(-inst_name)"
    run_openroad_script $::env(SCRIPTS_DIR)/openroad/insert_buffer.tcl\
        -indexed_log [index_file $::env(routing_logs)/insert_buffer.log]\
        -save "to=$::env(routing_tmpfiles),def,odb"
    unset ::env(INSERT_BUFFER_COMMAND)

    if { ![info exists flags_map(-place)] } {
        unset ::env(INSERT_BUFFER_NO_PLACE)
    }

    incr ::env(INSERT_BUFFER_COUNTER)
}

proc eco_gen_buffer {args} {
    # Read all multi corner STA files
    set files [glob -directory $::env(signoff_logs) *parasitics_multi_corner_sta*log]
    set sta_args [list]
    foreach f $files {
        lappend sta_args -i $f
    }

    puts_info "\[ECO: $::env(ECO_ITER)\] Generating buffer insertion script..."

    try_catch $::env(OPENROAD_BIN) -exit -python $::env(SCRIPTS_DIR)/odbpy/eco.py \
        insert_buffer \
        -o $::env(routing_tmpfiles)/eco_fix.tcl \
        -s $::env(ECO_SKIP_PIN) \
        -l $::env(MERGED_LEF) \
        {*}$sta_args \
        $::env(CURRENT_DEF)
}

proc eco_output_check {args} {
    puts_info "\[ECO: $::env(ECO_ITER)\] Checking output..."

    eco_gen_buffer

    set lines [split [cat "$::env(routing_results)/eco_fix.tcl"] "\n"]
    foreach line $lines {
        # Use regex to determine if finished here
        if {[regexp {No violations} $line]} {
            puts_info "ECO done after [expr $::env(ECO_ITER) + 1] iterations."
            set ::env(ECO_FINISH) 1;
        } else {
            puts_info "\[ECO: $::env(ECO_ITER)\] Timing violations found, performing another ECO iteration..."
            incr ::env(ECO_ITER) 1;
        }
        break
    }
}

proc run_apply_step {args} {
    puts_info "\[ECO: $::env(ECO_ITER)\] Applying fixes..."

    set ::env(ECO_FIX_FILE) $::env(routing_results)/eco_fix.tcl

    # This runs the tcl script to apply the fixes. Buffers are placed over the top of
    # the cells being fixed, and then detailed placement is called to fix it up.
    run_openroad_script $::env(SCRIPTS_DIR)/openroad/eco.tcl \
        -indexed_log [index_file $::env(routing_logs)/eco.log] \
        -save "to=$::env(routing_results),name=eco,noindex,netlist,def,odb"
}

proc run_eco_flow {args} {
    puts_info "Starting ECO flow..."

    set prev_routing_tmpfiles $::env(routing_tmpfiles)
    set prev_routing_logs $::env(routing_logs)
    set prev_routing_reports $::env(routing_reports)
    set prev_routing_results $::env(routing_results)
    set prev_signoff_logs $::env(signoff_logs)

    while (1) {
        set ::env(routing_tmpfiles) ${prev_routing_tmpfiles}/eco_$::env(ECO_ITER)
        set ::env(routing_logs) ${prev_routing_logs}/eco_$::env(ECO_ITER)
        set ::env(routing_reports) ${prev_routing_reports}/eco_$::env(ECO_ITER)
        set ::env(routing_results) ${prev_routing_results}/eco_$::env(ECO_ITER)
        set ::env(signoff_logs) ${prev_signoff_logs}/eco_$::env(ECO_ITER)

        file mkdir $::env(routing_tmpfiles)
        file mkdir $::env(routing_logs)
        file mkdir $::env(routing_reports)
        file mkdir $::env(routing_results)
        file mkdir $::env(signoff_logs)

        run_routing
        run_parasitics_sta
        eco_output_check

        if {$::env(ECO_FINISH) == 1} {
            break
        }

        puts_info "\[ECO: $::env(ECO_ITER)\] Starting iteration..."
        run_apply_step
    }

    # Copy post ECO files back to the non ECO directories
    file copy -force {*}[glob -dir $::env(routing_tmpfiles) *] $prev_routing_tmpfiles
    file copy -force {*}[glob -dir $::env(routing_logs) *] $prev_routing_logs
    file copy -force {*}[glob -dir $::env(routing_reports) *] $prev_routing_reports
    file copy -force {*}[glob -dir $::env(routing_results) *] $prev_routing_results
    file copy -force {*}[glob -dir $::env(signoff_logs) *] $prev_signoff_logs

    ins_fill_cells

    set ::env(routing_tmpfiles) $prev_routing_tmpfiles
    set ::env(routing_logs) $prev_routing_logs
    set ::env(routing_reports) $prev_routing_reports
    set ::env(routing_results) $prev_routing_results
    set ::env(signoff_logs) $prev_signoff_logs
}

package provide openlane 0.9

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

    set ::env(SAVE_DEF) [index_file $::env(eco_tmpfiles)/$::env(DESIGN_NAME).def]

    set ::env(INSERT_BUFFER_COMMAND) "$arg_values(-at_pin) $pin_type $arg_values(-buffer_cell) $arg_values(-net_name) $arg_values(-inst_name)"

    run_openroad_script $::env(SCRIPTS_DIR)/openroad/insert_buffer.tcl -indexed_log [index_file $::env(eco_logs)/insert_buffer.log]

    unset ::env(INSERT_BUFFER_COMMAND)

    if { ![info exists flags_map(-place)] } {
        unset ::env(INSERT_BUFFER_NO_PLACE)
    }


    incr ::env(INSERT_BUFFER_COUNTER)

    set_def $::env(SAVE_DEF)


}

proc eco_gen_buffer {args} {
    # Generate fixes via the gen_insert_buffer Python script
    # It reads in the LATEST multi-corner sta min report

    set lef_file [lindex [glob -directory $::env(RUN_DIR)/tmp \
        *_unpadded.lef] end]
    set sta_file [lindex [glob -directory $::env(routing_logs) \
        *multi_corner_sta*] end]

    set files [glob -directory $::env(routing_logs) *multi_corner_sta*]
    set newest 0
    foreach f $files {
        set mtime [file mtime $f]
        if { $newest == 0 || $mtime > $newest } {
            set newest $mtime
            set sta_file $f
        }
    }

    if { $::env(ECO_ITER) == 0 } {
        set def_file [lindex [glob -directory $::env(eco_results)/arcdef \
            $::env(ECO_ITER)_post-route.def] end]
    } else {
        set def_file [lindex [glob -directory $::env(eco_results)/def \
            *.def] end]
    }

    puts_info "\[ECO: $::env(ECO_ITER)\] Generating buffer insertion script..."
    puts_verbose "Using report $sta_file..."

    try_catch $::env(OPENROAD_BIN) \
        -python $::env(SCRIPTS_DIR)/gen_insert_buffer.py \
        -s $::env(ECO_SKIP_PIN) \
        -i $sta_file \
        -l $lef_file \
        -d $def_file \
        -o $::env(eco_results)/fix/eco_fix_$::env(ECO_ITER).tcl
}

proc eco_output_check {args} {
    puts_info "\[ECO: $::env(ECO_ITER)\] Checking output..."

    eco_gen_buffer

    set lines [split [cat "$::env(eco_results)/fix/eco_fix_$::env(ECO_ITER).tcl"] "\n"]
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
    try_catch $::env(OPENROAD_BIN) \
        -exit $::env(SCRIPTS_DIR)/openroad/eco.tcl \
        |& tee $::env(TERMINAL_OUTPUT) $::env(eco_logs)/$::env(ECO_ITER)_eco.log

    if { $::env(ECO_ITER) > 10 } {
        pause;
    }

    set_netlist $::env(eco_results)/net/eco_$::env(ECO_ITER).v
    set_def $::env(eco_results)/def/eco_$::env(ECO_ITER).def
}

proc run_eco_flow {args} {
    # Assume script generate fix commands
    puts_info "Starting ECO flow..."

    # Re-organize report/result files here
    exec sh $::env(SCRIPTS_DIR)/reorg_reports.sh
    eco_output_check

    while {$::env(ECO_FINISH) != 1} {

        puts_info "\[ECO: $::env(ECO_ITER)\] Starting iteration..."
        # Then run detailed placement again
        # Get the connections then destroy them

        # Pause to see puts output
        if {$::env(ECO_ITER) > 10} {
            puts_info "Ran for 10 itertations; Check files"
            pause;
        }

        run_apply_step
        run_routing
        run_parasitics_sta\
            -spef_out_prefix $::env(eco_results)/spef/$::env(ECO_ITER)_$::env(DESIGN_NAME)\
            -sdf_out $::env(eco_results)/sdf/$::env(ECO_ITER)_$::env(DESIGN_NAME).sdf

        ins_fill_cells

        if { $::env(ECO_ITER) != 0 } {
            set post_eco_net [lindex [glob -directory $::env(eco_results)/net *.v]   end]
            set post_eco_def [lindex [glob -directory $::env(eco_results)/def *.def] end]
            file copy -force $post_eco_net $::env(synthesis_results)/$::env(DESIGN_NAME).synthesis_preroute.v
            file copy -force $post_eco_def $::env(routing_results)/post_eco-$::env(DESIGN_NAME).def
        }
    }
}
package provide openlane 0.9

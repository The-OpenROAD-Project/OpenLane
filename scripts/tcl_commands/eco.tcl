# Copyright 2021 The University of Michigan
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

proc eco_read_fix {args} {
    set path "$::env(eco_results)/fix"

    set   fp   [open  $path/eco_fix_$::env(ECO_ITER).tcl "r"]
    set   fd   [read  $fp]
    set   txt  [split $fd "\n"]
    close $fp

    return $txt
}

proc eco_gen_buffer {args} {
    # Generate fixes via the gen_insert_buffer Python script
    # It reads in the LATEST multi-corner sta min report
    if { $::env(ECO_ITER) == 0 } {
        puts "Generating fixes for ECO iteration 1!"
        puts "Parsing STA report: "
        puts [lindex [glob -directory $::env(routing_logs) \
            *multi_corner_sta*] end]
        puts "Input Lef File: "
        puts [lindex [glob -directory $::env(RUN_DIR)/tmp \
            *_unpadded.lef] end]
        puts "Input Def File: "
        puts $::env(routing_results)
        puts [lindex [glob -directory $::env(eco_results)/arcdef \
            $::env(ECO_ITER)_post-route.def] end]
        # pause;

        try_catch $::env(OPENROAD_BIN) \
            -python $::env(SCRIPTS_DIR)/gen_insert_buffer.py \
            -s $::env(ECO_SKIP_PIN) \
            -i [lindex [glob -directory $::env(routing_logs) \
            *multi_corner_sta*] end] \
            -l [lindex [glob -directory $::env(RUN_DIR)/tmp \
            *_unpadded.lef] end] \
            -d [lindex [glob -directory $::env(eco_results)/arcdef \
            $::env(ECO_ITER)_post-route.def] end] \
            -o $::env(eco_results)/fix/eco_fix_$::env(ECO_ITER).tcl
    } else {
        puts "Generating fixes for ECO iteration [expr {$::env(ECO_ITER) + 1}]!"
        puts "Parsing STA report: "
        puts [lindex [glob -directory $::env(routing_logs) \
            *multi_corner_sta*] end]
        puts "Input Lef File: "
        puts [lindex [glob -directory $::env(RUN_DIR)/tmp \
            *_unpadded.lef] end]
        puts "Input Def File: "
        puts [lindex [glob -directory $::env(eco_results)/def \
            *.def] end]
        # pause;

        try_catch $::env(OPENROAD_BIN) \
            -python $::env(SCRIPTS_DIR)/gen_insert_buffer.py \
            -s $::env(ECO_SKIP_PIN) \
            -i [lindex [glob -directory $::env(routing_logs) \
            *multi_corner_sta*] end] \
            -l [lindex [glob -directory $::env(RUN_DIR)/tmp \
            *_unpadded.lef] end] \
            -d [lindex [glob -directory $::env(eco_results)/def \
            *.def] end] \
            -o $::env(eco_results)/fix/eco_fix_$::env(ECO_ITER).tcl
    }
}

proc eco_output_check {args} {
    puts "Entering eco_output_check subproc!"

    eco_gen_buffer

    set lines [eco_read_fix]
    foreach line $lines {
        # Use regex to determine if finished here
        if {[regexp {No violations} $line]} {
            set ::env(ECO_FINISH) 1;
        } else {
            incr ::env(ECO_ITER) 1;
        }
        break
    }
}

proc run_apply_step {args} {
    puts "ECO: Applying Fixes!"
    try_catch $::env(OPENROAD_BIN) \
        -exit $::env(SCRIPTS_DIR)/openroad/apply_fix.tcl \
        |& tee $::env(TERMINAL_OUTPUT) $::env(eco_logs)/$::env(ECO_ITER)_eco.log

    if { $::env(ECO_ITER) > 10 } {
        pause;
    }
    set ::env(CURRENT_NETLIST) $::env(eco_results)/net/eco_$::env(ECO_ITER).v
    set ::env(CURRENT_DEF)     $::env(eco_results)/def/eco_$::env(ECO_ITER).def

    puts "ECO Iteration $::env(ECO_ITER): "
    puts "Set NETLIST/DEF in apply_fix.tcl"
    puts $::env(CURRENT_NETLIST)
    puts $::env(CURRENT_DEF)
}

proc run_eco_flow {args} {
    #set log          "$::env(eco_logs)"
    #set path         "$::env(eco_results)"
    #set fix_path     "$::env(eco_results)/fix"
    #set def_path     "$::env(eco_results)/def"
    #set net_path     "$::env(eco_results)/net"
    #set spef_path    "$::env(eco_results)/spef"
    #set sdf_path     "$::env(eco_results)/sdf"
    #set arc_def_path "$::env(eco_results)/arcdef"
    #file mkdir $log
    #file mkdir $path
    #file mkdir $fix_path
    #file mkdir $def_path
    #file mkdir $net_path
    #file mkdir $spef_path
    #file mkdir $sdf_path
    #file mkdir $arc_def_path


    # Assume script generate fix commands
    puts "Generating Fix commands (resize/insert)"

    # Re-organize report/result files here
    exec sh $::env(SCRIPTS_DIR)/reorg_reports.sh
    eco_output_check

    while {$::env(ECO_FINISH) != 1} {

        puts "Start ECO loop $::env(ECO_ITER)!"
        # Then run detailed placement again
        # Get the connections then destroy them

        # Pause to see puts output
        # pause;
        if {$::env(ECO_ITER) > 10} {
            puts "Ran for 10 itertations; Check files"
            pause;
        }

        set eco_steps [dict create "apply" {run_apply_step ""}\
            "routing" {run_routing_step ""}
        ]

        set_if_unset arg_values(-from) "apply";
        set_if_unset arg_values(-to) "routing";

        set exe 0;
        dict for {step_name step_exe} $eco_steps {
            puts "Re-running"
            puts $step_name
            if { [ string equal $arg_values(-from) $step_name ] } {
                set exe 1;
            }

            if { $exe } {
                # For when it fails
                set ::env(CURRENT_STEP) $step_name
                [lindex $step_exe 0] [lindex $step_exe 1] ;
            }

            if { [ string equal $arg_values(-to) $step_name ] } {
                set exe 0:
                break;
            }

        }
        # end of dict

        # Re-organize report files here
        exec sh $::env(SCRIPTS_DIR)/reorg_reports.sh
        eco_output_check
    }
    ins_fill_cells
    # end of while
    if { $::env(ECO_ITER) != 0 } {
        set post_eco_net [lindex [glob -directory $::env(eco_results)/net *.v]   end]
        set post_eco_def [lindex [glob -directory $::env(eco_results)/def *.def] end]
        file copy -force $post_eco_net $::env(synthesis_results)/$::env(DESIGN_NAME).synthesis_preroute.v
        file copy -force $post_eco_def $::env(routing_results)/post_eco-$::env(DESIGN_NAME).def
    }
}

package provide openlane 0.9

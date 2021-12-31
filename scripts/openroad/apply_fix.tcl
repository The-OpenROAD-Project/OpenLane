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

proc move_to_dir {filenames dirname} {
    foreach filename $filenames {
        file rename $filename [file join $dirname [file tail $filename]]
    }
}

if {[catch {read_lef $::env(MERGED_LEF_UNPADDED)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

foreach lib $::env(LIB_CTS) {
    read_liberty $lib
}
puts "ECO: Successfully read liberty!"

set cur_iter [expr $::env(ECO_ITER) == 0 ? \
                   0 : \
                   [expr {$::env(ECO_ITER) -1}] \
             ]

if {[expr {$cur_iter == 0}]} {
    if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
        puts stderr $errmsg
        exit 1
    }
    puts "Reading: $::env(CURRENT_NETLIST)"
    read_verilog $::env(CURRENT_NETLIST)
} else {
    if {[catch {read_def \
            $::env(eco_results)/def/eco_$cur_iter.def} errmsg]} {
        puts stderr $errmsg
        exit 1
    }
    puts "Reading results/eco/net/eco_$cur_iter.v"
    read_verilog $::env(eco_results)/net/eco_$cur_iter.v
}
puts "ECO: Successfully read Verilog!"

read_sdc -echo $::env(CURRENT_SDC)
puts "ECO: Successfully read SDC!"

puts "ECO: Sourcing eco.tcl!"
source $::env(SCRIPTS_DIR)/openroad/eco.tcl


write_verilog $::env(eco_results)/net/eco_$::env(ECO_ITER).v
write_def     $::env(eco_results)/def/eco_$::env(ECO_ITER).def

# Now these variables are set in flow.tcl
# right after this script is run
# set ::env(CURRENT_NETLIST) $::env(eco_results)/net/eco_$::env(ECO_ITER).v
# set ::env(CURRENT_DEF)     $::env(eco_results)/def/eco_$::env(ECO_ITER).def

# File post-processing for pre-eco
# if { $::env(ECO_ITER) == 1 } {
#     move_to_dir [glob -directory $::env(routing_results) *.def]  \
#                 $::env(eco_results)/def
#     move_to_dir [glob -directory $::env(routing_results) *.spef] \
#                 $::env(eco_results)/spef
#     move_to_dir [glob -directory $::env(routing_results) *.sdf]  \
#                 $::env(eco_results)/sdf
# }

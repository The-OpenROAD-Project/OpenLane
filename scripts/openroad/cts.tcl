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
source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
read -override_libs "$::env(LIB_CTS)"

set max_slew [expr {$::env(SYNTH_MAX_TRAN) * 1e-9}]; # must convert to seconds
set max_cap [expr {$::env(CTS_MAX_CAP) * 1e-12}]; # must convert to farad
# set rc values
source $::env(SCRIPTS_DIR)/openroad/common/set_rc.tcl
estimate_parasitics -placement

# Clone clock tree inverters next to register loads
# so cts does not try to buffer the inverted clocks.
repair_clock_inverters

puts "\[INFO\]: Configuring cts characterization..."
configure_cts_characterization\
    -max_slew $max_slew\
    -max_cap $max_cap

puts "\[INFO]: Performing clock tree synthesis..."
puts "\[INFO]: Looking for the following net(s): $::env(CLOCK_NET)"
puts "\[INFO]: Running Clock Tree Synthesis..."

set arg_list [list]

lappend arg_list -buf_list $::env(CTS_CLK_BUFFER_LIST)
lappend arg_list -root_buf $::env(CTS_ROOT_BUFFER)
lappend arg_list -sink_clustering_size $::env(CTS_SINK_CLUSTERING_SIZE)
lappend arg_list -sink_clustering_max_diameter $::env(CTS_SINK_CLUSTERING_MAX_DIAMETER)
lappend arg_list -sink_clustering_enable

if { $::env(CTS_DISTANCE_BETWEEN_BUFFERS) != 0 } {
    lappend arg_list -distance_between_buffers $::env(CTS_DISTANCE_BETWEEN_BUFFERS)
}

if { $::env(CTS_DISABLE_POST_PROCESSING) } {
    lappend arg_list -post_cts_disable
}

clock_tree_synthesis {*}$arg_list

set_propagated_clock [all_clocks]

estimate_parasitics -placement
puts "\[INFO]: Repairing long wires on clock nets..."
# CTS leaves a long wire from the pad to the clock tree root.
repair_clock_nets -max_wire_length $::env(CTS_CLK_MAX_WIRE_LENGTH)

estimate_parasitics -placement
write

puts "\[INFO\]: Legalizing..."
source $::env(SCRIPTS_DIR)/openroad/common/dpl_cell_pad.tcl

detailed_placement

if { [info exists ::env(PL_OPTIMIZE_MIRRORING)] && $::env(PL_OPTIMIZE_MIRRORING) } {
    optimize_mirroring
}
estimate_parasitics -placement

write
if { [catch {check_placement -verbose} errmsg] } {
    puts stderr $errmsg
    exit 1
}

puts "cts_report"
report_cts
puts "cts_report_end"

if {[info exists ::env(CLOCK_PORT)]} {
    if { [info exists ::env(CTS_REPORT_TIMING)] && $::env(CTS_REPORT_TIMING) } {
        set ::env(RUN_STANDALONE) 0
        source $::env(SCRIPTS_DIR)/openroad/sta.tcl
    }
} else {
    puts "\[WARN\]: No CLOCK_PORT found. Skipping STA..."
}

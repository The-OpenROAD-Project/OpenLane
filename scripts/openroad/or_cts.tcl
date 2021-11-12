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


if { $::env(ECO_STARTED) == 1} {

    puts "Sourcing eco.tcl!"
    source $::env(SCRIPTS_DIR)/tcl_commands/eco.tcl

} else {

    if {[catch {read_lef $::env(MERGED_LEF_UNPADDED)} errmsg]} {
        puts stderr $errmsg
        exit 1
    }

    foreach lib $::env(LIB_CTS) {
        read_liberty $lib
    }

    if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
        puts stderr $errmsg
        exit 1
    }

    read_verilog $::env(CURRENT_NETLIST)
    read_sdc -echo $::env(CURRENT_SDC)

    set max_slew [expr {$::env(SYNTH_MAX_TRAN) * 1e-9}]; # must convert to seconds
    set max_cap [expr {$::env(CTS_MAX_CAP) * 1e-12}]; # must convert to farad
    # set rc values
    source $::env(SCRIPTS_DIR)/openroad/or_set_rc.tcl 
    set_wire_rc -layer $::env(WIRE_RC_LAYER)
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

    clock_tree_synthesis\
        -buf_list $::env(CTS_CLK_BUFFER_LIST)\
        -root_buf $::env(CTS_ROOT_BUFFER)\
        -clk_nets $::env(CLOCK_NET)\
        -sink_clustering_enable\
        -sink_clustering_size $::env(CTS_SINK_CLUSTERING_SIZE)\
        -sink_clustering_max_diameter $::env(CTS_SINK_CLUSTERING_MAX_DIAMETER)

    set_propagated_clock [all_clocks]

    estimate_parasitics -placement
    puts "\[INFO]: Repairing long wires on clock nets..."
    # CTS leaves a long wire from the pad to the clock tree root.
    repair_clock_nets

    estimate_parasitics -placement
    write_def $::env(SAVE_DEF)

    set buffers "$::env(CTS_ROOT_BUFFER) $::env(CTS_CLK_BUFFER_LIST)" 
    set_placement_padding -masters $buffers -left $::env(CELL_PAD)
    puts "\[INFO\]: Legalizing..."
    detailed_placement
    if { [info exists ::env(PL_OPTIMIZE_MIRRORING)] && $::env(PL_OPTIMIZE_MIRRORING) } {
        optimize_mirroring
    }
    estimate_parasitics -placement

}


write_def $::env(SAVE_DEF)
write_sdc $::env(SAVE_SDC)
if { [check_placement -verbose] } {
	exit 1
}

puts "cts_report"
report_cts
puts "cts_report_end"

if {[info exists ::env(CLOCK_PORT)]} {
	if { [info exists ::env(CTS_REPORT_TIMING)] && $::env(CTS_REPORT_TIMING) } {
        set ::env(RUN_STANDALONE) 0
        source $::env(SCRIPTS_DIR)/openroad/or_sta.tcl 
	}
} else {
    puts "\[WARN\]: No CLOCK_PORT found. Skipping STA..."
}

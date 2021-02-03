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

if {[catch {read_lef $::env(MERGED_LEF_UNPADDED)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

read_lib $::env(LIB_SYNTH_COMPLETE)

if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

read_verilog $::env(CURRENT_NETLIST)
read_sdc $::env(BASE_SDC_FILE)

set max_slew [expr {$::env(SYNTH_MAX_TRAN) * 1e-9}]; # must convert to seconds
set max_cap [expr {$::env(CTS_MAX_CAP) * 1e-12}]; # must convert to farad
# Clone clock tree inverters next to register loads
# so cts does not try to buffer the inverted clocks.
set_wire_rc -layer $::env(WIRE_RC_LAYER)
estimate_parasitics -placement
repair_clock_inverters

puts "\[INFO\]: Configuring cts characterization..."
configure_cts_characterization\
    -max_slew $max_slew\
    -max_cap $max_cap\
    -sqr_cap $::env(CTS_SQR_CAP)\
    -sqr_res $::env(CTS_SQR_RES)

puts "\[INFO]: Performing clock tree synthesis..."
puts "\[INFO]: Looking for the following net(s): $::env(CLOCK_NET)"
puts "\[INFO]: Running Clock Tree Synthesis..."

clock_tree_synthesis\
    -buf_list $::env(CTS_CLK_BUFFER_LIST)\
    -root_buf $::env(CTS_ROOT_BUFFER)\
    -clk_nets $::env(CLOCK_NET)

puts "\[INFO]: Repairing long wires on clock nets..."
# CTS leaves a long wire from the pad to the clock tree root.
repair_clock_nets

write_def $::env(SAVE_DEF)

set buffers "$::env(CTS_ROOT_BUFFER) $::env(CTS_CLK_BUFFER_LIST)" 
set_placement_padding -masters $buffers -left $::env(CELL_PAD)
puts "\[INFO\]: Legalizing..."
detailed_placement -diamond_search_height $::env(PL_DIAMOND_SEARCH_HEIGHT)
write_def $::env(SAVE_DEF)
if { [check_placement -verbose] } {
	exit 1
}

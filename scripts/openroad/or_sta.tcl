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

set_cmd_units -time ns -capacitance pF -current mA -voltage V -resistance kOhm -distance um

read_liberty -min $::env(LIB_FASTEST)
read_liberty -max $::env(LIB_SLOWEST)
read_verilog $::env(CURRENT_NETLIST)
link_design $::env(DESIGN_NAME)
if { [info exists ::env(CURRENT_SPEF)] } {
    read_spef $::env(CURRENT_SPEF)
}

read_sdc -echo $::env(CURRENT_SDC)

puts "check_report"
report_checks -fields {capacitance slew input_pins nets fanout} -group_count 1000  -slack_max -0.01 > $::env(opensta_report_file_tag).rpt
puts "check_report_end"
puts "timing_report"
report_checks -fields {capacitance slew input_pins nets fanout} -unique -slack_max -0.0 -group_count 1000 > $::env(opensta_report_file_tag).timing.rpt
puts "timing_report_end"
puts "min_max_report"
report_checks -fields {capacitance slew input_pins nets fanout} -path_delay min_max -group_count 1000 > $::env(opensta_report_file_tag).min_max.rpt
puts "min_max_report_end"
puts "check_slew"
report_check_types -max_slew -max_capacitance -max_fanout -violators > $::env(opensta_report_file_tag).slew.rpt
puts "check_slew_end"
puts "wns_report"
report_wns
puts "wns_report_end"
puts "tns_report"
report_tns
puts "tns_report_end"
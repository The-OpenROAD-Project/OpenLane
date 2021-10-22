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

read_liberty $::env(LIB_SYNTH_COMPLETE)

read_verilog $::env(CURRENT_NETLIST)
link_design $::env(DESIGN_NAME)

if { [info exists ::env(CURRENT_SPEF)] } {
    read_spef $::env(CURRENT_SPEF)
}

read_sdc -echo $::env(CURRENT_SDC)

puts "\n=========================================================================="
puts "report_checks -path_delay min (Hold)"
puts "============================================================================"
report_checks -path_delay min -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 5

puts "\n=========================================================================="
puts "report_checks -path_delay max (Setup)"
puts "============================================================================"
report_checks -path_delay max -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 5 

puts "\n=========================================================================="
puts "report_checks -unique"
puts "============================================================================"
report_checks -unique -fields {slew cap input nets fanout} -slack_max -0.0 -format full_clock_expanded

puts "\n=========================================================================="
puts "report_checks -unconstrained"
puts "============================================================================"
report_checks -unconstrained -fields {slew cap input nets fanout} -format full_clock_expanded 

puts "\n=========================================================================="
puts "report_checks --slack_max -0.01"
puts "============================================================================"
report_checks -slack_max -0.01 -fields {slew cap input nets fanout} -format full_clock_expanded


puts "\n=========================================================================="
puts " report_check_types -max_slew -max_cap -max_fanout -violators"
puts "============================================================================"
report_check_types -max_slew -max_capacitance -max_fanout -violators


puts "\n=========================================================================="
puts "max slew violation count [sta::max_slew_violation_count]"
puts "max fanout violation count [sta::max_fanout_violation_count]"
puts "max cap violation count [sta::max_capacitance_violation_count]"
puts "============================================================================"

puts "\n=========================================================================="
puts " report_tns"
puts "============================================================================"
report_tns  

puts "\n=========================================================================="
puts " report_wns"
puts "============================================================================"
report_wns

puts "\n=========================================================================="
puts " report_worst_slack -max (Setup)"
puts "============================================================================"
report_worst_slack -max 

puts "\n=========================================================================="
puts " report_worst_slack -min (Hold)"
puts "============================================================================"
report_worst_slack -min 

puts "\n=========================================================================="
puts " report_clock_skew"
puts "============================================================================"
report_clock_skew


puts "\n=========================================================================="
puts " report_power"
puts "============================================================================"
report_power 

puts "\n=========================================================================="
puts " report_design_area"
puts "============================================================================"
report_design_area
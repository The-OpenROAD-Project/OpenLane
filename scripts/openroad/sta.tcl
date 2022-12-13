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
if { $::env(RUN_STANDALONE) == 1 } {
    source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
    if { $::env(CURRENT_ODB) != "0" } {
        read
    } else {
        read_libs
        read_lef $::env(MERGED_LEF)
        read_netlist
    }

    if { $::env(STA_PRE_CTS) == 1 } {
        unset_propagated_clock [all_clocks]
    } else {
        set_propagated_clock [all_clocks]
    }
}

set_cmd_units -time ns -capacitance pF -current mA -voltage V -resistance kOhm -distance um

if { [info exists ::env(CURRENT_SPEF)] } {
    read_spef $::env(CURRENT_SPEF)
}

puts "min_report"
puts "\n==========================================================================="
puts "report_checks -path_delay min (Hold)"
puts "============================================================================"
report_checks -path_delay min -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 5
puts "min_report_end"

puts "max_report"
puts "\n==========================================================================="
puts "report_checks -path_delay max (Setup)"
puts "============================================================================"
report_checks -path_delay max -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 5
puts "max_report_end"


puts "check_report"
puts "\n==========================================================================="
puts "report_checks -unconstrained"
puts "============================================================================"
report_checks -unconstrained -fields {slew cap input nets fanout} -format full_clock_expanded

puts "\n==========================================================================="
puts "report_checks --slack_max -0.01"
puts "============================================================================"
report_checks -slack_max -0.01 -fields {slew cap input nets fanout} -format full_clock_expanded
puts "check_report_end"

puts "parastic_annotation_check"
puts "\n==========================================================================="
puts "report_parasitic_annotation -report_unannotated"
puts "============================================================================"
report_parasitic_annotation -report_unannotated
puts "parastic_annotation_check"

puts "check_slew"
puts "\n==========================================================================="
puts " report_check_types -max_slew -max_cap -max_fanout -violators"
puts "============================================================================"
report_check_types -max_slew -max_capacitance -max_fanout -violators


puts "\n==========================================================================="
puts "max slew violation count [sta::max_slew_violation_count]"
puts "max fanout violation count [sta::max_fanout_violation_count]"
puts "max cap violation count [sta::max_capacitance_violation_count]"
puts "============================================================================"
puts "check_slew_end"

puts "tns_report"
puts "\n==========================================================================="
puts " report_tns"
puts "============================================================================"
report_tns
puts "tns_report_end"

puts "wns_report"
puts "\n==========================================================================="
puts " report_wns"
puts "============================================================================"
report_wns
puts "wns_report_end"

puts "worst_slack"
puts "\n==========================================================================="
puts " report_worst_slack -max (Setup)"
puts "============================================================================"
report_worst_slack -max

puts "\n==========================================================================="
puts " report_worst_slack -min (Hold)"
puts "============================================================================"
report_worst_slack -min
puts "worst_slack_end"

# report clock skew if the clock port is defined
# OR hangs if this command is run on clockless designs
if { $::env(CLOCK_PORT) != "__VIRTUAL_CLK__" && $::env(CLOCK_PORT) != "" } {
    puts "clock_skew"
    puts "\n==========================================================================="
    puts " report_clock_skew"
    puts "============================================================================"
    report_clock_skew
    puts "clock_skew_end"
}

# This segfaults sometimes.
if { $::env(STA_REPORT_POWER) } {
    puts "power_report"
    puts "\n==========================================================================="
    puts " report_power"
    puts "============================================================================"
    report_power
    puts "power_report_end"
}

puts "area_report"
puts "\n==========================================================================="
puts " report_design_area"
puts "============================================================================"
report_design_area
puts "area_report_end"

write

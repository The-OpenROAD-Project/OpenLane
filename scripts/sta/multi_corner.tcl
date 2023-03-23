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

read_libs -multi_corner
if { [info exists ::env(VERILOG_NETLISTS)] } {
    foreach verilog $::env(VERILOG_NETLISTS) {
        read_verilog $verilog
    }
}
read_netlist -powered

set_cmd_units -time ns -capacitance pF -current mA -voltage V -resistance kOhm -distance um

# Read parasitics if they are generated prior to this point
if { [info exists ::env(CURRENT_SPEF)] } {
    read_spef -corner ss $::env(CURRENT_SPEF)
    read_spef -corner tt $::env(CURRENT_SPEF)
    read_spef -corner ff $::env(CURRENT_SPEF)
}

proc lmap args {
    set body [lindex $args end]
    set args [lrange $args 0 end-1]
    set n 0
    set pairs [list]
    foreach {varnames listval} $args {
        set varlist [list]
        foreach varname $varnames {
            upvar 1 $varname var$n
            lappend varlist var$n
            incr n
        }
        lappend pairs $varlist $listval
    }
    set temp [list]
    foreach {*}$pairs {
        lappend temp [uplevel 1 $body]
    }
    set temp
}

if { [info exists ::env(EXTRA_SPEFS)] } {
    set extra_spefs [lmap {a b c d} $::env(EXTRA_SPEFS) {list $a $b $c $d}]
    foreach i $extra_spefs {
        set module_name [lindex $i 0]
        set spef_file_min [lindex $i 1]
        set spef_file_nom [lindex $i 2]
        set spef_file_max [lindex $i 3]
        set matched 0
        foreach cell [get_cells *] {
            if { "[get_property $cell ref_name]" eq "$module_name" } {
                puts "Matched [get_property $cell name] with $module_name"
                set matched 1
                read_spef -path [get_property $cell name] -corner ss $spef_file_min
                read_spef -path [get_property $cell name] -corner tt $spef_file_nom
                read_spef -path [get_property $cell name] -corner ff $spef_file_max
                break
            }
        }
        if { $matched != 1 } {
            puts "Error: Module $module_name specified in EXTRA_SPEFS not found."
            exit 1
        }
    }
}

if { $::env(STA_PRE_CTS) == 1 } {
    unset_propagated_clock [all_clocks]
} else {
    set_propagated_clock [all_clocks]
}

puts "min_report"
puts "\n==========================================================================="
puts "report_checks -path_delay min (Hold)"
puts "============================================================================"
puts "\n======================= Slowest Corner ===================================\n"
report_checks -path_delay min -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 1000 -corner ss
puts "\n======================= Typical Corner ===================================\n"
report_checks -path_delay min -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 1000 -corner tt
puts "\n======================= Fastest Corner ===================================\n"
report_checks -path_delay min -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 1000 -corner ff
puts "min_report_end"


puts "max_report"
puts "\n==========================================================================="
puts "report_checks -path_delay max (Setup)"
puts "============================================================================"
puts "\n======================= Slowest Corner ===================================\n"
report_checks -path_delay max -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 1000 -corner ss
puts "\n======================= Typical Corner ===================================\n"
report_checks -path_delay max -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 1000 -corner tt
puts "\n======================= Fastest Corner ===================================\n"
report_checks -path_delay max -fields {slew cap input nets fanout} -format full_clock_expanded -group_count 1000 -corner ff
puts "max_report_end"


puts "check_report"
puts "\n==========================================================================="
puts "report_checks -unconstrained"
puts "============================================================================"
puts "\n======================= Slowest Corner ===================================\n"
report_checks -unconstrained -fields {slew cap input nets fanout} -format full_clock_expanded -corner ss
puts "\n======================= Typical Corner ===================================\n"
report_checks -unconstrained -fields {slew cap input nets fanout} -format full_clock_expanded -corner tt
puts "\n======================= Fastest Corner ===================================\n"
report_checks -unconstrained -fields {slew cap input nets fanout} -format full_clock_expanded -corner ff


puts "\n==========================================================================="
puts "report_checks --slack_max -0.01"
puts "============================================================================"
puts "\n======================= Slowest Corner ===================================\n"
report_checks -slack_max -0.01 -fields {slew cap input nets fanout} -format full_clock_expanded -corner ss
puts "\n======================= Typical Corner ===================================\n"
report_checks -slack_max -0.01 -fields {slew cap input nets fanout} -format full_clock_expanded -corner tt
puts "\n======================= Fastest Corner ===================================\n"
report_checks -slack_max -0.01 -fields {slew cap input nets fanout} -format full_clock_expanded -corner ff
puts "check_report_end"

puts "parastic_annotation_check"
puts "\n==========================================================================="
puts "report_parasitic_annotation -report_unannotated"
puts "============================================================================"
report_parasitic_annotation -report_unannotated
puts "parastic_annotation_check_end"

puts "check_slew"
puts "\n==========================================================================="
puts " report_check_types -max_slew -max_cap -max_fanout -violators"
puts "============================================================================"
puts "\n======================= Slowest Corner ===================================\n"
report_check_types -max_slew -max_capacitance -max_fanout -violators -corner ss
puts "\n======================= Typical Corner ===================================\n"
report_check_types -max_slew -max_capacitance -max_fanout -violators -corner tt
puts "\n======================= Fastest Corner ===================================\n"
report_check_types -max_slew -max_capacitance -max_fanout -violators -corner ff

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
    puts "\n======================== Slowest Corner ==================================\n"
    report_clock_skew -corner ss
    puts "\n======================= Typical Corner ===================================\n"
    report_clock_skew -corner tt
    puts "\n======================= Fastest Corner ===================================\n"
    report_clock_skew -corner ff
    puts "clock_skew_end"
}

puts "power_report"
puts "\n==========================================================================="
puts " report_power"
puts "============================================================================"
puts "\n\n======================= Slowest Corner =================================\n"
report_power -corner ss
puts "\n======================= Typical Corner ===================================\n"
report_power -corner tt
puts "\n\n======================= Fastest Corner =================================\n"
report_power -corner ff
puts "power_report_end"


write -no_global_connect

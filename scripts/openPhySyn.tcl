#Psn ; # or ./build/Psn if not installed in the global path
puts "Here"
import_lib $::env(LIB_SYNTH_COMPLETE)
import_lef $::env(MERGED_LEF_UNPADDED)
import_def $::env(CURRENT_DEF)
read_sdc $::env(BASE_SDC_FILE)

set_wire_rc met1;# 1.0e-03 1.0e-03  # or set_wire_rc <metal layer>

puts "=============== Initial Reports ============="
report_checks
report_check_types -max_slew -max_capacitance -violators
puts "Capacitance violations: [llength [capacitance_violations]]"
puts "Transition violations: [llength [transition_violations]]"
report_wns
report_tns

puts "Initial area: [expr round([design_area] * 10E12) ] um2"

puts "OpenPhySyn timing repair:"
repair_timing

puts "=============== Final Reports ============="
report_checks
report_check_types -max_slew -max_capacitance -violators
puts "Capacitance violations: [llength [capacitance_violations]]"
puts "Transition violations: [llength [transition_violations]]"
report_wns
report_tns

puts "Final area: [expr round([design_area] * 10E12) ] um2"

puts "Export optimized design"
export_def $::env(SAVE_DEF)
exit 0
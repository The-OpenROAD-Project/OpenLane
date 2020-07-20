# Copyright (c) Efabless Corporation. All rights reserved.
# See LICENSE file in the project root for full license information.
set_cmd_units -time ns -capacitance pF -current mA -voltage V -resistance kOhm -distance um

read_liberty -min $::env(LIB_MIN)
read_liberty -max $::env(LIB_MAX)
read_verilog $::env(yosys_result_file_tag).v
link_design $::env(DESIGN_NAME)

#set_units -capacitance ff
read_sdc -echo $::env(BASE_SDC_FILE)
#report_checks
report_tns
report_tns > $::env(opensta_report_file_tag)_tns.rpt
report_wns
report_wns > $::env(opensta_report_file_tag)_wns.rpt
# report_power
# report_power > $::env(opensta_report_file_tag)_power.rpt

report_checks -unique -slack_max -0.0 -group_count 100 > $::env(opensta_report_file_tag).timing.rpt
report_checks -path_delay min_max > $::env(opensta_report_file_tag).min_max.rpt
report_checks -group_count 100  -slack_max -0.01 > $::env(opensta_report_file_tag).rpt
exit

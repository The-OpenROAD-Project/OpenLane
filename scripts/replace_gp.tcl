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

replace_external rep

rep set_verbose_level 3
# rep set_plot_enable true
rep set_density $::env(PL_TARGET_DENSITY)

rep import_lef $::env(MERGED_LEF)
rep import_def $::env(CURRENT_DEF)
rep set_output $::env(replaceio_tmp_file_tag)

if { $::env(PL_TIME_DRIVEN) } {
	rep set_timing_driven true
	rep import_lib $::env(PL_LIB)
	rep import_sdc ./scripts/base.sdc
	rep import_verilog $::env(yosys_result_file_tag).v
}

if { $::env(PL_BASIC_PLACEMENT) } {
	rep set_target_overflow 0.9
}

rep set_seed_init_enable true
rep init_replace
rep place_cell_nesterov_place
# rep print_instances

rep export_def $::env(replaceio_tmp_file_tag)_place.def

set hpwl [rep get_hpwl]
exec echo $hpwl >> $::env(replaceio_report_file_tag)_hpwl.rpt

if { $::env(PL_TIME_DRIVEN) } {
	set wns [rep get_wns]
	set tns [rep get_tns]
	puts "\[INFO\]: TNS after placement $tns"
	puts "\[INFO\]: WNS after placement $wns"
	exec echo $wns >> $::env(replaceio_report_file_tag)_wns.rpt
	exec echo $tns >> $::env(replaceio_report_file_tag)_tns.rpt
}

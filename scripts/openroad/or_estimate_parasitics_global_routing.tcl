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

if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

read_liberty -max $::env(LIB_SLOWEST)
read_liberty -min $::env(LIB_FASTEST)
read_sdc -echo $::env(BASE_SDC_FILE)

set_wire_rc -layer $::env(WIRE_RC_LAYER)
estimate_parasitics -global_routing

report_checks -unique -slack_max -0.0 -group_count 100 > $::env(fastroute_report_file_tag).timing.rpt
report_checks -path_delay min_max > $::env(fastroute_report_file_tag).min_max.rpt
report_checks -group_count 100  -slack_max -0.01 > $::env(fastroute_report_file_tag).rpt

report_wns > $::env(fastroute_report_file_tag)_wns.rpt
report_tns > $::env(fastroute_report_file_tag)_tns.rpt
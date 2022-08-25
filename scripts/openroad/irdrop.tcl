# Copyright 2022 Efabless Corporation
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

if {[catch {read_lef $::env(MERGED_LEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

foreach lib $::env(LIB_SYNTH_COMPLETE) {
    read_liberty $lib
}

if { [info exists ::env(EXTRA_LIBS) ] } {
    foreach lib $::env(EXTRA_LIBS) {
        read_liberty $lib
    }
}

source $::env(SCRIPTS_DIR)/openroad/common/set_rc.tcl

analyze_power_grid -net $::env(VDD_NET) -outfile $::env(_tmp_save_rpt)

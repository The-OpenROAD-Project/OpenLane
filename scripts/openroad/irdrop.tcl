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
source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
read
read_spef $::env(CURRENT_SPEF)

source $::env(SCRIPTS_DIR)/openroad/common/set_rc.tcl

if { [info exists ::env(VSRC_LOC_FILES)] } {
    foreach {net vsrc_file} "$::env(VSRC_LOC_FILES)" {
        set arg_list [list]
        lappend arg_list -net $net
        lappend arg_list -outfile $::env(_tmp_save_rpt_prefix)-$net.rpt
        lappend arg_list -vsrc $vsrc_file
        analyze_power_grid {*}$arg_list
    }
} else {
    foreach net "$::env(VDD_NETS) $::env(GND_NETS)" {
        set arg_list [list]
        lappend arg_list -net $net
        lappend arg_list -outfile $::env(_tmp_save_rpt_prefix)-$net.rpt
        analyze_power_grid {*}$arg_list
    }
}



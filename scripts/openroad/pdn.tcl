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
#
source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
read

# load the grid definitions
if {[catch {source $::env(FP_PDN_CFG)} errmsg]} {
    puts stderr $errmsg
    exit 1
}
set arg_list [list]
if { $::env(FP_PDN_SKIPTRIM) } {
    lappend arg_list -skip_trim
    puts "adding -skip_trim to pdngen"
}
# run PDNGEN
if {[catch {pdngen {*}$arg_list} errmsg]} {
    puts stderr $errmsg
    exit 1
}

# https://github.com/The-OpenROAD-Project/OpenROAD/issues/2126
# checks for unconnected nodes (e.g., isolated rails or stripes)
if { $::env(FP_PDN_CHECK_NODES) } {
    check_power_grid -net $::env(VDD_NET)
    check_power_grid -net $::env(GND_NET)
}

write

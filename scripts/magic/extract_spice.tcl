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

if { [info exist ::env(MAGIC_EXT_USE_GDS)] && $::env(MAGIC_EXT_USE_GDS) } {
    gds read $::env(CURRENT_GDS)
} else {
    source $::env(SCRIPTS_DIR)/magic/def/read.tcl
}
load $::env(DESIGN_NAME) -dereference

set extdir $::env(signoff_tmpfiles)/magic_spice_ext
file mkdir $extdir
cd $extdir

extract do local
extract no capacitance
extract no coupling
extract no resistance
extract no adjust
if { ! $::env(LVS_CONNECT_BY_LABEL) } {
    extract unique
}
# extract warn all
extract

ext2spice lvs
ext2spice -o $::env(EXT_NETLIST) $::env(DESIGN_NAME).ext
feedback save $::env(signoff_reports)/$::env(_tmp_magic_extract_type).feedback.txt
# exec cp $::env(DESIGN_NAME).spice $::env(signoff_results)/$::env(DESIGN_NAME).spice
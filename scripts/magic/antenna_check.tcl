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

lef read $::env(TECH_LEF)
if {  [info exist ::env(EXTRA_LEFS)] } {
    set lefs_in $::env(EXTRA_LEFS)
    foreach lef_file $lefs_in {
        lef read $lef_file
    }
}
def read $::env(CURRENT_DEF)
load $::env(DESIGN_NAME) -dereference
cd $::env(signoff_tmpfiles)
select top cell

# for now, do extraction anyway; can be optimized by reading the maglef ext
# but getting many warnings
if { ! [file exists $::env(DESIGN_NAME).ext] } {
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
    feedback save $feedback_file
}
antennacheck debug
antennacheck
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

foreach lib $::env(RCX_LIB) {
    read_liberty $lib
}

if { [info exists ::env(EXTRA_LIBS) ] } {
    foreach lib $::env(EXTRA_LIBS) {
        read_liberty $lib
    }
}

if {[catch {read_lef $::env(RCX_LEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

read_sdc $::env(CURRENT_SDC)
set_propagated_clock [all_clocks]

set rcx_flags ""
if { !$::env(RCX_MERGE_VIA_WIRE_RES) } {
    set rcx_flags "-no_merge_via_res"
}

# RCX
puts "Using RCX ruleset '$::env(RCX_RULESET)'..."
define_process_corner -ext_model_index 0 X
extract_parasitics $rcx_flags\
    -ext_model_file $::env(RCX_RULESET)\
    -lef_res

puts "Writing result to $::env(SAVE_SPEF)..."
write_spef $::env(SAVE_SPEF)

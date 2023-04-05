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
source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
read_lef $::env(RCX_LEF)
read_def $::env(RCX_DEF)
read_libs -typical "$::env(RCX_LIB)"

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
write

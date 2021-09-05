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

foreach lib $::env(LIB_SYNTH_COMPLETE) {
	read_liberty $lib
}

if {[catch {read_lef $::env(MERGED_LEF_UNPADDED)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

if {[catch {read_def -order_wires $::env(CURRENT_DEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

read_sdc $::env(BASE_SDC_FILE)

set_propagated_clock [all_clocks]

set rcx_flags ""
if { !$::env(RCX_MERGE_VIA_WIRE_RES) } {
    set rcx_flags "-no_merge_via_res"
}

# Via resistance
if { [info exist ::env(VIAS_RC)] } {
    set vias_rc [split $::env(VIAS_RC) ","]
    foreach via_rc $vias_rc {
        set layer_name [lindex $via_rc 0]
        set resistance [lindex $via_rc 1]
        set_layer_rc -via $layer_name -resistance $resistance
    }
}

set_wire_rc -signal -layer $::env(DATA_WIRE_RC_LAYER)
set_wire_rc -clock -layer $::env(CLOCK_WIRE_RC_LAYER)

# RCX 
define_process_corner -ext_model_index 0 X
extract_parasitics $rcx_flags -ext_model_file $::env(RCX_RULES)\
    -corner_cnt $::env(RCX_CORNER_COUNT)\
    -max_res $::env(RCX_MAX_RESISTANCE)\
    -coupling_threshold $::env(RCX_COUPLING_THRESHOLD)\
    -cc_model $::env(RCX_CC_MODEL)\
    -context_depth $::env(RCX_CONTEXT_DEPTH)

write_spef [file rootname $::env(CURRENT_DEF)].spef
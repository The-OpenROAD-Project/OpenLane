# Copyright 2020-2021 Efabless Corporation
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

set_global_routing_layer_adjustment * $::env(GLB_RT_ADJUSTMENT)

if { [info exists ::env(GLB_RT_L1_ADJUSTMENT)] } {
    # Legacy format for layer adjustments: Convert to new format
    set flag 0

    set l1_adj 0
    if { [info exists ::env(GLB_RT_L1_ADJUSTMENT)] } {
        set flag 1
        set l1_adj $::env(GLB_RT_L1_ADJUSTMENT)
    }
    set l2_adj 0
    if { [info exists ::env(GLB_RT_L2_ADJUSTMENT)] } {
        set flag 1
        set l2_adj $::env(GLB_RT_L2_ADJUSTMENT)
    }
    set l3_adj 0
    if { [info exists ::env(GLB_RT_L3_ADJUSTMENT)] } {
        set flag 1
        set l3_adj $::env(GLB_RT_L3_ADJUSTMENT)
    }
    set l4_adj 0
    if { [info exists ::env(GLB_RT_L4_ADJUSTMENT)] } {
        set flag 1
        set l4_adj $::env(GLB_RT_L4_ADJUSTMENT)
    }
    set l5_adj 0
    if { [info exists ::env(GLB_RT_L5_ADJUSTMENT)] } {
        set flag 1
        set l5_adj $::env(GLB_RT_L5_ADJUSTMENT)
    }
    set l6_adj 0
    if { [info exists ::env(GLB_RT_L6_ADJUSTMENT)] } {
        set flag 1
        set l6_adj $::env(GLB_RT_L6_ADJUSTMENT)
    }

    set ::env(GLB_RT_LAYER_ADJUSTMENTS) "$l1_adj,$l2_adj,$l3_adj,$l4_adj,$l5_adj,$l6_adj"

    if { $flag } {
        puts stderr "\[DEPRECATION WARNING] A GLB_RT_LX_ADJUSTMENT variable is still used by your design and will be removed in a future version of OpenLane. We recommend you update to GLB_RT_LAYER_ADJUSTMENTS. Check configuration/README.md for more info."

        puts stderr "Recommended replacement:\nset ::env(GLB_RT_LAYER_ADJUSTMENTS) $::env(GLB_RT_LAYER_ADJUSTMENTS)"
    }
}

set array [split $::env(GLB_RT_LAYER_ADJUSTMENTS) ","]
set i 0
foreach adjustment $array {
    set layer_name [lindex $::env(TECH_METAL_LAYERS) $i]
    set_global_routing_layer_adjustment $layer_name $adjustment
    incr i
}
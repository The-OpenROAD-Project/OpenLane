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

set_global_routing_layer_adjustment [lindex $::env(TECH_METAL_LAYERS) 0] $::env(GLB_RT_L1_ADJUSTMENT)
set_global_routing_layer_adjustment [lindex $::env(TECH_METAL_LAYERS) 1] $::env(GLB_RT_L2_ADJUSTMENT)
set_global_routing_layer_adjustment [lindex $::env(TECH_METAL_LAYERS) 2] $::env(GLB_RT_L3_ADJUSTMENT)

if { $::env(GLB_RT_MAXLAYER) > 3 } {
    set_global_routing_layer_adjustment [lindex $::env(TECH_METAL_LAYERS) 3] $::env(GLB_RT_L4_ADJUSTMENT)
    if { $::env(GLB_RT_MAXLAYER) > 4 } {
        set_global_routing_layer_adjustment [lindex $::env(TECH_METAL_LAYERS) 4] $::env(GLB_RT_L5_ADJUSTMENT)
        if { $::env(GLB_RT_MAXLAYER) > 5 } {
            set_global_routing_layer_adjustment [lindex $::env(TECH_METAL_LAYERS) 5] $::env(GLB_RT_L6_ADJUSTMENT)
        }
    }
}
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

# Routing defaults
set ::env(ROUTING_STRATEGY) 0
set ::env(GLB_RT_OLD_FR) 0
set ::env(GLB_RT_ADJUSTMENT) 0
set ::env(GLB_RT_L1_ADJUSTMENT) 0; # more like pdk-specific (e.g., when L1 = li)
set ::env(GLB_RT_L2_ADJUSTMENT) 0
set ::env(GLB_RT_UNIDIRECTIONAL) 1
set ::env(GLB_RT_ALLOW_CONGESTION) 0
set ::env(GLB_RT_OVERFLOW_ITERS) 50
set ::env(GLB_RT_MINLAYER) 1
set ::env(GLB_RT_MAXLAYER) 6
set ::env(GLB_RT_TILES) 15 ; # openroads fastroute default value
set ::env(GLB_RT_SCRIPT) $::env(SCRIPTS_DIR)/fastroute.tcl


set ::env(DIODE_PADDING) 2 ; # sites 

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
set ::env(ROUTING_CORES) 4
set ::env(GLB_RT_ADJUSTMENT) 0
set ::env(GLB_RT_L1_ADJUSTMENT) 0; # more like pdk-specific (e.g., when L1 = li)
set ::env(GLB_RT_L2_ADJUSTMENT) 0
set ::env(GLB_RT_L3_ADJUSTMENT) 0
set ::env(GLB_RT_L4_ADJUSTMENT) 0
set ::env(GLB_RT_L5_ADJUSTMENT) 0
set ::env(GLB_RT_L6_ADJUSTMENT) 0; # We go up to 6 here because the lowest met layer we've dealt with was met5, starting from li1. This might need to be adjusted.
set ::env(GLB_RT_UNIDIRECTIONAL) 1
set ::env(GLB_RT_ALLOW_CONGESTION) 0
set ::env(GLB_RT_OVERFLOW_ITERS) 50
set ::env(GLB_RT_MINLAYER) 1
set ::env(GLB_RT_MAXLAYER) 6
set ::env(GLB_RT_TILES) 15 ; # openroads fastroute default value

set ::env(GLB_RT_ESTIMATE_PARASITICS) 1

set ::env(DIODE_PADDING) 2 ; # sites

# GLB_RT_MAX_DIODE_INS_ITERS is set to 1 because of the bulk testing we're running (as it will speed-up the runtime for big designs).
# However, the user is advised to set it up to 5 or more, in case of running a specific design.
# It is capable to detect any divergence, so, you'll probably end up with the lowest # of Antenna violations possible.
# Check the configuration/README.md for more.
set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 1

set ::env(ROUTING_OPT_ITERS) 64

set ::env(GLOBAL_ROUTER) fastroute
set ::env(DETAILED_ROUTER) tritonroute

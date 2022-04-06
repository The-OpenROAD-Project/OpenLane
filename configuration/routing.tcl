# Copyright 2020-2021 Efabless Corporation
# ECO Flow Copyright 2021 The University of Michigan
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
if { ![info exists ::env(ROUTING_CORES)] } {
    set ::env(ROUTING_CORES) 2
}

set ::env(GLOBAL_ROUTER) fastroute
set ::env(DETAILED_ROUTER) tritonroute

set ::env(GLB_OPTIMIZE_MIRRORING) 1

set ::env(GLB_RT_ADJUSTMENT) 0.3
set ::env(GLB_RT_ALLOW_CONGESTION) 0
set ::env(GLB_RT_OVERFLOW_ITERS) 50
set ::env(GLB_RT_ANT_ITERS) 3
set ::env(GLB_RT_ESTIMATE_PARASITICS) 1
set ::env(GLB_RT_MACRO_EXTENSION) 0

set ::env(DIODE_PADDING) 2

# GLB_RT_MAX_DIODE_INS_ITERS is set to 1 because of the bulk testing we're running (as it will speed-up the runtime for big designs).
# However, the user is advised to set it up to 5 or more, in case of running a specific design.
# It is capable to detect any divergence, so, you'll probably end up with the lowest # of Antenna violations possible.
# Check the configuration/README.md for more.
set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 1

set ::env(DRT_OPT_ITERS) 64

# GLB Resizer
set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) 1
set ::env(GLB_RESIZER_MAX_WIRE_LENGTH) 0
set ::env(GLB_RESIZER_MAX_SLEW_MARGIN) 10
set ::env(GLB_RESIZER_MAX_CAP_MARGIN) 10
set ::env(GLB_RESIZER_HOLD_SLACK_MARGIN) 0.1
set ::env(GLB_RESIZER_SETUP_SLACK_MARGIN) 0.05
set ::env(GLB_RESIZER_HOLD_MAX_BUFFER_PERCENT) 50
set ::env(GLB_RESIZER_SETUP_MAX_BUFFER_PERCENT) 50
set ::env(GLB_RESIZER_ALLOW_SETUP_VIOS) 0
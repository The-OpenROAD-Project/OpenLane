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

# Routing defaults
if { ![info exists ::env(ROUTING_CORES)] } {
    set ::env(ROUTING_CORES) 2
}

set ::env(RUN_HEURISTIC_DIODE_INSERTION) 0
set ::env(HEURISTIC_ANTENNA_THRESHOLD) 90

# Private: Strategy for placement of the diodes. Possible values `source`, `pin`, `balanced` and `random`. Only applicable when `RUN_HEURISTIC_DIODE_INSERTION` is enabled.
set ::env(HEURISTIC_ANTENNA_INSERTION_MODE) "source"

set ::env(DIODE_PADDING) 2
set ::env(DIODE_ON_PORTS) none
set ::env(GRT_REPAIR_ANTENNAS) 1

set ::env(GLOBAL_ROUTER) fastroute
set ::env(DETAILED_ROUTER) tritonroute


set ::env(GRT_ADJUSTMENT) 0.3
set ::env(GRT_ALLOW_CONGESTION) 0
set ::env(GRT_OVERFLOW_ITERS) 50
set ::env(GRT_ANT_ITERS) 15
set ::env(GRT_ANT_MARGIN) 10
set ::env(GRT_ESTIMATE_PARASITICS) 1
set ::env(GRT_MACRO_EXTENSION) 0

# Increasing this value is very recommended for larger designs.
set ::env(GRT_MAX_DIODE_INS_ITERS) 1

# Maximum number of DRT Optimization iterations. Any number above 64 is ignored.
set ::env(DRT_OPT_ITERS) 64

# GLB Resizer
set ::env(GLB_OPTIMIZE_MIRRORING) 1
set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) 1
set ::env(GLB_RESIZER_DESIGN_OPTIMIZATIONS) 1
set ::env(GLB_RESIZER_MAX_WIRE_LENGTH) 0
set ::env(GLB_RESIZER_MAX_SLEW_MARGIN) 10
set ::env(GLB_RESIZER_MAX_CAP_MARGIN) 10
set ::env(GLB_RESIZER_HOLD_SLACK_MARGIN) 0.05
set ::env(GLB_RESIZER_SETUP_SLACK_MARGIN) 0.025
set ::env(GLB_RESIZER_HOLD_MAX_BUFFER_PERCENT) 50
set ::env(GLB_RESIZER_SETUP_MAX_BUFFER_PERCENT) 50
set ::env(GLB_RESIZER_ALLOW_SETUP_VIOS) 0

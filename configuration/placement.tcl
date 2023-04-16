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

# Placement defaults
set ::env(PL_ROUTABILITY_DRIVEN) 1
set ::env(PL_TIME_DRIVEN) 1
set ::env(PL_RANDOM_GLB_PLACEMENT) 0
set ::env(PL_BASIC_PLACEMENT) 0
set ::env(PL_SKIP_INITIAL_PLACEMENT) 0
set ::env(PL_RANDOM_INITIAL_PLACEMENT) 0
set ::env(PL_ESTIMATE_PARASITICS) 1
set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 1
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 1
set ::env(PL_RESIZER_MAX_WIRE_LENGTH) 0
set ::env(PL_OPTIMIZE_MIRRORING) 1
set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 1
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 1
set ::env(PL_RESIZER_MAX_SLEW_MARGIN) 20
set ::env(PL_RESIZER_MAX_CAP_MARGIN) 20
set ::env(PL_RESIZER_HOLD_SLACK_MARGIN) 0.1
set ::env(PL_RESIZER_TIE_SEPERATION) 0
set ::env(PL_RESIZER_SETUP_SLACK_MARGIN) 0.05
set ::env(PL_RESIZER_HOLD_MAX_BUFFER_PERCENT) 50
set ::env(PL_RESIZER_SETUP_MAX_BUFFER_PERCENT) 50
set ::env(PL_RESIZER_ALLOW_SETUP_VIOS) 0
set ::env(PL_RESIZER_REPAIR_TIE_FANOUT) 1
set ::env(PL_MAX_DISPLACEMENT_X) 500
set ::env(PL_MAX_DISPLACEMENT_Y) 100
set ::env(PL_MACRO_HALO) {0 0}
set ::env(PL_MACRO_CHANNEL) {0 0}
set ::env(PL_WIRELENGTH_COEF) 0.25
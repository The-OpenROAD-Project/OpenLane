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

set ::env(WIRE_RC_LAYER) "met1"; # Used for estimate_parasitics

# Options are rcx/def2spef
set ::env(SPEF_EXTRACTOR) "openrcx"

# OpenRCX default condigurations
set ::env(RCX_CORNER_COUNT) 1
set ::env(RCX_MAX_RESISTANCE) 50
set ::env(RCX_COUPLING_THRESHOLD) 0.1
set ::env(RCX_CC_MODEL) 10
set ::env(RCX_CONTEXT_DEPTH) 5
set ::env(RCX_MERGE_VIA_WIRE_RES) 1
set ::env(DATA_WIRE_RC_LAYER) "met2"
set ::env(CLOCK_WIRE_RC_LAYER) "met5"

# DEF2SPEF default configurations
set ::env(SPEF_WIRE_MODEL) "L"
set ::env(SPEF_EDGE_CAP_FACTOR) 1



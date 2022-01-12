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

if {[catch {read_lef $::env(MERGED_LEF_UNPADDED)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

set_thread_count $::env(ROUTING_CORES)

set min_layer $::env(RT_MIN_LAYER)
if { [info exists ::env(DRT_MIN_LAYER)] } {
    set min_layer $::env(DRT_MIN_LAYER)
}

set max_layer $::env(RT_MAX_LAYER)
if { [info exists ::env(DRT_MAX_LAYER)] } {
    set max_layer $::env(DRT_MAX_LAYER)
}

detailed_route\
    -guide $::env(CURRENT_GUIDE)\
    -bottom_routing_layer $min_layer\
    -top_routing_layer $max_layer\
    -output_guide $::env(TRITONROUTE_FILE_PREFIX).guide\
    -output_maze $::env(TRITONROUTE_FILE_PREFIX)_maze.log\
    -output_drc $::env(TRITONROUTE_RPT_PREFIX).drc\
    -droute_end_iter $::env(DRT_OPT_ITERS)\
    -or_seed 42\
    -verbose 1

puts stderr "Saving to $::env(SAVE_DEF)"
write_def $::env(SAVE_DEF)
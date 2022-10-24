# Copyright 2020-2022 Efabless Corporation
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
source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
read

set_thread_count $::env(ROUTING_CORES)

set min_layer $::env(RT_MIN_LAYER)
if { [info exists ::env(DRT_MIN_LAYER)] } {
    set min_layer $::env(DRT_MIN_LAYER)
}

set max_layer $::env(RT_MAX_LAYER)
if { [info exists ::env(DRT_MAX_LAYER)] } {
    set max_layer $::env(DRT_MAX_LAYER)
}

read_guides $::env(CURRENT_GUIDE)

detailed_route\
    -bottom_routing_layer $min_layer\
    -top_routing_layer $max_layer\
    -output_maze $::env(_tmp_drt_file_prefix)_maze.log\
    -output_drc $::env(_tmp_drt_rpt_prefix).drc\
    -droute_end_iter $::env(DRT_OPT_ITERS)\
    -or_seed 42\
    -verbose 1

write
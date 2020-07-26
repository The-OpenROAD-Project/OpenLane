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

fr_import_lef "${MERGED_LEF_UNPADDED}"
fr_import_def "${CURRENT_DEF}" 
set_output_file "${fastroute_tmp_file_tag}.guide"
set_capacity_adjustment ${GLB_RT_ADJUSTMENT}
set_min_layer ${GLB_RT_MINLAYER}
set_max_layer ${GLB_RT_MAXLAYER}
set_layer_adjustment 1 ${GLB_RT_L1_ADJUSTMENT}
set_layer_adjustment 2 ${GLB_RT_L2_ADJUSTMENT}
set_unidirectional_routing true
set_pitches_in_tile ${GLB_RT_TILES}


start_fastroute
run_fastroute
write_guides

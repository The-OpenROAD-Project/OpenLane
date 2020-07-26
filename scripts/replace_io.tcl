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

replace_external rep

rep set_verbose_level 3
# rep set_plot_enable true
rep set_density $::env(PL_TARGET_DENSITY)

rep import_lef $::env(MERGED_LEF)
rep import_def $::env(tapcell_result_file_tag).def
rep set_output $::env(replaceio_tmp_file_tag)

# rep set_timing_driven true
# rep import_lib $::env(LIB_FILE)
# rep import_sdc $::env(RESULTS_DIR)/synthesis/1_synth.sdc
# rep import_verilog $::env(RESULTS_DIR)/synthesis/1_synthesis.v

rep set_fast_mode_enable true
rep init_replace
rep place_cell_nesterov_place
# rep print_instances

rep export_def $::env(replaceio_tmp_file_tag)_io.def

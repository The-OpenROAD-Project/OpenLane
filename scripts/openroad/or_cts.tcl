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

if {[catch {read_lef $::env(MERGED_LEF_UNPADDED)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

read_lib $::env(LIB_SYNTH_COMPLETE)

if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

read_verilog $::env(yosys_result_file_tag).v
read_sdc $::env(SCRIPTS_DIR)/base.sdc

clock_tree_synthesis\
    -max_slew $::env(SYNTH_MAX_TRAN)\
    -max_cap $::env(CTS_MAX_CAP)\
    -buf_list $::env(CTS_CLK_BUFFER_LIST)\
    -sqr_cap $::env(CTS_SQR_CAP)\
    -sqr_res $::env(CTS_SQR_RES)\
    -root_buf $::env(CTS_ROOT_BUFFER)

write_def $::env(SAVE_DEF)
write_verilog $::env(yosys_result_file_tag)_cts.v

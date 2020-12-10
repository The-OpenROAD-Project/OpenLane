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

foreach lib $::env(LIB_SYNTH) {
    read_liberty $lib
}

if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}  

set glb_cfg_file [open $::env(TMP_DIR)/glb.cfg w]
    puts $glb_cfg_file \
"set ::HALO_WIDTH_V 0
set ::HALO_WIDTH_H 0
set ::CHANNEL_WIDTH_V 0
set ::CHANNEL_WIDTH_H 0"
close $glb_cfg_file

macro_placement -global_config $::env(TMP_DIR)/glb.cfg

write_def $::env(SAVE_DEF)

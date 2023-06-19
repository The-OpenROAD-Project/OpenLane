# Copyright 2020-2023 Efabless Corporation
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
drc off
if { $::env(MAGIC_LEF_WRITE_USE_GDS) } {
    gds read $::env(CURRENT_GDS)
} else {
    source $::env(SCRIPTS_DIR)/magic/def/read.tcl
}

lef nocheck $::env(VDD_NETS) $::env(GND_NETS)

# Write LEF
if { $::env(MAGIC_WRITE_FULL_LEF) } {
    puts "\[INFO\]: Writing non-abstract (full) LEF"
    lef write $::env(signoff_results)/$::env(DESIGN_NAME).lef
} else {
    puts "\[INFO\]: Writing abstract LEF"
    lef write $::env(signoff_results)/$::env(DESIGN_NAME).lef -hide
}
puts "\[INFO\]: LEF Write Complete"

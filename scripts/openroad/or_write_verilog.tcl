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

if {[catch {read_def $::env(INPUT_DEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

if { [info exists ::env(LEC_ENABLE)] && $::env(LEC_ENABLE) } {
    write_verilog $::env(SAVE_NETLIST).without_power_pins.v
}

write_verilog -include_pwr_gnd $::env(SAVE_NETLIST)

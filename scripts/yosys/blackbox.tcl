# Copyright 2023 Efabless Corporation
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

yosys -import
foreach input $::env(YOSYS_IN) {
    if { [info exists ::env(YOSYS_DEFINES)] } {
        read_verilog -lib -D$::env(YOSYS_DEFINES) $input
    } else {
        read_verilog -lib $input
    }
}
blackbox *
write_verilog -noattr -noexpr -nohex -nodec -defparam -blackboxes $::env(YOSYS_OUT)

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
source $::env(SCRIPTS_DIR)/openroad/common/io.tcl

read_libs -typical $::env(LIB_TYPICAL)
read_netlist

if { [get_ports $::env(CLOCK_PORT)] == "" } {
    puts "\[ERROR]: CLOCK_PORT: '$::env(CLOCK_PORT)' not part of the design"
    exit 1
} else {
    puts "\[INFO]: CLOCK_PORT: '$::env(CLOCK_PORT)' found"
}

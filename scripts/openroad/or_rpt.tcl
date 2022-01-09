# Copyright 2021 The University of Michigan
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
# This script generates reports for parsing purposes
# Only serves as a placeholder

if {[catch {read_lef $::env(MERGED_LEF_UNPADDED)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

if { $::env(CURRENT_DEF) != 0 } {
    if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
        puts stderr $errmsg
        exit 1
    }
}

set_cmd_units -time ns -capacitance pF -current mA -voltage V -resistance kOhm -distance um

define_corners tt
read_liberty -corner tt $::env(LIB_SYNTH_COMPLETE)

# Read Verilog and link design
read_verilog $::env(CURRENT_NETLIST)
link_design $::env(DESIGN_NAME)

# Read SPEF and SDC
if { [info exists ::env(SPEF_TYPICAL)] } {
    read_spef -corner tt $::env(SPEF_TYPICAL)
}

read_sdc -echo $::env(CURRENT_SDC)

report_checks -path_delay max

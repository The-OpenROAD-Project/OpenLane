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

foreach lib $::env(LIB_SYNTH_COMPLETE) {
	read_liberty $lib
}

if {[catch {read_lef $::env(MERGED_LEF_UNPADDED)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

if {[catch {pdngen $::env(PDN_CFG) -verbose} errmsg]} {
    puts stderr $errmsg
    exit 1
}

# checks for unconnected nodes (e.g., isolated rails or stripes)
if { $::env(FP_PDN_CHECK_NODES) } {
    check_power_grid -net $::env(VDD_NET)
    check_power_grid -net $::env(GND_NET)
}

if { $::env(FP_PDN_IRDROP) } {
    if { ! [ info exists ::env(FP_PDN_RCFILE) ] } {
        puts stderr "To calculate the IR Drop, you should add an RC file to your config.tcl."
        puts stderr "set ::env(FP_PDN_RCFILE) /path/to/rcfile"
        exit 1
    }
    if {[catch {source $::env(FP_PDN_RCFILE)} errmsg]} {
        puts stderr "Invalid PDN RC file $::env(FP_PDN_RCFILE)."
        puts stderr $errmsg
        exit 1
    }
    
    analyze_power_grid -net $::env(VDD_NET)
}

write_def $::env(SAVE_DEF)

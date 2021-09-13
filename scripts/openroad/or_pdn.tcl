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
    if { [info exist ::env(VIAS_RC)] } {
        set vias_rc [split $::env(VIAS_RC) ","]
        foreach via_rc $vias_rc {
            set layer_name [lindex $via_rc 0]
            set resistance [lindex $via_rc 1]
            set_layer_rc -via $layer_name -resistance $resistance
        }
    }

    if { [info exist ::env(LAYERS_RC)] } {
        set layers_rc [split $::env(LAYERS_RC) ","]
        foreach layer_rc $layers_rc {
            set layer_name [lindex $layer_rc 0]
            set capacitance [lindex $layer_rc 1]
            set resistance [lindex $layer_rc 2]
            set_layer_rc -layer $layer_name -capacitance $capacitance -resistance $resistance
        }
    }

    set_wire_rc -layer $::env(WIRE_RC_LAYER)
    set_wire_rc -signal -layer $::env(DATA_WIRE_RC_LAYER)
    set_wire_rc -clock -layer $::env(CLOCK_WIRE_RC_LAYER)

    analyze_power_grid -net $::env(VDD_NET)
}

write_def $::env(SAVE_DEF)

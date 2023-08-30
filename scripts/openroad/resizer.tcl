# Copyright 2020-2022 Efabless Corporation
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
set read_args [list]
if { $::env(RSZ_MULTICORNER_LIB) } {
    lappend read_args -lib_fastest $::env(RSZ_LIB_FASTEST)
    lappend read_args -lib_slowest $::env(RSZ_LIB_SLOWEST)
}
lappend read_args -lib_typical $::env(RSZ_LIB)
read {*}$read_args

# set rc values
source $::env(SCRIPTS_DIR)/openroad/common/set_rc.tcl

# estimate wire rc parasitics
estimate_parasitics -placement

# set don't touch nets
source $::env(SCRIPTS_DIR)/openroad/common/resizer.tcl
set_dont_touch_wrapper

# set don't use cells
if { [info exists ::env(DONT_USE_CELLS)] } {
    set_dont_use $::env(DONT_USE_CELLS)
}

if { [info exists ::env(PL_RESIZER_BUFFER_INPUT_PORTS)] && $::env(PL_RESIZER_BUFFER_INPUT_PORTS) } {
    buffer_ports -inputs
}

if { [info exists ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS)] && $::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) } {
    buffer_ports -outputs
}
# Resize
if { [info exists ::env(PL_RESIZER_MAX_WIRE_LENGTH)] && $::env(PL_RESIZER_MAX_WIRE_LENGTH) } {
    repair_design -max_wire_length $::env(PL_RESIZER_MAX_WIRE_LENGTH) \
        -slew_margin $::env(PL_RESIZER_MAX_SLEW_MARGIN) \
        -cap_margin $::env(PL_RESIZER_MAX_CAP_MARGIN)
} else {
    repair_design -slew_margin $::env(PL_RESIZER_MAX_SLEW_MARGIN) \
        -cap_margin $::env(PL_RESIZER_MAX_CAP_MARGIN)
}

if { $::env(PL_RESIZER_REPAIR_TIE_FANOUT) == 1} {
    # repair tie lo fanout
    repair_tie_fanout -separation $::env(PL_RESIZER_TIE_SEPERATION) [lindex $::env(SYNTH_TIELO_PORT) 0]/[lindex $::env(SYNTH_TIELO_PORT) 1]
    # repair tie hi fanout
    repair_tie_fanout -separation $::env(PL_RESIZER_TIE_SEPERATION) [lindex $::env(SYNTH_TIEHI_PORT) 0]/[lindex $::env(SYNTH_TIEHI_PORT) 1]
}

report_floating_nets -verbose

source $::env(SCRIPTS_DIR)/openroad/common/dpl_cell_pad.tcl

detailed_placement

if { [info exists ::env(PL_OPTIMIZE_MIRRORING)] && $::env(PL_OPTIMIZE_MIRRORING) } {
    optimize_mirroring
}

if { [catch {check_placement -verbose} errmsg] } {
    puts stderr $errmsg
    exit 1
}

unset_dont_touch_wrapper

write

# Run post design optimizations STA
estimate_parasitics -placement

puts "area_report"
puts "\n==========================================================================="
puts "report_design_area"
puts "============================================================================"
report_design_area
puts "area_report_end"

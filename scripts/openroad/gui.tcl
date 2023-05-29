# Copyright 2022 Efabless Corporation
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
read -no_spefs

proc are_insts_placed {} {
    set odb_block [[[::ord::get_db] getChip] getBlock]
    set odb_nets [odb::dbBlock_getNets $odb_block]
    set odb_instances [odb::dbBlock_getInsts $odb_block]
    foreach instance $odb_instances {
        if { ![odb::dbInst_isPlaced $instance] } {
            return 0
        }
    }
    return 1
}

if { [info exists ::env(GUI_PARASITICS)] } {
    if { [are_insts_placed] } { ;# grt::have_routes causes an error with results from floorplan so check if cells are placed
        if { [grt::have_routes] } {
            if { [info exists ::env(CURRENT_SPEF)] } {
                puts "Reading spefs ..."
                read_spefs
            } else {
                puts "Estimating global parastics ..."
                source $::env(SCRIPTS_DIR)/openroad/common/set_rc.tcl
                estimate_parasitics -global_routing
            }
        } else {
                puts "Estimating placement parastics ..."
                source $::env(SCRIPTS_DIR)/openroad/common/set_rc.tcl
                estimate_parasitics -placement
        }
    }
}

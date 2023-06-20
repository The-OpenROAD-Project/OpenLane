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

# Power nets
proc set_global_connections {} {
    if { [info exists ::env(FP_PDN_ENABLE_GLOBAL_CONNECTIONS) ] } {
        if { $::env(FP_PDN_ENABLE_GLOBAL_CONNECTIONS) == 1 } {
            foreach power_pin $::env(STD_CELL_POWER_PINS) {
                add_global_connection \
                    -net $::env(VDD_NET) \
                    -inst_pattern .* \
                    -pin_pattern $power_pin \
                    -power
            }
            foreach ground_pin $::env(STD_CELL_GROUND_PINS) {
                add_global_connection \
                    -net $::env(GND_NET) \
                    -inst_pattern .* \
                    -pin_pattern $ground_pin \
                    -ground
            }
        }
    }

    if { $::env(FP_PDN_ENABLE_MACROS_GRID) == 1 &&
        [info exists ::env(FP_PDN_MACRO_HOOKS)]} {
        set pdn_hooks [split $::env(FP_PDN_MACRO_HOOKS) ","]
        foreach pdn_hook $pdn_hooks {
            set instance_name [lindex $pdn_hook 0]
            set power_net [lindex $pdn_hook 1]
            set ground_net [lindex $pdn_hook 2]
            set power_pin [lindex $pdn_hook 3]
            set ground_pin [lindex $pdn_hook 4]

            if { $power_pin == "" || $ground_pin == "" } {
                puts "FP_PDN_MACRO_HOOKS missing power and ground pin names"
                exit 1
            }

            set matched 0
            foreach cell [[ord::get_db_block] getInsts] {
                if { [regexp "\^$instance_name" [$cell getName]] } {
                    set matched 1
                }
            }
            if { $matched != 1 } {
                puts "No regex match found for $instance_name defined in FP_PDN_MACRO_HOOKS"
                exit 1
            }

            add_global_connection \
                -net $power_net \
                -inst_pattern $instance_name \
                -pin_pattern $power_pin \
                -power

            add_global_connection \
                -net $ground_net \
                -inst_pattern $instance_name \
                -pin_pattern $ground_pin \
                -ground
        }
    }
}

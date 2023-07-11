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
proc set_dont_touch_wrapper {} {
    if { [info exists ::env(RSZ_DONT_TOUCH_RX)] && $::env(RSZ_DONT_TOUCH_RX) != {^$} } {

        set pattern $::env(RSZ_DONT_TOUCH_RX)
        variable odb_block [[[::ord::get_db] getChip] getBlock]
        set odb_nets [odb::dbBlock_getNets $::odb_block]
        set odb_instances [odb::dbBlock_getInsts $odb_block]
        foreach net $odb_nets {
            set net_name [odb::dbNet_getName $net]
            if { [regexp "$pattern" $net_name full] } {
                puts "\[INFO\] Net '$net_name' matched don't touch regular expression, setting as don't touch..."
                set_dont_touch "$net_name"
            }
        }
        foreach instance $odb_instances {
            set instance_name [odb::dbInst_getName $instance]
            if { [regexp "$pattern" $instance_name full] } {
                puts "\[INFO\] Instance '$instance_name' matched don't touch regular expression, setting as don't touch..."
                set_dont_touch "$instance_name"
            }
        }
    }

    if { [info exists ::env(RSZ_DONT_TOUCH)] } {
        set_dont_touch $::env(RSZ_DONT_TOUCH)
    }
}

proc unset_dont_touch_wrapper {} {
    if { [info exists ::env(RSZ_DONT_TOUCH_RX)] && $::env(RSZ_DONT_TOUCH_RX) != {^$} } {
        set pattern $::env(RSZ_DONT_TOUCH_RX)
        variable odb_block [[[::ord::get_db] getChip] getBlock]
        set odb_nets [odb::dbBlock_getNets $::odb_block]
        set odb_instances [odb::dbBlock_getInsts $odb_block]
        foreach net $odb_nets {
            set net_name [odb::dbNet_getName $net]
            if { [regexp "$pattern" $net_name full] } {
                unset_dont_touch "$net_name"
            }
        }
        foreach instance $odb_instances {
            set instance_name [odb::dbInst_getName $instance]
            if { [regexp "$pattern" $instance_name full] } {
                unset_dont_touch "$instance_name"
            }
        }
    }

    if { [info exists ::env(RSZ_DONT_TOUCH)] } {
        unset_dont_touch $::env(RSZ_DONT_TOUCH)
    }
}

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
proc set_dont_touch_rx {net_pattern} {
    if { $::env(RSZ_USE_OLD_REMOVER) == 1} {
        return
    }
    if { $net_pattern == {^$} } {
        # Save some compute
        return
    }
    variable odb_block [[[::ord::get_db] getChip] getBlock]
    set odb_nets [odb::dbBlock_getNets $::odb_block]
    foreach net $odb_nets {
        set net_name [odb::dbNet_getName $net]
        if { [regexp "$net_pattern" $net_name full] } {
            puts "\[INFO\] Net '$net_name' matched don't touch regular expression, setting as don't touch..."
            set_dont_touch "$net_name"
        }
    }
}

proc unset_dont_touch_rx {net_pattern} {
    if { $::env(RSZ_USE_OLD_REMOVER) == 1} {
        return
    }
    if { $net_pattern == {^$} } {
        # Save some compute
        return
    }
    variable odb_block [[[::ord::get_db] getChip] getBlock]
    set odb_nets [odb::dbBlock_getNets $::odb_block]
    foreach net $odb_nets {
        set net_name [odb::dbNet_getName $net]
        if { [regexp "$net_pattern" $net_name full] } {
            unset_dont_touch "$net_name"
        }
    }
}
# Copyright 2021 The University of Michigan
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

source $::env(SCRIPTS_DIR)/openroad/insert_buffer.tcl

proc size_cell {inst_name new_master_name} {
    set db [ord::get_db]
    set new_master [$db findMaster $new_master_name]

    set block [ord::get_db_block]
    set inst [$block findInst $inst_name]
    $inst swapMaster $new_master
}

proc run_eco {args} {
    source $::env(ECO_FIX_FILE)

    # Run detailed placement
    detailed_placement

    # Destroy faulty connections
    set block [ord::get_db_block]
    set nets [$block getNets]

    foreach net $nets {
        set wire [$net getWire]
        if {$wire != "NULL"} {
            [odb::dbWire_destroy $wire]
        }
    }
}

source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
read -override_libs "$::env(LIB_CTS)"

set_propagated_clock [all_clocks]

run_eco

write
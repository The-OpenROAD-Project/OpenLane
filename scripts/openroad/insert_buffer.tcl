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

proc insert_buffer {pin_name pin_type master_name net_name inst_name} {
    set db [ord::get_db]
    set block [ord::get_db_block]

    # Create buffer instance
    set master [$db findMaster $master_name]
    if { $master == "NULL" } {
        puts "Buffer cell '$master' not found."
        exit -1
    }

    set inst [odb::dbInst_create $block $master $inst_name]

    # Figure out the inputs & outputs of the master
    foreach mterm [$master getMTerms] {
        if {[$mterm getSigType] == "POWER"} {
            continue
        }
        if {[$mterm getSigType] == "GROUND"} {
            continue
        }
        if {[$mterm getIoType] == "INPUT"} {
            set input $mterm
        }
        if {[$mterm getIoType] == "OUTPUT"} {
            set output $mterm
        }
    }

    # New net to connect to
    set new_net [odb::dbNet_create $block $net_name]

    if {$pin_type=="ITerm"} {
        # Finding the block with pin name
        set iterm [$block findITerm $pin_name]
        if { $iterm == "NULL" } {
            puts "Instance terminal '$pin_name' not found."
            exit -1
        }
        set old_net [$iterm getNet]

        # Original disconnect command
        odb::dbITerm_disconnect $iterm

        # Original connect command
        odb::dbITerm_connect $iterm $new_net

        # Set I/O of iterm (Buffer)
        set in_iterm [$inst getITerm $input]
        set out_iterm [$inst getITerm $output]

        if { ![info exists ::env(INSERT_BUFFER_NO_PLACE)] } {
            # define the instance to which the buffer inserted will connected to
            set master_inst [$iterm getInst]
            # get the geometry of the instance, geometry means its shape, the coordinate of its vertex...
            set box [$master_inst getBBox]

            # get the position of the lower left point of this instance
            set x_min [$box xMin]
            set y_min [$box yMin]

            # $inst is the buffer we want to insert, now insert it in the position of the instance it is connected to,
            # using setLocation, and detail_place will help us separate them
            $inst setLocation $x_min $y_min
            $inst setPlacementStatus PLACED
        }

        odb::dbITerm_connect $in_iterm $new_net
        odb::dbITerm_connect $out_iterm $old_net

    } else {
        # Finding the block with pin name
        set bterm [$block findBTerm $pin_name]
        set old_net [$bterm getNet]
        set  net_out_iterm [odb::dbNet_get1stITerm $old_net]
        set old_net_inst [$net_out_iterm getInst]
        set net_mterm [$net_out_iterm getMTerm]
        set old_net_input $net_mterm
        odb::dbITerm_disconnect $net_out_iterm

        if { ![info exists ::env(INSERT_BUFFER_NO_PLACE)] } {
            set box [$bterm getBBox]

            # get the position of the lower left point of this instance
            set x_min [$box xMin]
            set y_min [$box yMin]

            # $inst is the buffer we want to insert, now insert it in the position of the instance it is connected to,
            # using setLocation, and detail_place will help us separate them
            $inst setLocation $x_min $y_min
            $inst setPlacementStatus PLACED
        }

        # Find output/input of buffer iterm
        set in_iterm [$inst getITerm $input]
        set out_iterm [$inst getITerm $output]

        odb::dbITerm_connect $out_iterm $new_net
        odb::dbITerm_connect $net_out_iterm $new_net
        odb::dbITerm_connect $in_iterm $old_net
    }
}

if { [info exists ::env(INSERT_BUFFER_COMMAND) ]} {
    source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
    read

    set arg_list [split $::env(INSERT_BUFFER_COMMAND) " "]
    insert_buffer {*}$arg_list

    write
}

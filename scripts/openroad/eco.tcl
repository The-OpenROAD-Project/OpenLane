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

proc pause {{message "Press enter to continue ==> "}} {
    puts -nonewline $message
    flush stdout
    gets stdin
}

proc insert_buffer {pin_name pin_type master_name net_name inst_name} {
  puts "Successfully set db"
  set db [ord::get_db]
  set new_master [$db findMaster $master_name]
  puts "Set DB: "
  puts $db
  puts "NEW MASTER: "
  puts $new_master
  set block [ord::get_db_block]
  puts "GOT BLOCK FROM DB: "
  puts $block

  # Create buffer instance
  puts "Successfully create new instance"
  set inst [odb::dbInst_create $block $new_master $inst_name]
  puts "create new master"

  # Figure out the inputs & outputs of the master
  foreach mterm [$new_master getMTerms] {
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
      puts "Start Inserting buffer for reg-* cases"
      
      # Finding the block with pin name
      set iterm [$block findITerm $pin_name]
      set old_net [$iterm getNet]

      # Original disconnert command
      odb::dbITerm_disconnect $iterm

      # Original connect command
      odb::dbITerm_connect $iterm $new_net

      # Set I/O of iterm (Buffer)
      set in_iterm [$inst getITerm $input]
      set out_iterm [$inst getITerm $output]
      
      # define the instance to which the buffer inserted will connected to
      set master_inst [$iterm getInst]
      # get the geometry of the instance, geometry means its shape, the coordinate of its vertex...
      set box [$master_inst getBBox]
      
      # get the position of the lower left point of this instance
      set x_min [$box xMin]
      set y_min [$box yMin]
      

      # $inst is the buffer we want to insert, now insert it in the position of the instance it is connected to, 
      # using setLocation, and detail_place will help us separate them
      [$inst setLocation $x_min $y_min]
      [$inst setPlacementStatus PLACED]
      
      # done inserting the buffer
      puts "done insert buffer"
      
      odb::dbITerm_connect $in_iterm $old_net
      puts "connect to in_iterm"
      
      odb::dbITerm_connect $out_iterm $new_net  
      puts "connect to out_iterm "

      puts "Done Inserting buffer for reg-* cases"
  } else {
      puts "Start Inserting buffer for pin-* cases"
      # Finding the block with pin name
      set bterm [$block findBTerm $pin_name]
      set old_net [$bterm getNet]
      puts [odb::dbNet_get1stITerm $old_net]
      set  net_out_iterm [odb::dbNet_get1stITerm $old_net]  
      set old_net_inst [$net_out_iterm getInst]
      set net_mterm [$net_out_iterm getMTerm]
      puts [$net_mterm getSigType]
      set old_net_input $net_mterm
      odb::dbITerm_disconnect $net_out_iterm     

      set box [$bterm getBBox] 

      # get the position of the lower left point of this instance
      set x_min [$box xMin] 
      set y_min [$box yMin]

      # $inst is the buffer we want to insert, now insert it in the position of the instance it is connected to, 
      # using setLocation, and detail_place will help us separate them
      [$inst setLocation $x_min $y_min]
      [$inst setPlacementStatus PLACED]

      # Find output/input of buffer iterm
      set in_iterm [$inst getITerm $input]
      puts "get in iterm"
      set out_iterm [$inst getITerm $output]
      puts "get out iterm"
      
      odb::dbITerm_connect $out_iterm $new_net
      odb::dbITerm_connect $net_out_iterm $new_net
      odb::dbITerm_connect $in_iterm $old_net

      puts "Done Inserting buffer for pin-* cases"
  }
}


proc size_cell {inst_name new_master_name} {
  set db [ord::get_db]
  set new_master [$db findMaster $new_master_name]

  set block [ord::get_db_block]
  set inst [$block findInst $inst_name]
  $inst swapMaster $new_master
}

proc run_eco {args} {
	# Source fixes
    puts "Sourcing fixes !!!"
    
    set cur_iter [expr $::env(ECO_ITER) == 0 ? \
                       0 : \
                       [expr {$::env(ECO_ITER) -1}] \
                 ]
    # Uncomment to source the generated fix
    # Currently args in the fix tcl has some bugs:
    # 1st argument of insert_buffer (pin_name) not found
    source "$::env(eco_results)/fix/eco_fix_$cur_iter.tcl"
    
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

run_eco

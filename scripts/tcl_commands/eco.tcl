
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

  # set iterm [$block findITerm $pin_name]
  # pin_type is the command "findxTerm"
  set find_command "find$pin_type"
  set connect "_connect"
  set connect_command "odb::db$pin_type$connect"
  set disconnect "_disconnect"
  set disconnect_command "odb::db$pin_type$disconnect"
  set get_command "get$pin_type"
  puts $find_command
  puts $connect_command
  puts $disconnect_command
  puts $get_command

  # Finding the block with pin name
  set iterm [$block $find_command $pin_name]
  puts "Successfully find old net"
  set old_net [$iterm getNet]
  puts "OLD_NET"
  puts $old_net

  # Original disconnert command
  #odb::dbITerm_disconnect $iterm

  # Disconnect the iterm
  $disconnect_command $iterm
  puts "Successfully create new net"

  # New net to connect to
  set new_net [odb::dbNet_create $block $net_name]
  
  # Original connect command
  #odb::dbITerm_connect $iterm $new_net

  # Connect to new net to iterm
  $connect_command $iterm $new_net
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
  puts "get the input and output"
  puts $input
  puts $output
  if {$pin_type=="ITerm"} {
      set in_iterm [$inst getITerm $input]
      puts "get in iterm"
      set out_iterm [$inst getITerm $output]
      puts "get out iterm"
      #set in_iterm [$inst $get_command $input]
      #set out_iterm [$inst $get_command $output]
      
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
      odb::dbITerm_connect $out_iterm $old_net
      #odb::dbITerm_connect $in_iterm $old_net
      puts "connect to in_iterm"
      odb::dbITerm_connect $in_iterm $new_net  
     #odb::dbITerm_connect $out_iterm $new_net
      puts "connect to out_iterm "
  #$connect_command $in_iterm $old_net
  #$connect_command $out_iterm $new_net
} else {
      set out_iterm [$inst getITerm $output]
      #set master_inst [$iterm getInst] 
      set box [$iterm getBBox] 
      set x_min [$box xMin] 
      set y_min [$box yMin]
      [$inst setLocation $x_min $y_min]
      [$inst setPlacementStatus PLACED] 
      puts "start insert buffer"
      odb::dbITerm_connect $inst $new_net $input 
      #odb::dbITerm_connect $out_iterm $new_net
      puts "connect to out iterm"
      odb::dbITerm_connect $out_iterm $old_net 
      #odb::dbITerm_connect $inst $old_net $input
      puts "connect to input pin!!!!!!!"     
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
    source "$::env(RUN_DIR)/results/eco/fix/eco_fix_$cur_iter.tcl"
    
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







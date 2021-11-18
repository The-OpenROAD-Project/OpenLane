
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
  set iterm [$block $pin_type $pin_name]
  puts "Successfully find old net"
  set old_net [$iterm getNet]
  puts "OLD_NET"
  puts $old_net
  odb::dbITerm_disconnect $iterm
  puts "Successfully create new net"
  set new_net [odb::dbNet_create $block $net_name]
  odb::dbITerm_connect $iterm $new_net
  puts "Successfully create new instance"
  set inst [odb::dbInst_create $block $new_master $inst_name]

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

  set in_iterm [$inst getITerm $input]
  set out_iterm [$inst getITerm $output]
# define the instance to which the buffer inserted will connected to
  set master_inst [$iterm getInst]
# get the geometry of the instance, geometry means its shape, the coordinate of its vertex...
  set box [$master_inst getBBox]
# get the position of the lower left point of this instance
  set x_min [$box xMin]
  set y_min [$box yMin]
# $inst is the buffer we want to insert, now insert it in the position of the instance it is connected to, using setLocation, and detail_place will help us separate them
  [$inst setLocation $x_min $y_min]
  [$inst setPlacementStatus PLACED]
# done inserting the buffer
  odb::dbITerm_connect $in_iterm $old_net
  odb::dbITerm_connect $out_iterm $new_net
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







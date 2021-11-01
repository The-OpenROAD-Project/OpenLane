run_eco

proc run_eco {args} {
	# Source fixes from PT
    # Fixes are currently unavailable
	# set fix_file [list $::env(RUN_DIR) results eco]
	# append fix_file $::env(ECO_ITER)_wc.tcl
    # source $fix_file
    
    puts "Running run_eco!"
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

proc insert_buffer {pin_name master_name net_name inst_name} {
  set db [ord::get_db]
  set new_master [$db findMaster $master_name]
  set block [ord::get_db_block]

  set block [ord::get_db_block]
  set iterm [$block findITerm $pin_name]
  set old_net [$iterm getNet]
  odb::dbITerm_disconnect $iterm
  set new_net [odb::dbNet_create $block $net_name]
  odb::dbITerm_connect $iterm $new_net
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

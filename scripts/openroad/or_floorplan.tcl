# Copyright 2020 Efabless Corporation
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
proc create_tracks args {
  set fp [open $::env(TRACKS_INFO_FILE) r]
  set file_data [read $fp]
  close $fp
  set lines [split $file_data "\n"]
  set state 0
  foreach line $lines {
    set words [split $line " "]
    if { $state == 0 || [lindex $words 0] != $layer } {
      set layer [lindex $words 0]
      set state 1
    }
    if { [lindex $words 1] == "X" } {
      set x_offset [lindex $words 2]
      set x_pitch [lindex $words 3]
      incr state
    } else {
      set y_offset [lindex $words 2]
      set y_pitch [lindex $words 3]
      incr state
    }
    if { $state == 3 } {
      make_tracks $layer -x_offset $x_offset -x_pitch $x_pitch -y_offset $y_offset -y_pitch $y_pitch
    }
  }
}

foreach lib $::env(LIB_SYNTH_COMPLETE) {
	read_liberty $lib
}

if {[catch {read_lef $::env(MERGED_LEF_UNPADDED)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

read_verilog $::env(yosys_result_file_tag).v
link_design $::env(DESIGN_NAME)
set bottom_margin  [expr $::env(PLACE_SITE_HEIGHT) * $::env(BOTTOM_MARGIN_MULT)]
set top_margin  [expr $::env(PLACE_SITE_HEIGHT) * $::env(TOP_MARGIN_MULT)]
set left_margin [expr $::env(PLACE_SITE_WIDTH) * $::env(LEFT_MARGIN_MULT)]
set right_margin [expr $::env(PLACE_SITE_WIDTH) * $::env(RIGHT_MARGIN_MULT)]


if {$::env(FP_SIZING) == "absolute"} {
  if { ! [info exists ::env(CORE_AREA)] } {
	set die_ll_x [lindex $::env(DIE_AREA) 0]
	set die_ll_y [lindex $::env(DIE_AREA) 1]
	set die_ur_x [lindex $::env(DIE_AREA) 2]
	set die_ur_y [lindex $::env(DIE_AREA) 3]

	set core_ll_x [expr {$die_ll_x + $left_margin}]
	set core_ll_y [expr {$die_ll_y + $bottom_margin}]
	set core_ur_x [expr {$die_ur_x - $right_margin}]
	set core_ur_y [expr {$die_ur_y - $top_margin}]

	set ::env(CORE_AREA) [list $core_ll_x $core_ll_y $core_ur_x $core_ur_y]
  } else {
	puts "\[INFO] Using the set CORE_AREA; ignoring core margin parameters"
  }

  initialize_floorplan \
    -die_area $::env(DIE_AREA) \
    -core_area $::env(CORE_AREA) \
    -site $::env(PLACE_SITE)
  
  create_tracks

} else {


  initialize_floorplan \
    -utilization $::env(FP_CORE_UTIL) \
    -aspect_ratio $::env(FP_ASPECT_RATIO) \
    -core_space "$bottom_margin $top_margin $left_margin $right_margin" \
    -site $::env(PLACE_SITE)
  create_tracks

    set ::chip [[::ord::get_db] getChip]
    set ::tech [[::ord::get_db] getTech]
    set ::block [$::chip getBlock]
    puts "\[INFO] Extracting DIE_AREA and CORE_AREA from the floorplan"
    set ::env(DIE_AREA) [list]
    set ::env(CORE_AREA) [list]

    set die_area [$::block getDieArea]
    set core_area [$::block getCoreArea] 

    set die_area [list [$die_area xMin] [$die_area yMin] [$die_area xMax] [$die_area yMax]]
    set core_area [list [$core_area xMin] [$core_area yMin] [$core_area xMax] [$core_area yMax]]

    set dbu [$tech getDbUnitsPerMicron]

    foreach coord $die_area {
      lappend ::env(DIE_AREA) [expr {1.0 * $coord / $dbu}]
    }
    foreach coord $core_area {
      lappend ::env(CORE_AREA) [expr {1.0 * $coord / $dbu}]
    }

    puts "\[INFO] Floorplanned on a die area of $::env(DIE_AREA) (microns). Saving to $::env(verilog2def_report_file_tag).die_area.rpt."
    puts "\[INFO] Floorplanned on a core area of $::env(CORE_AREA) (microns). Saving to $::env(verilog2def_report_file_tag).core_area.rpt."
}

set die_area_file [open $::env(verilog2def_report_file_tag).die_area.rpt w]
set core_area_file [open $::env(verilog2def_report_file_tag).core_area.rpt w]
    puts $die_area_file $::env(DIE_AREA)
    puts $core_area_file $::env(CORE_AREA)
close $core_area_file
close $die_area_file

write_def $::env(SAVE_DEF)

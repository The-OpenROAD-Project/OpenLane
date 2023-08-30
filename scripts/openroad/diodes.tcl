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

# NORMAL MODE: inserts diode cells
# OPTIMIZED MODE: inserts a fake diode, to be replaced later with a real diode if necessary
source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
read

set ::PREFIX ANTENNA
set ::VERBOSE 0
set ::block [[[::ord::get_db] getChip] getBlock]
set ::antenna_pin_name $::env(DIODE_CELL_PIN)
set ::nets [$::block getNets]

if { $::env(DIODE_INSERTION_STRATEGY) == 2 } {
	if { ! [info exists ::env(FAKEDIODE_CELL)] } {
		puts "\[ERROR\]: FAKEDIODE_CELL is undefined. Try a different DIODE_INSERTION_STRATEGY."
		exit 1
	}
	set ::antenna_cell_name $::env(FAKEDIODE_CELL)
} else {
	set ::antenna_cell_name $::env(DIODE_CELL)
}

proc add_antenna_cell { iterm } {
	set antenna_master [[::ord::get_db] findMaster $::antenna_cell_name]
	set antenna_mterm [$antenna_master getMTerms]

	set iterm_net [$iterm getNet]
	set iterm_inst [$iterm getInst]
	set iterm_inst_name [$iterm_inst getName]
	set iterm_pin_name [[$iterm getMTerm] getConstName]
	set inst_ori [$iterm_inst getOrient]

	foreach {success avg_iterm_x avg_iterm_y} [$iterm getAvgXY] {}
	if { ! $success } {
		foreach {avg_iterm_x avg_iterm_y} [$iterm_inst getLocation] {}
	}

	set antenna_inst_name ${::PREFIX}_${iterm_inst_name}_${iterm_pin_name}
	# create a 2-node "subnet" for the antenna (for easy removal) -> doesn't work
	# set antenna_subnet [odb::dbNet_create $::block NET_${antenna_inst_name}]
	set antenna_inst [odb::dbInst_create $::block $antenna_master $antenna_inst_name]
	set antenna_iterm [$antenna_inst findITerm $::antenna_pin_name]

	$antenna_inst setLocation $avg_iterm_x $avg_iterm_y
	$antenna_inst setOrient $inst_ori
	$antenna_inst setPlacementStatus PLACED
	$antenna_iterm connect $iterm_net

	if { $::VERBOSE } {
		puts "\[INFO\]: Adding $antenna_inst_name on subnet $antenna_subnet for cell $iterm_inst_name pin $iterm_pin_name"
	}
}

set count 0
puts "\[INFO\]: Inserting $::antenna_cell_name..."
foreach net $::nets {
	set net_name [$net getName]
	if { [expr {$net_name eq $::env(VDD_PIN)} || {$net_name eq $::env(GND_PIN)}] } {
		puts "\[WARN\]: Skipping $net_name"
	} else {
		set iterms [$net getITerms]
		foreach iterm $iterms {
			if { [$iterm isInputSignal] } {
				add_antenna_cell $iterm
				set count [expr $count + 1]
			}
		}
	}
}
puts "\n\[INFO\]: $count of $::antenna_cell_name inserted!"
set_placement_padding -masters $::env(DIODE_CELL) -left $::env(DIODE_PADDING)
puts "\[INFO\]: Legalizing..."
detailed_placement
if { [info exists ::env(PL_OPTIMIZE_MIRRORING)] && $::env(PL_OPTIMIZE_MIRRORING) } {
	optimize_mirroring
}

write

if { [catch {check_placement -verbose} errmsg] } {
	puts stderr $errmsg
	exit 1
}

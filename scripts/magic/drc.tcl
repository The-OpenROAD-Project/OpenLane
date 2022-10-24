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

if { [info exist ::env(MAGIC_DRC_USE_GDS)] && $::env(MAGIC_DRC_USE_GDS) } {
	gds read $::env(CURRENT_GDS)
} else {
	source $::env(SCRIPTS_DIR)/magic/def/read.tcl
}

set drc_rpt_path $::env(drc_prefix).rpt
set fout [open $drc_rpt_path w]
set oscale [cif scale out]
set cell_name $::env(DESIGN_NAME)
magic::suspendall
puts stdout "\[INFO\]: Loading $cell_name\n"
flush stdout
load $cell_name
select top cell
drc euclidean on
drc style drc(full)
drc check
set drcresult [drc listall why]


set count 0
puts $fout "$cell_name"
puts $fout "----------------------------------------"
foreach {errtype coordlist} $drcresult {
	puts $fout $errtype
	puts $fout "----------------------------------------"
	foreach coord $coordlist {
		set bllx [expr {$oscale * [lindex $coord 0]}]
		set blly [expr {$oscale * [lindex $coord 1]}]
		set burx [expr {$oscale * [lindex $coord 2]}]
		set bury [expr {$oscale * [lindex $coord 3]}]
		set coords [format " %.3fum %.3fum %.3fum %.3fum" $bllx $blly $burx $bury]
		puts $fout "$coords"
		set count [expr {$count + 1} ]
	}
	puts $fout "----------------------------------------"
}

puts $fout "\[INFO\]: COUNT: $count"
puts $fout "\[INFO\]: Should be divided by 3 or 4"

puts $fout ""
close $fout

puts stdout "\[INFO\]: COUNT: $count"
puts stdout "\[INFO\]: Should be divided by 3 or 4"
puts stdout "\[INFO\]: DRC Checking DONE ($drc_rpt_path)"
flush stdout

set mag_view $::env(signoff_results)/$::env(DESIGN_NAME).drc.mag
puts stdout "\[INFO\]: Saving mag view with DRC errors ($mag_view)"
# WARNING: changes the name of the cell; keep as last step
save $mag_view
puts stdout "\[INFO\]: Saved"

exit 0

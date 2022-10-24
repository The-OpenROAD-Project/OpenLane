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

# convert all external macros to maglef views with GDS_* pointers

drc off

if {  [info exist ::env(EXTRA_LEFS)] } {
	foreach lef_file $::env(EXTRA_LEFS) {
		lef read $lef_file
	}
}

cellname delete \(UNNAMED\)

foreach design_name [cellname list allcells] {
	load $design_name

	cellname filepath $design_name $::env(signoff_results)

	save

	# Copy GDS pointers from .full.mag files into .mag files

	set gds_properties [list]
	set fp [open $design_name.full.mag r]

	set mag_lines [split [read $fp] "\n"]
	foreach line $mag_lines {
		if { [string first "string GDS_" $line] != -1 } {
			lappend gds_properties $line
		}
	}
	close $fp

	set fp [open $design_name.mag r]
	set mag_lines [split [read $fp] "\n"]
	set new_mag_lines [list]
	foreach line $mag_lines {
		if { [string first "<< end >>" $line] != -1 } {
			lappend new_mag_lines [join $gds_properties "\n"]
		}
		lappend new_mag_lines $line
	}
	close $fp

	set fp [open $design_name.mag w]
	puts $fp [join $new_mag_lines "\n"]
	close $fp
}

exit 0

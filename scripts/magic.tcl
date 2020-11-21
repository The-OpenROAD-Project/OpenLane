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

drc off

lef read $::env(TECH_LEF)

if {  [info exist ::env(EXTRA_LEFS)] } {
	set lefs_in $::env(EXTRA_LEFS)
	foreach lef_file $lefs_in {
		lef read $lef_file
	}
}

# Read def and load design
def read $::env(CURRENT_DEF)

gds readonly true
gds rescale false
if {  [info exist ::env(EXTRA_GDS_FILES)] } {
       set gds_files_in $::env(EXTRA_GDS_FILES)
       foreach gds_file $gds_files_in {
               gds read $gds_file
       }
}


load $::env(DESIGN_NAME)
select top cell

# padding

if { $::env(MAGIC_PAD) } {
	puts "\[INFO\]: Padding LEFs"
	# assuming scalegrid 1 2
	# use um
	select top cell
	box grow right [expr 100*($::env(PLACE_SITE_WIDTH))]
	box grow left [expr 100*($::env(PLACE_SITE_WIDTH))]
	box grow up [expr 100*($::env(PLACE_SITE_HEIGHT))]
	box grow down [expr 100*($::env(PLACE_SITE_HEIGHT))]
	property FIXED_BBOX [box values]
}
if { $::env(MAGIC_ZEROIZE_ORIGIN) } {
	# assuming scalegrid 1 2
	# makes origin zero based on the selection
	puts "\[INFO\]: Zeroizing Origin"
	set bbox [box values]
	set offset_x [lindex $bbox 0]
	set offset_y [lindex $bbox 1]
	move origin [expr {$offset_x/2}] [expr {$offset_y/2}]
	puts "\[INFO\]: Current Box Values: [box values]"
	property FIXED_BBOX [box values]
}

select top cell


# Write gds
if { $::env(MAGIC_GENERATE_GDS) } {
	cif *hier write disable
	#gds write $::env(DESIGN_NAME).gds
	gds write $::env(magic_result_file_tag).gds
	puts "\[INFO\]: GDS Write Complete"
}

if { $::env(MAGIC_GENERATE_LEF) } {
	if { $::env(MAGIC_WRITE_FULL_LEF) } {
		puts "\[INFO\]: Writing non-abstract (full) LEF"
		lef write $::env(magic_result_file_tag).lef
	} else {
		puts "\[INFO\]: Writing abstract LEF"
		if { [info exists ::env(FP_PDN_CORE_RING)] && $::env(FP_PDN_CORE_RING) == 1 } {
			set tolerance 1
			set cr_offset [expr max($::env(FP_PDN_CORE_RING_HOFFSET), $::env(FP_PDN_CORE_RING_VOFFSET))/2]
			set cr_spacing [expr max($::env(FP_PDN_CORE_RING_HSPACING), $::env(FP_PDN_CORE_RING_VSPACING))]
			set cr_width [expr max($::env(FP_PDN_CORE_RING_HWIDTH), $::env(FP_PDN_CORE_RING_VWIDTH))]
			set cr_distance [expr $cr_offset + $cr_spacing + 2 * $cr_width - $tolerance]
			lef write $::env(magic_result_file_tag).lef -hide ${cr_distance}um
		} else {
			lef write $::env(magic_result_file_tag).lef -hide
		}
	}
	puts "\[INFO\]: LEF Write Complete"
}

exit 0

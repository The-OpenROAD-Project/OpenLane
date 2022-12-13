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

# convert all external macros to mag views with GDS pointers
# we will only copy the GDS pointers from these files in the
# corresponding maglefs

drc off

gds readonly true
gds rescale false

if { $::env(MAGIC_GDS_POLYGON_SUBCELLS) } {
    gds polygon subcells true
}

if {  [info exist ::env(EXTRA_GDS_FILES)] } {
	set gds_files_in $::env(EXTRA_GDS_FILES)
	foreach gds_file $gds_files_in {
		gds read $gds_file

		select top cell
		set design_name [cellname list self]

		cellname filepath $design_name $::env(signoff_results)

		save

		# maglefs reserve the original names
		file rename $::env(signoff_results)/$design_name.mag $::env(signoff_results)/$design_name.full.mag

		puts "\[INFO]: Saved mag view from $gds_file under $::env(signoff_results)"
	}
}

exit 0

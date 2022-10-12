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

gds readonly true
gds rescale false

# This comes afterwards, so that it would contain GDS pointers
# And yes, we need to re-read the GDS we just generated...
gds read $::env(MAGIC_GDS)

cellname filepath $::env(DESIGN_NAME) $::env(signoff_tmpfiles)
save

set final_filepath $::env(signoff_tmpfiles)/gds_ptrs.mag

file rename -force $::env(signoff_tmpfiles)/$::env(DESIGN_NAME).mag $final_filepath

puts "\[INFO\]: Wrote $final_filepath including GDS pointers."
exit 0

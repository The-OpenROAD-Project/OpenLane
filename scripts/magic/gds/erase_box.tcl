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

tech unlock *

gds read $::env(CURRENT_GDS)

set box_coordinates [list]
lappend box_coordinates {*}$::env(_tmp_mag_box_coordinates)

box [lindex box_coordinates 2]um [lindex box_coordinates 3]um [lindex box_coordinates 4]um [lindex box_coordinates 5]um

erase
select area
delete

select top cell
erase labels

if { $::env(MAGIC_GDS_ALLOW_ABSTRACT) } { 
    gds abstract allow
}

gds write $::env(SAVE_GDS)

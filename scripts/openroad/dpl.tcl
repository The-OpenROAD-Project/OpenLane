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
source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
read

source $::env(SCRIPTS_DIR)/openroad/common/dpl_cell_pad.tcl

detailed_placement\
    -max_displacement [subst { $::env(PL_MAX_DISPLACEMENT_X) $::env(PL_MAX_DISPLACEMENT_Y) }]

if { [info exists ::env(PL_OPTIMIZE_MIRRORING)] && $::env(PL_OPTIMIZE_MIRRORING) } {
    optimize_mirroring
}

if { [catch {check_placement -verbose} errmsg] } {
    puts stderr $errmsg
    exit 1
}

write
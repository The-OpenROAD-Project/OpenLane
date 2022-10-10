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
source $::env(SCRIPTS_DIR)/magic/def/read.tcl

load $::env(DESIGN_NAME) -dereference

set extdir $::env(signoff_tmpfiles)/magic_antenna_ext
file mkdir $extdir
cd $extdir

select top cell
extract do local
extract no capacitance
extract no coupling
extract no resistance
extract no adjust
if { ! $::env(LVS_CONNECT_BY_LABEL) } {
    extract unique
}
extract
feedback save $::env(_tmp_feedback_file)

antennacheck debug
antennacheck
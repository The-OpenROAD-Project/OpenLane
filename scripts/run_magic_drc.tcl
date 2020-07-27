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

set magicrc $::env(TMP_DIR)/magic_drc.magicrc
set ::env(PDKPATH) "$::env(PDK_ROOT)/$::env(PDK)"
# the following MAGTYPE has to be maglef for the purpose of DRC checking
set ::env(MAGTYPE) maglef
set ::env(MAGPATH) "$::env(PDKPATH)/libs.ref/$::env(MAGTYPE)"
exec envsubst < $::env(MAGIC_MAGICRC) > $magicrc
exec magic \
        -noconsole \
        -dnull \
        -rcfile $magicrc \
        $::env(SCRIPTS_DIR)/magic_drc.tcl \
	</dev/null \
        |& tee $::env(TERMINAL_OUTPUT) $::env(magic_log_file_tag).drc.log

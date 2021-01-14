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

proc run_klayout {args} {
    if {[info exists ::env(RUN_KLAYOUT)] && $::env(RUN_KLAYOUT)} {
        set ::env(CURRENT_STAGE) klayout
        puts_info "Running Klayout to re-generate GDS-II..."
        puts_info "Streaming out GDS II..."
        set gds_files_in ""
        if {  [info exist ::env(EXTRA_GDS_FILES)] } {
            set gds_files_in $::env(EXTRA_GDS_FILES)
        }
        try_catch bash $::env(SCRIPTS_DIR)/klayout/def2gds.sh $::env(KLAYOUT_TECH) $::env(CURRENT_DEF) $::env(DESIGN_NAME) $::env(klayout_result_file_tag).gds "$::env(GDS_FILES) $gds_files_in" |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(klayout_log_file_tag).log]
        file copy -force $::env(KLAYOUT_PROPERTIES) $::env(klayout_result_file_tag).lyp
    }
}

package provide openlane 0.9

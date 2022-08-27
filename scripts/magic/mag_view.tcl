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

lef read $::env(TECH_LEF)
if {  [info exist ::env(EXTRA_LEFS)] } {
    set lefs_in $::env(EXTRA_LEFS)
    foreach lef_file $lefs_in {
        lef read $lef_file
    }
}
def read $::env(_tmp_def_in)

save $::env(_tmp_save_mag)

puts "[INFO]: Done exporting $::env(_tmp_save_mag)."
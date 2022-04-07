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

lef read $::env(signoff_results)/$::env(DESIGN_NAME).lef

load $::env(DESIGN_NAME)

cellname rename $::env(DESIGN_NAME) $::env(DESIGN_NAME).lef

cellname filepath $::env(DESIGN_NAME).lef $::env(signoff_results)
save

puts "\[INFO\]: DONE GENERATING MAGLEF VIEW"
exit 0

# Copyright 2022 Efabless Corporation
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

set signal_min_layer $::env(RT_MIN_LAYER)
set signal_max_layer $::env(RT_MAX_LAYER)
set clock_min_layer $::env(RT_MIN_LAYER)
set clock_max_layer $::env(RT_MAX_LAYER)

if { [info exists ::env(RT_CLOCK_MIN_LAYER)]} {
    set clock_min_layer $::env(RT_CLOCK_MIN_LAYER)
}
if { [info exists ::env(RT_CLOCK_MAX_LAYER)]} {
    set clock_max_layer $::env(RT_CLOCK_MAX_LAYER)
}

puts "\[INFO]: Setting signal min routing layer to: $signal_min_layer and clock min routing layer to $clock_min_layer. "
puts "\[INFO]: Setting signal max routing layer to: $signal_max_layer and clock max routing layer to $clock_max_layer. "

set_routing_layers -signal [subst $signal_min_layer]-[subst $signal_max_layer] -clock [subst $clock_min_layer]-[subst $clock_max_layer]

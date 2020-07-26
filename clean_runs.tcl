#!/usr/bin/tclsh8.5
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

set ::env(OPENLANE_ROOT) [file dirname [file normalize [info script]]]
lappend ::auto_path "$::env(OPENLANE_ROOT)/scripts/"


package require openlane_utils

puts_warn "DELETING ALL DESIGN RUNS!"

if { ! [catch {glob designs/*/runs} runs] } {
	file delete -force  {*}$runs
	puts_success "ALL DESIGN RUNS ARE DELETED!"
} else {
	puts_info "No runs to delete"
}

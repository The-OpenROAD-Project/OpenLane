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

#source /openLANE_flow/scripts/magic.tcl
if { $argc < 7 } {
    puts "The magic_gds_to_lef.tcl script requires 4 flags and 2 arguments to be inputed: the directory and the gds file prefix."
    puts "tclsh magic_gds_to_lef.tcl /home/user/designs/runs/todayRun/ spm"
    puts "Please try again."
} else {
    cd [lindex $argv 6]
    gds read [lindex $argv 7].gds                                     
    load [lindex $argv 7]                                             
    select top cell           
    cd [lindex $argv 8]                                                                         
    lef write [lindex $argv 9].lef -hide
}

exit


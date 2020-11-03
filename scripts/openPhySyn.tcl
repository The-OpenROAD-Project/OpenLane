#Psn ; # or ./build/Psn if not installed in the global path
#BSD 3-Clause License
#Copyright (c) 2019, SCALE Lab, Brown University
#All rights reserved.
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are met:
#* Redistributions of source code must retain the above copyright notice, this
#  list of conditions and the following disclaimer.
#* Redistributions in binary form must reproduce the above copyright notice,
#  this list of conditions and the following disclaimer in the documentation
#  and/or other materials provided with the distribution.
#* Neither the name of the copyright holder nor the names of its
#  contributors may be used to endorse or promote products derived from
#  this software without specific prior written permission.
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
#FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import_lib $::env(LIB_OPT)
import_lef $::env(MERGED_LEF_UNPADDED)
import_def $::env(CURRENT_DEF)
read_sdc $::env(BASE_SDC_FILE)

set_wire_rc $::env(WIRE_RC_LAYER)

puts "=============== Initial Reports ============="
report_checks
report_check_types -max_slew -max_capacitance -violators
puts "Capacitance violations: [llength [capacitance_violations]]"
puts "Transition violations: [llength [transition_violations]]"
report_wns
report_tns

puts "Initial area: [expr round([design_area] * 10E12) ] um2"

puts "OpenPhySyn timing repair:"

set opts ""

if { $::env(PSN_ENABLE_RESIZING) == 0 } {
    set opts "$opts -resize_disabled"
} 

if { $::env(PSN_ENABLE_PIN_SWAP) == 0 } {   
    set opts "$opts -pin_swap_disabled"
} 


repair_timing -capacitance_violations -transition_violations -fanout_violations -negative_slack_violations $opts

puts "=============== Final Reports ============="
report_checks
report_checks > $::env(openphysyn_report_file_tag)_allchecks.rpt
report_check_types -max_slew -max_capacitance -violators
report_check_types -max_slew -max_capacitance -violators > $::env(openphysyn_report_file_tag)_violators.rpt
puts "Capacitance violations: [llength [capacitance_violations]]"
puts "Transition violations: [llength [transition_violations]]"
report_wns
report_wns > $::env(openphysyn_report_file_tag)_wns.rpt
report_tns
report_tns > $::env(openphysyn_report_file_tag)_tns.rpt

puts "Final area: [expr round([design_area] * 10E12) ] um2"

puts "Export optimized design"
export_def $::env(SAVE_DEF)
exit 0


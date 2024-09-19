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


proc run_erc {args} {
    if { ![info exists ::env(CVC_SCRIPTS_DIR)] } {
        puts_warn "This PDK does not support the Circuit Validity Checker, skipping..."
        return
    }

    if { [info exists ::env(EXTRA_LEFS)] } {
        puts_info "Your design contains macros, which is not supported by the current integration of the Circuit Validity Checker. So CVC won't run, however CVC is just a check so it's not critical to your design."
        return
    }

    if { $::env(VDD_PIN) != $::env(VDD_NETS) || $::env(GND_PIN) != $::env(GND_NETS)} {
        puts_info "Your design uses the advanced power settings, which is not supported by the current integration of the Circuit Validity Checker. So CVC won't run, however CVC is just a check so it's not critical to your design."
        return
    }

    set lef_spice $::env(signoff_results)/$::env(DESIGN_NAME).lef.spice
    if { ![file exist $lef_spice] } {
        puts_warn "No lefspice found, skipping CVC..."
        return
    }

    increment_index
    TIMER::timer_start
    set log [index_file $::env(signoff_logs)/erc_screen.log]
    puts_info "Running Circuit Validity Checker ERC (log: [relpath . $log])..."

    # merge cdl views of the optimization library and the base library if they are different
    if { $::env(STD_CELL_LIBRARY_OPT) != $::env(STD_CELL_LIBRARY) } {
        set lib_cdl $::env(qor_tempfiles)/merged.cdl
        file copy -force $::env(STD_CELL_LIBRARY_CDL) $lib_cdl
        set out [open $lib_cdl a]
        set in [open $::env(STD_CELL_LIBRARY_OPT_CDL)]
        fcopy $in $out
        close $in
        close $out
    } else {
        set lib_cdl $::env(STD_CELL_LIBRARY_CDL)
    }

    # Create power file
    try_exec awk -v vdd=$::env(VDD_PIN) -v gnd=$::env(GND_PIN) \
        -f $::env(CVC_SCRIPTS_DIR)/power.awk $::env(CURRENT_NETLIST) \
        > $::env(signoff_tmpfiles)/$::env(DESIGN_NAME).power

    # Create cdl file by combining cdl library with lef spice
    try_exec awk -f $::env(CVC_SCRIPTS_DIR)/cdl.awk $lib_cdl $lef_spice \
        > $::env(signoff_tmpfiles)/$::env(DESIGN_NAME).cdl

    # The main event
    try_exec cvc_rv $::env(CVC_SCRIPTS_DIR)/cvcrc \
        |& tee $::env(TERMINAL_OUTPUT) $log

    TIMER::timer_stop

    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "erc - circuit validity checker"
}

proc run_lef_cvc {args} {
    handle_deprecated_command run_erc
}

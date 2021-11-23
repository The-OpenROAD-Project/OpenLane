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


proc run_lef_cvc {args} {
    if { [info exists ::env(EXTRA_LEFS)] } {
        puts_info "Your design contains macros, which is not supported by the current integration of CVC. So CVC won't run, however CVC is just a check so it's not critical to your design."
    } else {
        if { $::env(VDD_PIN) != $::env(VDD_NETS) || $::env(GND_PIN) != $::env(GND_NETS)} {
            puts_info "Your design uses the advanced power settings, which is not supported by the current integration of CVC. So CVC won't run, however CVC is just a check so it's not critical to your design."
        } else {
            if {$::env(RUN_CVC) == 1 && [file exist $::env(SCRIPTS_DIR)/cvc/$::env(PDK)/cvcrc.$::env(PDK)]} {
		    increment_index
            puts_info "Running CVC"
            TIMER::timer_start
            set cvc_power_awk "\
BEGIN {  # Print power and standard_input definitions
    print \"$::env(VDD_PIN) power 1.8\";
    print \"$::env(GND_PIN) power 0.0\";
    print \"#define std_input min@$::env(GND_PIN) max@$::env(VDD_PIN)\";
}
\$1 == \"input\" {  # Print input nets
    gsub(/;/, \"\");
    if ( \$2 == \"$::env(VDD_PIN)\" || \$2 == \"$::env(GND_PIN)\" ) {  # ignore power nets
        next;
    }
    if ( NF == 3 ) {  # print buses as net\[range\]
        \$2 = \$3 \$2;
    }
    print \$2, \"input std_input\";
}"

    set cvc_cdl_awk "\
/Black-box entry subcircuit/ {  # remove black-box defintions
    while ( \$1 != \".ends\" ) {
        getline;
    }
    getline;
}
/^\\\*/ {  # remove comments
    next;
}
/^.ENDS .*/ {  # remove name from ends lines
    print \$1;
    next;
}
 {
    print \$0;
}"
	    # For compatibility purposes because master is frozen
	    # TODO: Remove in later versions
	    if { ! [info exists ::env(STD_CELL_LIBRARY_CDL)] } {
                set ::env(STD_CELL_LIBRARY_CDL) $::env(PDK_ROOT)/$::env(PDK)/libs.ref/$::env(STD_CELL_LIBRARY)/cdl/$::env(STD_CELL_LIBRARY).cdl
        }
        
        # merge cdl views of the optimization library and the base library if they are different
        if { $::env(STD_CELL_LIBRARY_OPT) != $::env(STD_CELL_LIBRARY)} {
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
            try_catch awk $cvc_power_awk $::env(CURRENT_NETLIST) > $::env(finishing_tmpfiles)/$::env(DESIGN_NAME).power
            # Create cdl file by combining cdl library with lef spice
	        try_catch awk $cvc_cdl_awk $lib_cdl $::env(finishing_results)/$::env(DESIGN_NAME).lef.spice \
                > $::env(finishing_tmpfiles)/$::env(DESIGN_NAME).cdl
            try_catch cvc $::env(SCRIPTS_DIR)/cvc/$::env(PDK)/cvcrc.$::env(PDK) \
                |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(finishing_logs)/erc_screen.log]
            TIMER::timer_stop
		    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "erc - cvc"
            } else {
                puts_info "Skipping CVC"
            }
        }
    }
}

package provide openlane 0.9

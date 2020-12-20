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

# WORKS ON VERILOG FILES
proc verilog_to_verilogPower {args} {
    puts_info "Adding Power Nets to Verilog..."
    set options {
      {-input required}
      {-output required}
      {-lef required}
      {-power required}
      {-ground required}
    }
    set flags {}
    parse_key_args "verilog_to_verilogPower" args arg_values $options flags_map $flags
    set bin vlog2Verilog
    set in $arg_values(-input)
    set out $arg_values(-output)
    set power $arg_values(-power)
    set gnd $arg_values(-ground)
    set lef $arg_values(-lef)

    try_catch $bin \
      -v $power \
      -g $gnd \
      -l $lef \
      $in |& tee $out
}

# WORKS ON DEF FILES
proc write_powered_verilog {args} {
    puts_info "Writing Powered Verilog..."
    set options {
      {-def optional}
      {-output_def optional}
      {-output_verilog optional}
      {-lef optional}
      {-power optional}
      {-ground optional}
      {-powered_netlist optional}
    }
    set flags {}
    parse_key_args "write_powered_verilog" args arg_values $options flags_map $flags
    set_if_unset arg_values(-def) $::env(CURRENT_DEF)
    set_if_unset arg_values(-output_def) $::env(TMP_DIR)/routing/$::env(DESIGN_NAME).powered.def
    set_if_unset arg_values(-output_verilog) $::env(lvs_result_file_tag).powered.v
    set_if_unset arg_values(-power) $::env(VDD_PIN)
    set_if_unset arg_values(-ground) $::env(GND_PIN)
    set_if_unset arg_values(-lef) $::env(MERGED_LEF)


    if { [info exists ::env(SYNTH_USE_PG_PINS_DEFINES)] } {
        set_if_unset arg_values(-powered_netlist) $::env(yosys_tmp_file_tag).pg_define.v
    } else {
        set_if_unset arg_values(-powered_netlist) ""
    }

    try_catch python3 $::env(SCRIPTS_DIR)/write_powered_def.py \
      -d $arg_values(-def) \
      -l $arg_values(-lef) \
      --power-port $arg_values(-power) \
      --ground-port $arg_values(-ground) \
      --powered-netlist $arg_values(-powered_netlist) \
      -o $arg_values(-output_def) \
      |& tee $::env(TERMINAL_OUTPUT) $::env(LOG_DIR)/lvs/write_powered_verilog.log

    write_verilog $arg_values(-output_verilog) -def $arg_values(-output_def) -canonical
}

# "layout": a spice netlist
# "schematic": a verilog netlist
proc run_lvs {{layout "$::env(magic_result_file_tag).spice"} {schematic "$::env(CURRENT_NETLIST)"}} {
    puts_info "Running LVS..."

    set layout [subst $layout]
    set schematic [subst $schematic]

    set setup_file $::env(NETGEN_SETUP_FILE)
    set module_name $::env(DESIGN_NAME)
    set output $::env(lvs_result_file_tag).log

    puts_info "$layout against $schematic"

    try_catch netgen -batch lvs \
      "$layout $module_name" \
      "$schematic $module_name" \
      $setup_file \
      $output \
      -json |& tee $::env(TERMINAL_OUTPUT) $::env(lvs_log_file_tag).log

    exec python3 $::env(SCRIPTS_DIR)/count_lvs.py -f $::env(lvs_result_file_tag).json \
      |& tee $::env(TERMINAL_OUTPUT) $::env(lvs_result_file_tag)_parsed.log
}

proc run_netgen {args} {
    handle_deprecated_command run_lvs
}
package provide openlane 0.9

proc run_lef_cvc {args} {
    if {$::env(RUN_CVC) == 1 && [file exist $::env(SCRIPTS_DIR)/cvc/$::env(PDK)/cvcrc.$::env(PDK)]} {
    puts_info "Running CVC"
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

    # Create power file
    try_catch awk $cvc_power_awk $::env(CURRENT_NETLIST) > $::env(cvc_result_file_tag).power
    # Create cdl file by combining cdl library with lef spice
    try_catch awk $cvc_cdl_awk $::env(PDK_ROOT)/$::env(PDK)/libs.ref/$::env(STD_CELL_LIBRARY)/cdl/$::env(STD_CELL_LIBRARY).cdl $::env(magic_result_file_tag).lef.spice \
        > $::env(cvc_result_file_tag).cdl
    try_catch cvc $::env(SCRIPTS_DIR)/cvc/$::env(PDK)/cvcrc.$::env(PDK) \
        |& tee $::env(TERMINAL_OUTPUT) $::env(cvc_log_file_tag)_screen.log
    } else {
        puts_info "Skipping CVC"
    }
}

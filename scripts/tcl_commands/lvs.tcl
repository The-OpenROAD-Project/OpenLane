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
    set_if_unset arg_values(-output_def) [index_file $::env(TMP_DIR)/routing/$::env(DESIGN_NAME).powered.def]
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
      |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(LOG_DIR)/lvs/write_powered_verilog.log 0]
    write_verilog $arg_values(-output_verilog) -def $arg_values(-output_def) -canonical
}

# "layout": a spice netlist
# "schematic": a verilog netlist
proc run_lvs {{layout "$::env(EXT_NETLIST)"} {schematic "$::env(CURRENT_NETLIST)"}} {
    # LEF LVS output to lvs.lef.log, design.lvs_parsed.lef.log, design.lvs.lef.json, design.lvs.lef.log
    # GDS LVS output to lvs.gds.log, design.lvs_parsed.gds.log, design.lvs.gds.json, design.lvs.gds.log
    # GDS LVS uses STD_CELL_LIBRARY spice and
    # if defined, additional LVS_EXTRA_STD_CELL_LIBRARY spice and LVS_EXTRA_GATE_LEVEL_VERILOG files
    TIMER::timer_start
    if { [info exist ::env(MAGIC_EXT_USE_GDS)] && $::env(MAGIC_EXT_USE_GDS) } {
        set extract_type gds
        puts_info "Running GDS LVS..."
    } else {
        set extract_type lef
        puts_info "Running LEF LVS..."
    }

    set layout [subst $layout]
    set schematic [subst $schematic]

    set setup_file $::env(NETGEN_SETUP_FILE)
    set module_name $::env(DESIGN_NAME)
    #writes setup_file_*_lvs to tmp directory.
    set lvs_file [open $::env(TMP_DIR)/lvs/setup_file.$extract_type.lvs w]
    if { "$extract_type" == "gds" } {
        if { [info exist ::env(LVS_EXTRA_STD_CELL_LIBRARY)] } {
            set libs_in $::env(LVS_EXTRA_STD_CELL_LIBRARY)
            foreach lib_file $libs_in {
                puts $lvs_file "puts \"Reading spice netlist file $lib_file\""
                puts $lvs_file "readnet spice $lib_file 1"
            }
        } else {
            if { [info exist ::env(STD_CELL_LIBRARY)] } {
                set std_cell_source $::env(PDK_ROOT)/$::env(PDK)/libs.ref/$::env(STD_CELL_LIBRARY)/spice/$::env(STD_CELL_LIBRARY).spice
            } else {
                set std_cell_source $::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice
            }
            puts $lvs_file "puts \"Reading spice netlist file $std_cell_source\""
            puts $lvs_file "readnet spice $std_cell_source 1"
        }
        if { [info exist ::env(LVS_EXTRA_GATE_LEVEL_VERILOG)] } {
            set libs_in $::env(LVS_EXTRA_GATE_LEVEL_VERILOG)
            foreach lib_file $libs_in {
                puts $lvs_file "puts \"Reading verilog netlist file $lib_file\""
                puts $lvs_file "readnet verilog $lib_file 1"
            }
        }
    }
    puts $lvs_file "lvs {$layout $module_name} {$schematic $module_name} $setup_file $::env(lvs_result_file_tag).$extract_type.log -json"
    close $lvs_file
    puts_info "$layout against $schematic"

    try_catch netgen -batch source $::env(TMP_DIR)/lvs/setup_file.$extract_type.lvs \
      |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(lvs_log_file_tag).$extract_type.log]
    exec python3 $::env(SCRIPTS_DIR)/count_lvs.py -f $::env(lvs_result_file_tag).$extract_type.json \
      |& tee $::env(TERMINAL_OUTPUT) $::env(lvs_result_file_tag)_parsed.$extract_type.log

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> [index_file $::env(lvs_log_file_tag)_runtime.txt 0]
    quit_on_lvs_error -log $::env(lvs_result_file_tag)_parsed.$extract_type.log
}

proc run_netgen {args} {
    handle_deprecated_command run_lvs
}

package provide openlane 0.9

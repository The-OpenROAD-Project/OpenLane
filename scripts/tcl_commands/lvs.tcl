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

    try_exec $bin \
        -v $power \
        -g $gnd \
        -l $lef \
        $in |& tee $out
}

# WORKS ON DEF FILES
proc write_powered_verilog {args} {
    set options {
        # Required (Manual Check)
        {-output_def required}
        {-output_nl optional}
        {-output_pnl optional}

        # Optional
        {-def optional}
        {-lef optional}
        {-power optional}
        {-ground optional}
        {-powered_netlist optional}
        {-output_verilog optional}
    }
    set flags {}

    parse_key_args "write_powered_verilog" args arg_values $options flags_map $flags

    if { [info exists arg_values(-output_verilog)] } {
        puts_warn "The -output_verilog option of write_powered_verilog is deprecated."
        puts_warn "Update your invocation to:"
        puts_warn "    write_powered_verilog -output_nl <UNPOWERED_NETLIST> -output_pnl <POWERED_NETLIST>"

        set arg_values(-output_nl) "$arg_values(-output_verilog).unpowered.nl.v"
        set arg_values(-output_pnl) $arg_values(-output_verilog)
    } else {
        if { ![info exists arg_values(-output_nl)] } {
            puts_err "-output_nl is required for write_powered_verilog."
            throw_error
        }
        if { ![info exists arg_values(-output_pnl)] } {
            puts_err "-output_pnl is required for write_powered_verilog."
            throw_error
        }
    }

    set_if_unset arg_values(-def) $::env(CURRENT_DEF)
    set_if_unset arg_values(-power) $::env(VDD_PIN)
    set_if_unset arg_values(-ground) $::env(GND_PIN)
    set_if_unset arg_values(-lef) $::env(MERGED_LEF)

    increment_index
    TIMER::timer_start
    set log_def [index_file $::env(signoff_logs)/write_powered_def.log]
    set log [index_file $::env(signoff_logs)/write_powered_verilog.log]
    puts_info "Writing Powered Verilog (logs: [relpath . $log_def], [relpath . $log])..."

    if { [info exists ::env(SYNTH_USE_PG_PINS_DEFINES)] } {
        set_if_unset arg_values(-powered_netlist) $::env(synthesis_tmpfiles)/pg_define.v
    } else {
        set_if_unset arg_values(-powered_netlist) ""
    }

    try_exec $::env(OPENROAD_BIN) -exit -no_init -python $::env(SCRIPTS_DIR)/odbpy/power_utils.py write_powered_def\
        --output $arg_values(-output_def) \
        --input-lef $arg_values(-lef) \
        --power-port $arg_values(-power) \
        --ground-port $arg_values(-ground) \
        --powered-netlist $arg_values(-powered_netlist) \
        $arg_values(-def)\
        |& tee $::env(TERMINAL_OUTPUT) $log_def

    write_verilog\
        $arg_values(-output_nl)\
        -powered_to $arg_values(-output_pnl)\
        -def $arg_values(-output_def)\
        -no_global_connect \
        -indexed_log $log

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "write powered verilog - openlane"
}

# "layout": a spice netlist
# "schematic": a verilog netlist
proc run_lvs {{layout "$::env(EXT_NETLIST)"}} {
    # LEF LVS output to lvs.lef.log, design.lvs.lef.log, design.lvs.lef.json, design.lvs.lef.log
    # GDS LVS output to lvs.gds.log, design.lvs.gds.log, design.lvs.gds.json, design.lvs.gds.log
    # GDS LVS uses STD_CELL_LIBRARY spice and
    # if defined, additional LVS_EXTRA_STD_CELL_LIBRARY spice and LVS_EXTRA_GATE_LEVEL_VERILOG files
    # Write Netlist
    puts_verbose "Starting LVS process..."
    if { $::env(LVS_INSERT_POWER_PINS) } {
        set netlist_name [index_file $::env(signoff_tmpfiles)/$::env(DESIGN_NAME).nl.v]
        set powered_netlist_name [index_file $::env(signoff_tmpfiles)/$::env(DESIGN_NAME).pnl.v]
        set powered_def_name [index_file $::env(signoff_tmpfiles)/$::env(DESIGN_NAME).p.def]

        write_powered_verilog\
            -output_nl $netlist_name\
            -output_pnl $powered_netlist_name\
            -output_def $powered_def_name
    }

    increment_index
    TIMER::timer_start
    if { [info exist ::env(MAGIC_EXT_USE_GDS)] && $::env(MAGIC_EXT_USE_GDS) } {
        set extract_type gds
    } else {
        set extract_type lef
    }
    set log [index_file $::env(signoff_logs)/lvs.$extract_type.log]
    puts_info "Running LVS (log: [relpath . $log])..."

    set schematic $::env(CURRENT_POWERED_NETLIST)
    set layout [subst $layout]

    set setup_file $::env(NETGEN_SETUP_FILE)
    set module_name $::env(DESIGN_NAME)
    #writes setup_file_*_lvs to tmp directory.
    set lvs_file_path [index_file $::env(signoff_tmpfiles)/setup_file.$extract_type.lvs]
    set lvs_file [open $lvs_file_path w]
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

    set extraction_prefix [index_file $::env(signoff_logs)/$::env(DESIGN_NAME).$extract_type.lvs]

    puts $lvs_file "lvs {$layout $module_name} {$schematic $module_name} $setup_file $extraction_prefix.log -json"
    close $lvs_file

    puts_verbose "$layout against $schematic"

    try_exec netgen -batch source $lvs_file_path \
        |& tee $::env(TERMINAL_OUTPUT) $log


    set count_lvs_rpt [index_file $::env(signoff_reports)/$::env(DESIGN_NAME).lvs.rpt]
    exec python3 $::env(SCRIPTS_DIR)/count_lvs.py \
        -f $extraction_prefix.json \
        |& tee $::env(TERMINAL_OUTPUT) $count_lvs_rpt

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "lvs - netgen"

    if { [info exists ::env(QUIT_ON_LVS_ERROR)] && $::env(QUIT_ON_LVS_ERROR) } {
        quit_on_lvs_error -rpt $count_lvs_rpt -log $log
    }
}

proc run_netgen {args} {
    handle_deprecated_command run_lvs
}

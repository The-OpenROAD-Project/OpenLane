proc run_dft {args} {
    if { $::env(DFT_ENABLE) } {
        increment_index
    }

    if { ! [info exists ::env(RESET_PORT) ] && $::env(DFT_ENABLE) } {
        if { ! [info exists ::env(CLOCK_PORT) ] } {
            puts_info "::env(CLOCK_PORT) is not set"
        }
        puts_info "::env(RESET_PORT) is not set"
        puts_warn "Skipping DFT"
        set ::env(DFT_ENABLE) 0
    }

    if { $::env(DFT_ENABLE) } {
        fault_chain \
            -verilog $::env(synthesis_results)/$::env(DESIGN_NAME).v \
            -liberty $::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_100C_1v80.lib \
            -clock $::env(CLOCK_PORT) \
            -reset $::env(RESET_PORT) \
            -output $::env(synthesis_results)/$::env(DESIGN_NAME).v
        
        increment_index

        fault_tap \
            -verilog $::env(synthesis_results)/$::env(DESIGN_NAME).v \
            -liberty $::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_100C_1v80.lib \
            -clock $::env(CLOCK_PORT) \
            -reset $::env(RESET_PORT) \
            -output $::env(synthesis_results)/$::env(DESIGN_NAME).v
    }
    
}


proc fault_chain {args} {
    puts_info "Running Scan Chain Insertion..."
    set options {
        {-verilog required}
        {-liberty required}
        {-clock required}
        {-reset required}
        {-output required}
    }
    parse_key_args "fault_chain" args values $options
    set tmp $::env(synthesis_tmpfiles)/$::env(DESIGN_NAME).v
    file copy -force $values(-verilog) $tmp
    
    try_catch $::env(DFT_BIN) chain \
        --liberty $values(-liberty) \
        --clock $values(-clock) \
        --reset $values(-reset) \
        --output $values(-output) \
        $values(-verilog)
}


proc fault_tap {args} {
    puts_info "Running JTAG Interface Insertion..."
    set options {
        {-verilog required}
        {-liberty required}
        {-clock required}
        {-reset required}
        {-output required}
    }
    parse_key_args "fault_tap" args values $options
    set tmp $::env(synthesis_tmpfiles)/$::env(DESIGN_NAME).v.chained.v
    file copy -force $values(-verilog) $tmp
    
    try_catch $::env(DFT_BIN) tap \
        --liberty $values(-liberty) \
        --clock $values(-clock) \
        --reset $values(-reset) \
        --output $values(-output) \
        $values(-verilog)
}
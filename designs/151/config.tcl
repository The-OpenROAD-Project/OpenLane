# User config
set ::env(DESIGN_NAME) riscv_top
set ::env(PDK_VARIANT) sky130_fd_sc_hd

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(OPENLANE_ROOT)/designs/151/src/*.v]
set ::env(CLOCK_PORT) "clk"

set filename $::env(OPENLANE_ROOT)/designs/151/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

# Design config
set ::env(CLOCK_PERIOD) 30
# Synthesis config
set ::env(SYNTH_STRATEGY) 1
# Floorplan config
set ::env(FP_CORE_UTIL) 0.4
# Placement config
set ::env(PL_TARGET_DENSITY) 0.3
# CTS config
# Routing config
set ::env(GLB_RT_ADJUSTMENT) 0
# Flow control config

# # threads for supporting tools
set ::env(ROUTING_CORES) 4

set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 1
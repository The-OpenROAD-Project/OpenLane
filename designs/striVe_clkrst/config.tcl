# User config
set ::env(DESIGN_NAME) striVe_clkrst

# Change if needed
set ::env(VERILOG_FILES) ./designs/striVe_clkrst/src/striVe_clkrst.v

# Fill this
set ::env(CLOCK_PERIOD) "50"
set ::env(CLOCK_PORT) "ext_clk"

set ::env(CLOCK_NET) "clk"
set ::env(RUN_SIMPLE_CTS) 0
set ::env(PL_INITIAL_PLACEMENT) 1
#set ::env(FP_CORE_UTIL) 35
set ::env(CLOCK_TREE_SYNTH) 0

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
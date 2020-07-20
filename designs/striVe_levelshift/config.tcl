
# User config
set ::env(DESIGN_NAME) striVe_levelshift

# Change if needed
set ::env(VERILOG_FILES) ./designs/striVe_levelshift/src/striVe_levelshift.v

# Fill this
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "SCK"


set ::env(CLOCK_NET) $::env(CLOCK_PORT)
set ::env(PDN_CFG) ./designs/striVe_levelshift/pdn.tcl

set ::env(FP_CORE_UTIL) 80
set ::env(RUN_MAGIC) 1
set ::env(RUN_SIMPLE_CTS) 0
set ::env(FILL_INSERTION) 0
set ::env(SYNTH_BUFFERING) 0

set ::env(PLACE_SITE) unithv_double

set ::env(CLOCK_TREE_SYNTH) 0

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
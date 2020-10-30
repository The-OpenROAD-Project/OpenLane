# 
# OPENLANE CONFIGURATION FILE
#

# User config
set ::env(DESIGN_NAME) fpga_250
set ::env(PDK_VARIANT) sky130_fd_sc_hd

set design_root $::env(OPENLANE_ROOT)/designs
set src_root $design_root/250

set fabric_src $src_root/src

set mac_top mac_cluster
set mac_run {cluster_750_750_0.3}
set mac_src $src_root/mac_team/src
set mac_design_root $design_root/250_mac
set mac_lef $mac_design_root/runs/$mac_run/results/magic/$mac_top.lef
set mac_gds $mac_design_root/runs/$mac_run/results/magic/$mac_top.gds
puts "MACRO PATH $mac_lef"
puts "MACRO PATH $mac_gds"
set ::env(MAC_TOP) $mac_top

# Verilog files for top level RTL connections. Do not include black boxes!
set ::env(VERILOG_FILES) [concat \
    [glob $fabric_src/*.v]]

# Include black boxes!
set ::env(VERILOG_FILES_BLACKBOX) [concat \
    [glob $mac_src/*.v]]

set ::env(SYNTH_READ_BLACKBOX_LIB) 1

set ::env(EXTRA_LEFS) [list $mac_lef]
set ::env(EXTRA_GDS_FILES) [list $mac_gds]

# set ::set(SYNTH_FLAT_TOP) 1

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_TREE_SYNTH) 0

set filename $::env(OPENLANE_ROOT)/designs/250/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) {0 0 10000 10000}

# Design config
set ::env(CLOCK_PERIOD) 30
# Synthesis config
set ::env(SYNTH_STRATEGY) 1
# Floorplan config
set ::env(FP_CORE_UTIL) 1
# Placement config
#set ::env(PL_TARGET_DENSITY) 0.05
# CTS config
# Routing config
set ::env(ROUTING_STRATEGY) 14 ;# run TritonRoute14
set ::env(GLB_RT_ADJUSTMENT) 0
# Flow control config

# # threads for supporting tools
set ::env(ROUTING_CORES) 4

# TODO(aryap): Enable this once the format is clear
# set ::env(FP_PIN_ORDER_CFG) $fabric_src/pin_order.cfg

set ::env(PDN_CFG) $fabric_src/pdn.tcl

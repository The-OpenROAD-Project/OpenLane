# Process node
set ::env(PROCESS) 130
set ::env(DEF_UNITS_PER_MICRON) 1000


# Placement site for core cells
# This can be found in the technology lef

set ::env(VDD_PIN) "vpwr"
set ::env(GND_PIN) "vgnd"

# Track information for generating DEF tracks
set ::env(TRACKS_INFO_FILE) "$::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(PDK_VARIANT)/tracks.info"


# Technology LEF
set ::env(TECH_LEF) "$::env(PDK_ROOT)/$::env(PDK)/libs.ref/techLEF/$::env(PDK_VARIANT)/$::env(PDK_VARIANT)_tech.lef"
set ::env(CELLS_LEF) [glob "$::env(PDK_ROOT)/$::env(PDK)/libraries/$::env(PDK_VARIANT)/latest/cells/*/*.magic.lef"]
set ::env(MAGIC_TECH_FILE) "$::env(PDK_ROOT)/$::env(PDK)/libs.tech/magic/current/sky130.tech"
#set ::env(GPIO_PADS_LEF) [glob "$::env(PDK_ROOT)/$::env(PDK)/libs.ref/lef/s8iom0s8/routing_abstract/*.lef"]

# netgen setup
set ::env(NETGEN_SETUP_FILE) $::env(PDK_ROOT)/$::env(PDK)/libs.tech/netgen/$::env(PDK)_setup.tcl
# CTS luts
set ::env(CTS_TECH_DIR) "N/A"

set ::env(FP_TAPCELL_DIST) 14


set ::env(GLB_RT_L1_ADJUSTMENT) 0.99

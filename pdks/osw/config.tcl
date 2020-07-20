# Process node
set ::env(PROCESS) 130
set ::env(DEF_UNITS_PER_MACRON) 1000
#
# Placement site for core cells
# This can be found in the technology lef
set ::env(PLACE_SITE) "unitehd"
set ::env(PLACE_SITE_WIDTH) 0.460
set ::env(PLACE_SITE_HEIGHT) 3.400

set ::env(VDD_PIN) "vpwr"
set ::env(GND_PIN) "vgnd"

# Track information for generating DEF tracks
set ::env(TRACKS_INFO_FILE) "$::env(OPENLANE_ROOT)/pdks/$::env(PDK)/common_tracks.info"

# Technology lef
# Cells, layers, vias, and sites all mereged together in one lef
set ::env(TECH_LEF) "$::env(OPENLANE_ROOT)/pdks/$::env(PDK)/techLEF/tech.lef"
set ::env(CELLS_LEF) "$::env(OPENLANE_ROOT)/pdks/$::env(PDK)/$::env(PDK_VARIANT)/lef/cells.lef"
set ::env(GPIO_PADS_LEF) [glob "$::env(OPENLANE_ROOT)/pdks/$::env(PDK)/efs8_pads/lef/*.lef"]

set ::env(MAGIC_TECH_FILE) "$::env(OPENLANE_ROOT)/pdks/$::env(PDK)/common_magic.tech"

# GDSII
set ::env(GDS_FILES) [glob $::env(OPENLANE_ROOT)/pdks/$::env(PDK)/$::env(PDK_VARIANT)/gds/*.gds]

# CTS luts
set ::env(CTS_TECH_DIR) "$::env(OPENLANE_ROOT)/pdks/$::env(PDK)/cts_lut_common/"

set ::env(FP_TAPCELL_DIST) 25

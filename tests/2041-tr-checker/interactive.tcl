package require openlane;

prep -design $::env(TEST_DIR) {*}$argv

set ::env(IO_READ_DEF) 1
set ::env(CURRENT_DEF) $::env(DESIGN_DIR)/in.def
set ::env(CURRENT_GUIDE) $::env(DESIGN_DIR)/in.guide

set save_odb $::env(DESIGN_DIR)/out.odb
detailed_routing
quit_on_tr_drc

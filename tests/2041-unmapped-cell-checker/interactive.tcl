package require openlane;

prep -design $::env(TEST_DIR) {*}$argv
check_unmapped_cells $::env(TEST_DIR)/1-synthesis_pre.stat

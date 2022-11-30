package require openlane;

prep -design $::env(TEST_DIR) {*}$argv

run_post_run_hooks
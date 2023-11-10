package require openlane;

prep -design $::env(TEST_DIR) {*}$argv

try_exec echo {
    read_lef $::env(MERGED_LEF)
    read_def $::env(DESIGN_DIR)/in.def
    write_db $::env(DESIGN_DIR)/in.odb
} | openroad -exit

set ::env(CURRENT_ODB) $::env(DESIGN_DIR)/in.odb

insert_buffer\
    -at_pin _0_/A\
    -buffer_cell sky130_fd_sc_hd__dlygate4sd3_1\
    -net_name inserted_net\
    -inst_name inserted_buffer

exec cp $::env(CURRENT_ODB) $::env(DESIGN_DIR)/out.odb

run_post_run_hooks

puts_info "Done."

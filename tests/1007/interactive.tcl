package require openlane;

prep -design tests/1007

set ::env(CURRENT_DEF) $::env(DESIGN_DIR)/in.def

insert_buffer\
    -at_pin _0_/A\
    -buffer_cell sky130_fd_sc_hd__dlygate4sd3_1\
    -net_name inserted_net\
    -inst_name inserted_buffer

exec cp $::env(CURRENT_DEF) $::env(DESIGN_DIR)/out.def

exec $::env(OPENROAD_BIN) -python $::env(DESIGN_DIR)/hooks/post_run.py

puts_info "Done."
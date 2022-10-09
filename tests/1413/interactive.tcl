package require openlane;

prep -design $::env(TEST_DIR)

set ::env(CURRENT_ODB) $::env(DESIGN_DIR)/in.odb

set save_odb $::env(DESIGN_DIR)/out.odb

# Remove pins first: nets cannot be removed if they are associated with a pin
remove_components -input $::env(CURRENT_ODB) -output $save_odb
remove_pins -input $save_odb
remove_nets -rx {^in$} -input $save_odb

set ::env(CURRENT_ODB) $save_odb

exec $::env(OPENROAD_BIN) -python $::env(DESIGN_DIR)/hooks/post_run.py

puts_info "Done."
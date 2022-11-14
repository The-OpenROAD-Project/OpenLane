package require openlane;

prep -design $::env(TEST_DIR) {*}$argv

try_catch echo {
    read_lef $::env(MERGED_LEF)
    read_def $::env(DESIGN_DIR)/../1413/in.def
    write_db $::env(DESIGN_DIR)/in.odb
} | openroad -exit

set ::env(CURRENT_ODB) $::env(DESIGN_DIR)/in.odb

set save_odb $::env(DESIGN_DIR)/out.odb

# Remove pins first: nets cannot be removed if they are associated with a pin
remove_components -input $::env(CURRENT_ODB) -output $save_odb
remove_pins -input $save_odb
remove_nets -rx {^in$} -input $save_odb

set ::env(CURRENT_ODB) $save_odb

try_catch $::env(OPENROAD_BIN) -exit -no_init -python $::env(DESIGN_DIR)/hooks/post_run.py

puts_info "Done."
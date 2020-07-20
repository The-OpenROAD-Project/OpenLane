package require openlane
prep -design striVe_soc_oram -tag hardened -overwrite

#config
set lefs 	 [glob $::env(DESIGN_DIR)/src/lef/*.lef]

#
add_lefs -src $lefs
run_synthesis
init_floorplan_or
place_io
global_placement_or
detailed_placement
try_catch $::env(SCRIPTS_DIR)/mark_component_fixed.sh "sram_1rw1r_32_256_8_s8" $::env(CURRENT_DEF)
tap_decap_or
detailed_placement
gen_pdn
run_routing
run_magic_drc
run_magic

package require openlane

prep -design striVe_levelshift -tag final -overwrite
run_synthesis

#floorplan
init_floorplan
place_io
set only_special_nets $::env(CURRENT_DEF)_special_nets_only
exec cp $::env(CURRENT_DEF) $only_special_nets

gen_pdn

exec $::env(SCRIPTS_DIR)/append_special_nets.py --source $::env(CURRENT_DEF) --destination $only_special_nets
set_def $only_special_nets
#
#exec $::env(SCRIPTS_DIR)/append_special_nets.py --source $::env(CURRENT_DEF) --destination $only_special_nets
#set_def $only_special_nets
#placement
run_placement

#routing
run_routing

run_magic

package require openlane
set script_dir [file dirname [file normalize [info script]]]
set design_name fpga_250
prep -design $script_dir -tag $design_name -run_path $script_dir/runs -overwrite
set save_path $script_path/save

#set lefs $::env(EXTRA_LEFS)
add_lefs -src /openLANE_flow/designs/250_mac/runs/cluster_750_750_0.3/results/magic/mac_cluster.lef

run_synthesis

# Doesn't work
#init_floorplan_or
#place_io
#global_placement_or

# 
init_floorplan
place_io
global_placement_or

add_macro_placement my_mac 5 5
manual_macro_placement
detailed_placement

puts "current def is $::env(CURRENT_DEF)"
try_catch $::env(SCRIPTS_DIR)/mark_component_fixed.sh my_macro $::env(CURRENT_DEF)

tap_decap_or
detailed_placement

gen_pdn
run_routing

if { $::env(DIODE_INSERTION_STRATEGY) == 2 } {
    run_magic_antenna_check; # produces a report of violators; extraction!
    heal_antenna_violators; # modifies the routed DEF
}

run_magic
save_views      -lef_path $::env(magic_result_file_tag).lef \
                -def_path $::env(tritonRoute_result_file_tag).def \
                -gds_path $::env(magic_result_file_tag).gds \
                -mag_path $::env(magic_result_file_tag).mag \
                -save_path $save_path \
                -tag $::env(RUN_TAG)

run_magic_drc
run_magic_spice_export
run_lvs
run_antenna_check

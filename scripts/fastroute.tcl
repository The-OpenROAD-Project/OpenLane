fr_import_lef "${MERGED_LEF_UNPADDED}"
fr_import_def "${CURRENT_DEF}" 
set_output_file "${fastroute_tmp_file_tag}.guide"
set_capacity_adjustment ${GLB_RT_ADJUSTMENT}
set_min_layer ${GLB_RT_MINLAYER}
set_max_layer ${GLB_RT_MAXLAYER}
set_layer_adjustment 1 ${GLB_RT_L1_ADJUSTMENT}
set_layer_adjustment 2 ${GLB_RT_L2_ADJUSTMENT}
set_unidirectional_routing true
set_pitches_in_tile ${GLB_RT_TILES}


start_fastroute
run_fastroute
write_guides

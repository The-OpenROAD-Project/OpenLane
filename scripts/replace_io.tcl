replace_external rep

rep set_verbose_level 3
# rep set_plot_enable true
rep set_density $::env(PL_TARGET_DENSITY)

rep import_lef $::env(MERGED_LEF)
rep import_def $::env(tapcell_result_file_tag).def
rep set_output $::env(replaceio_tmp_file_tag)

# rep set_timing_driven true
# rep import_lib $::env(LIB_FILE)
# rep import_sdc $::env(RESULTS_DIR)/synthesis/1_synth.sdc
# rep import_verilog $::env(RESULTS_DIR)/synthesis/1_synthesis.v

rep set_fast_mode_enable true
rep init_replace
rep place_cell_nesterov_place
# rep print_instances

rep export_def $::env(replaceio_tmp_file_tag)_io.def

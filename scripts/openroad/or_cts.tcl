if {[catch {read_lef $::env(MERGED_LEF_UNPADDED)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

read_lib $::env(LIB_SYNTH_COMPLETE)

if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

read_verilog $::env(yosys_result_file_tag).v
read_sdc $::env(SCRIPTS_DIR)/base.sdc

clock_tree_synthesis\
    -max_slew $::env(SYNTH_MAX_TRAN)\
    -max_cap $::env(CTS_MAX_CAP)\
    -buf_list $::env(CTS_CLK_BUFFER_LIST)\
    -sqr_cap $::env(CTS_SQR_CAP)\
    -sqr_res $::env(CTS_SQR_RES)\
    -root_buf $::env(CTS_ROOT_BUFFER)

write_def $::env(SAVE_DEF)
write_verilog $::env(yosys_result_file_tag)_cts.v

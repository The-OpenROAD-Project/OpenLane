read_lef $::env(MERGED_LEF_UNPADDED)
read_def $::env(CURRENT_DEF)

tapcell\
    -halo_width_x 5\
    -halo_width_y 5\
    -endcap_cpp "1"\
    -distance $::env(FP_TAPCELL_DIST)\
    -tapcell_master "$::env(FP_WELLTAP_CELL)"\
    -endcap_master "$::env(FP_ENDCAP_CELL)"

write_def $::env(SAVE_DEF)

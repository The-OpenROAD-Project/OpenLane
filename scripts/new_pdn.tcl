read_lef $::env(MERGED_LEF_UNPADDED)
read_def $::env(CURRENT_DEF)

pdngen $::env(PDN_CFG) -verbose

write_def $::env(pdn_tmp_file_tag).def

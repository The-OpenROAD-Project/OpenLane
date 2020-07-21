read_lef $::env(MERGED_LEF_UNPADDED)
read_def $::env(CURRENT_DEF)


if {[catch {pdngen $::env(PDN_CFG) -verbose} errmsg]} {
    puts stderr $errmsg
    exit 1
}

write_def $::env(pdn_tmp_file_tag).def

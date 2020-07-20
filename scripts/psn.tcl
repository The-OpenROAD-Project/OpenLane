import_lef $::env(MERGED_LEF)
import_def $::env(replaceio_tmp_file_tag).def
import_lib $::env(LIB_SYNTH)

export_def $::env(psn_tmp_file_tag).def
exit 0

set magicrc $::env(TMP_DIR)/magic_drc.magicrc
set ::env(PDKPATH) "$::env(PDK_ROOT)/$::env(PDK)"
# the following MAGTYPE has to be maglef for the purpose of DRC checking
set ::env(MAGTYPE) maglef
set ::env(MAGPATH) "$::env(PDKPATH)/libs.ref/$::env(MAGTYPE)"
exec envsubst < $::env(MAGIC_MAGICRC) > $magicrc
exec magic \
        -noconsole \
        -dnull \
        -rcfile $magicrc \
        $::env(SCRIPTS_DIR)/magic_drc.tcl \
	</dev/null \
        |& tee $::env(TERMINAL_OUTPUT) $::env(magic_log_file_tag).drc.log

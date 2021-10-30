proc run_eco {args} {
    set eco_iter 0
    set eco_finish 0

    while {$eco_finish != 0} {
        # Run tcl to fix timing
        incr eco_iter

	# Read fix reports
	set path [list $::env(LOG_DIR) eco report]
	append path $eco_iter

        set fp   [open  $path r]	
	set fd   [read  $fp]
	set txt  [split $fd "\n"]

        foreach line in $txt{
	    if {[regexp {no errors} $fp]} {
                set eco_finish 1
            }
            else {
                # Run fix timing script (again)         
            }	
        }
	close $fp
    }

}

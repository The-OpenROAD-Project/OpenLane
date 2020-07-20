#source /openLANE_flow/scripts/magic.tcl
if { $argc < 7 } {
    puts "The magic_gds_to_lef.tcl script requires 4 flags and 2 arguments to be inputed: the directory and the gds file prefix."
    puts "tclsh magic_gds_to_lef.tcl /home/user/designs/runs/todayRun/ spm"
    puts "Please try again."
} else {
    cd [lindex $argv 6]
    gds read [lindex $argv 7].gds                                     
    load [lindex $argv 7]                                             
    select top cell           
    cd [lindex $argv 8]                                                                         
    lef write [lindex $argv 9].lef -hide
}

exit


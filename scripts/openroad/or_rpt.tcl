# This script generates reports for parsing purposes
# Only serves as a placeholder

if {[catch {read_lef $::env(MERGED_LEF_UNPADDED)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

if { $::env(CURRENT_DEF) != 0 } {
    if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
        puts stderr $errmsg
        exit 1
    }
}

set_cmd_units -time ns -capacitance pF -current mA -voltage V -resistance kOhm -distance um

define_corners tt
read_liberty -corner tt $::env(LIB_SYNTH_COMPLETE)

# Read Verilog and link design
read_verilog $::env(CURRENT_NETLIST)
link_design $::env(DESIGN_NAME)

# Read SPEF and SDC
if { [info exists ::env(SPEF_TYPICAL)] } {
    read_spef -corner tt $::env(SPEF_TYPICAL)
}

read_sdc -echo $::env(CURRENT_SDC)

report_checks -path_delay max

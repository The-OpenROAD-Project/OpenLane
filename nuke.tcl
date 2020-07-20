#!/usr/bin/tclsh8.5
source ./scripts/utils/utils.tcl

puts_warn "\[WARN\]: DELETING ALL DESIGN RUNS!"
exec rm -rf {*}[glob designs/*/runs]
puts_success "\[SUCCESS\]: ALL DESIGN RUNS ARE DELETED!"

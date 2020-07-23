#!/usr/bin/tclsh8.5
set ::env(OPENLANE_ROOT) [file dirname [file normalize [info script]]]
lappend ::auto_path "$::env(OPENLANE_ROOT)/scripts/"

package require openlane_utils

puts_warn "DELETING ALL DESIGN RUNS!"

if { ! [catch {glob designs/*/runs} runs] } {
	file delete -force  {*}$runs
	puts_success "ALL DESIGN RUNS ARE DELETED!"
} else {
	puts_info "No runs to delete"
}

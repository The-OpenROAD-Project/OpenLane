# Copyright 2022 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source $::env(SCRIPTS_DIR)/openroad/common/set_global_connections.tcl

proc is_blackbox {file_path blackbox_wildcard} {
    set not_found [catch { exec bash -c "grep '$blackbox_wildcard' $file_path" }]
    return [expr !$not_found]
}

proc string_in_file {file_path substring} {
    set f [open $file_path r]
    set data [read $f]
    close $f

    if { [string first $substring $data] != -1} {
        return 1
    }
    return 0
}

proc env_var_used {file var} {
    return [string_in_file $file "\$::env($var)"]
}

proc read_current_sdc {} {
    if { ![info exists ::env(CURRENT_SDC)]} {
        puts "\[INFO] CURRENT_SDC not found. Not reading an SDC file."
        return
    }

    set ::env(SYNTH_MAX_FANOUT) $::env(MAX_FANOUT_CONSTRAINT)
    set ::env(SYNTH_CAP_LOAD) $::env(OUTPUT_CAP_LOAD)
    if { [info exists ::env(MAX_TRANSITION_CONSTRAINT)] } {
        set ::env(SYNTH_MAX_TRAN) $::env(MAX_TRANSITION_CONSTRAINT)
    }

    puts "Reading design constraints file at '$::env(CURRENT_SDC)'…"
    if {[catch {read_sdc $::env(CURRENT_SDC)} errmsg]} {
        puts stderr $errmsg
        exit 1
    }
}


proc read_netlist {args} {
    sta::parse_key_args "read_netlists" args \
        keys {}\
        flags {-powered -all}

    set netlist $::env(CURRENT_NETLIST)
    if { [info exists flags(-powered)] } {
        set netlist $::env(CURRENT_POWERED_NETLIST)
    }

    puts "Reading netlist '$netlist'…"

    if {[catch {read_verilog $netlist} errmsg]} {
        puts stderr $errmsg
        exit 1
    }

    if { [info exists flags(-all)] } {
        set blackbox_wildcard {/// sta-blackbox}
        if { [info exists ::env(VERILOG_FILES_BLACKBOX)] } {
            foreach verilog_file $::env(VERILOG_FILES_BLACKBOX) {
                if { [is_blackbox $verilog_file $blackbox_wildcard] } {
                    puts "Found '$blackbox_wildcard' in '$verilog_file', skipping…"
                } elseif { [catch {read_verilog $verilog_file} err] } {
                    puts "Error while reading $verilog_file:"
                    puts "Make sure that this a gate-level netlist not an RTL file"
                    puts "You can add the following comment '$blackbox_wildcard' in the file to skip it and blackbox the modules inside if needed."
                    puts $err
                    exit 1
                }
            }
        }
    }

    link_design $::env(DESIGN_NAME)

    if { [info exists ::env(CURRENT_SDC)] } {
        read_current_sdc
    }

}


proc print_units {args} {
    foreach {unit} {
        capacitance
        resistance
        time
        voltage
        current
        power
        distance
    } {
        set scale [sta::unit_scale $unit]
        puts "Using [format %.0e $scale] for $unit..."
    }
}

proc read_libs {args} {
    sta::parse_key_args "read_libs" args \
        keys {-typical -slowest -fastest}\
        flags {-no_extra}

    if { ![info exists keys(-typical)] } {
        puts "read_libs -typical is required"
        exit 1
    }
    if { [info exists keys(-slowest)] } {
        set corner(Slowest) $keys(-slowest)
    }
    if { [info exists keys(-fastest)] } {
        set corner(Fastest) $keys(-fastest)
    }
    set corner(Typical) $keys(-typical)
    puts "define_corners [array name corner]"
    define_corners {*}[array name corner]

    foreach corner_name [array name corner] {
        foreach lib $corner($corner_name) {
            puts "read_liberty -corner $corner_name $lib"
            read_liberty -corner $corner_name $lib
        }
        if { ![info exists flags(-no_extra)] } {
            if { [info exists ::env(EXTRA_LIBS) ] } {
                foreach lib $::env(EXTRA_LIBS) {
                    puts "read_liberty -corner $corner_name $lib"
                    read_liberty -corner $corner_name $lib
                }
            }
        }
    }

    print_units
}

proc read {args} {
    sta::parse_key_args "read" args \
        keys {-lib_fastest -lib_typical -lib_slowest} \
        flags {-no_spefs}

    if { [info exists ::env(IO_READ_DEF)] && $::env(IO_READ_DEF) } {
        if { [ catch {read_lef $::env(MERGED_LEF)} errmsg ]} {
            puts stderr $errmsg
            exit 1
        }
        if { [ catch {read_def $::env(CURRENT_DEF)} errmsg ]} {
            puts stderr $errmsg
            exit 1
        }
    } else {
        puts "\[INFO\]: Reading ODB at '$::env(CURRENT_ODB)'…"
        if { [ catch {read_db $::env(CURRENT_ODB)} errmsg ]} {
            puts stderr $errmsg
            exit 1
        }
    }

    set read_libs_args [list]

    if { [info exists keys(-lib_typical)]} {
        lappend read_libs_args -typical "$keys(-lib_typical)"
    } else {
        lappend read_libs_args -typical "$::env(LIB_TYPICAL)"
    }

    if { [info exists keys(-lib_fastest)] } {
        lappend read_libs_args -fastest "$keys(-lib_fastest)"
    }
    if { [info exists keys(-lib_slowest)] } {
        lappend read_libs_args -slowest "$keys(-lib_slowest)"
    }

    read_libs {*}$read_libs_args

    if { [info exists ::env(CURRENT_SDC)] } {
        read_current_sdc
    }

    if { ![info exist flags(-no_spefs)] } {
        if { [info exists ::env(CURRENT_SPEF)] } {
            if {[catch {read_spef $::env(CURRENT_SPEF)} errmsg]} {
                puts stderr $errmsg
                exit 1
            }
        }
    }
}

proc write {args} {
    # This script will attempt to write views based on existing "SAVE_"
    # environment variables. If the SAVE_ variable exists, the script will
    # attempt to write a corresponding view to the specified location.
    sta::parse_key_args "write" args \
        keys {}\
        flags {-no_global_connect}

    if { [info exists ::env(VDD_NET)] \
        && ![info exist flags(-no_global_connect)] } {
        puts "Setting global connections for newly added cells…"
        set_global_connections
    }

    if { [info exists ::env(SAVE_ODB)] } {
        puts "Writing OpenROAD database to '$::env(SAVE_ODB)'…"
        write_db $::env(SAVE_ODB)
    } else {
        puts "\[WARNING\] Did not save OpenROAD database!"
    }

    if { [info exists ::env(SAVE_NETLIST)] } {
        puts "Writing netlist to '$::env(SAVE_NETLIST)'…"
        write_verilog $::env(SAVE_NETLIST)
    }

    if { [info exists ::env(SAVE_POWERED_NETLIST)] } {
        puts "Writing powered netlist to '$::env(SAVE_POWERED_NETLIST)'…"
        write_verilog -include_pwr_gnd $::env(SAVE_POWERED_NETLIST)
    }

    if { [info exists ::env(SAVE_DEF)] } {
        puts "Writing layout to '$::env(SAVE_DEF)'…"
        write_def $::env(SAVE_DEF)
    }

    if { [info exists ::env(SAVE_SDC)] } {
        puts "Writing timing constraints to '$::env(SAVE_SDC)'…"
        write_sdc $::env(SAVE_SDC)
    }

    if { [info exists ::env(SAVE_SPEF)] } {
        puts "Writing extracted parasitics to '$::env(SAVE_SPEF)'…"
        write_spef $::env(SAVE_SPEF)
    }

    if { [info exists ::env(SAVE_GUIDE)] } {
        puts "Writing routing guides to '$::env(SAVE_GUIDE)'…"
        write_guides $::env(SAVE_GUIDE)
    }

    if { [info exists ::env(SAVE_SDF)] } {
        set corners [sta::corners]
        if { [llength $corners] > 1 } {
            puts "Writing SDF files for all corners…"
            set prefix [file rootname $::env(SAVE_SDF)]
            foreach corner $corners {
                set corner_name [$corner name]
                set target $prefix.$corner_name.sdf
                puts "Writing SDF for the $corner_name corner to $target…"
                write_sdf -include_typ -divider . -corner $corner_name $target
            }
        } else {
            puts "Writing SDF to '$::env(SAVE_SDF)'…"
            write_sdf -include_typ -divider . $::env(SAVE_SDF)
        }
    }

    if { [info exists ::env(SAVE_LIB)] && !$::env(STA_PRE_CTS)} {
        set corners [sta::corners]
        if { [llength $corners] > 1 } {
            puts "Writing timing models for all corners…"
            set prefix [file rootname $::env(SAVE_LIB)]
            foreach corner $corners {
                set corner_name [$corner name]
                set target $prefix.$corner_name.lib
                puts "Writing timing models for the $corner_name corner to $target…"
                write_timing_model -corner $corner_name $target
            }
        } else {
            puts "Writing timing model to '$::env(SAVE_LIB)'…"
            write_timing_model $::env(SAVE_LIB)
        }
    }
}


proc read_spefs {} {
    set corners [sta::corners]
    if { [info exists ::env(CURRENT_SPEF)] } {
        foreach corner $corners {
            read_spef -corner [$corner name] $::env(CURRENT_SPEF)
        }
    }

    if { [info exists ::env(EXTRA_SPEFS)] } {
        foreach {module_name spef_file_min spef_file_nom spef_file_max} "$::env(EXTRA_SPEFS)" {
            set matched 0
            foreach cell [get_cells * -hierarchical] {
                if { "[get_property $cell ref_name]" eq "$module_name"} {
                    puts "Matched [get_property $cell full_name] with $module_name"
                    set matched 1
                    foreach corner $corners {
                        if { $::env(PROCESS_CORNER) eq "nom" } {
                            read_spef -path [get_property $cell full_name] -corner [$corner name] $spef_file_nom
                        } elseif { $::env(PROCESS_CORNER) eq "min" } {
                            read_spef -path [get_property $cell full_name] -corner [$corner name] $spef_file_min
                        } elseif { $::env(PROCESS_CORNER) eq "max" } {
                            read_spef -path [get_property $cell full_name] -corner [$corner name] $spef_file_max
                        }
                    }
                }
            }
            if { $matched != 1 } {
                puts "Error: Module $module_name specified in EXTRA_SPEFS not found."
                exit 1
            }
        }
    }
}

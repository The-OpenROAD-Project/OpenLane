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

proc read_netlist {args} {
    puts "Reading netlist..."

    if {[catch {read_verilog $::env(CURRENT_NETLIST)} errmsg]} {
        puts stderr $errmsg
        exit 1
    }

    link_design $::env(DESIGN_NAME)

    if { [info exists ::env(CURRENT_SDC)] } {
        if {[catch {read_sdc $::env(CURRENT_SDC)} errmsg]} {
            puts stderr $errmsg
            exit 1
        }
    }

}

proc read_libs {args} {
    sta::parse_key_args "read_libs" args \
        keys {-override}\
        flags {-multi_corner}

    set libs $::env(LIB_SYNTH_COMPLETE)

    if { [info exists keys(-override)] } {
        set libs $keys(-override)
    }

    if { [info exists flags(-multi_corner)] } {
        # Note that the one defined first is the "default": meaning you
        # shouldn't use -multi_corner for scripts that do not explicitly
        # specify the corners for STA calls.
        define_corners ss tt ff;

        foreach lib $::env(LIB_SLOWEST) {
            read_liberty -corner ss $lib
        }
        foreach lib $::env(LIB_TYPICAL) {
            read_liberty -corner tt $lib
        }
        foreach lib $::env(LIB_FASTEST) {
            read_liberty -corner ff $lib
        }

        foreach corner {ss tt ff} {
            if { [info exists ::env(EXTRA_LIBS) ] } {
                foreach lib $::env(EXTRA_LIBS) {
                    read_liberty -corner $corner $lib
                }
            }
        }
    } else {
        foreach lib $libs {
            read_liberty $lib
        }

        if { [info exists ::env(EXTRA_LIBS) ] } {
            foreach lib $::env(EXTRA_LIBS) {
                read_liberty $lib
            }
        }

    }
}

proc read {args} {
    sta::parse_key_args "read" args \
        keys {-override_libs}\
        flags {-multi_corner_libs}

    if {[catch {read_db $::env(CURRENT_ODB)} errmsg]} {
        puts stderr $errmsg
        exit 1
    }

    set read_libs_args [list]

    if { [info exists keys(-override_libs)]} {
        lappend read_libs_args -override $keys(-override_libs)
    }

    if { [info exists flags(-multi_corner_libs)] } {
        lappend read_libs_args -multi_corner
    }

    read_libs {*}$read_libs_args

    if { [info exists ::env(CURRENT_SDC)] } {
        if {[catch {read_sdc $::env(CURRENT_SDC)} errmsg]} {
            puts stderr $errmsg
            exit 1
        }
    }
}

proc write {args} {
    # This script will attempt to write views based on existing "SAVE_"
    # environment variables. If the SAVE_ variable exists, the script will
    # attempt to write a corresponding view to the specified location.
    sta::parse_key_args "write" args \
        keys {}\
        flags {}

    if { [info exists ::env(VDD_NET)] } {
        puts "Setting global connections for newly added cells..."
        set_global_connections
    }

    if { [info exists ::env(SAVE_ODB)] } {
        puts "Writing OpenROAD database to $::env(SAVE_ODB)..."
        write_db $::env(SAVE_ODB)
    } else {
        puts "\[WARNING\] Did not save OpenROAD database!"
    }

    if { [info exists ::env(SAVE_NETLIST)] } {
        puts "Writing netlist to $::env(SAVE_NETLIST)..."
        write_verilog $::env(SAVE_NETLIST)
    }

    if { [info exists ::env(SAVE_POWERED_NETLIST)] } {
        puts "Writing powered netlist to $::env(SAVE_POWERED_NETLIST)..."
        write_verilog -include_pwr_gnd $::env(SAVE_POWERED_NETLIST)
    }

    if { [info exists ::env(SAVE_DEF)] } {
        puts "Writing layout to $::env(SAVE_DEF)..."
        write_def $::env(SAVE_DEF)
    }

    if { [info exists ::env(SAVE_SDC)] } {
        puts "Writing timing constraints to $::env(SAVE_SDC)..."
        write_sdc $::env(SAVE_SDC)
    }

    if { [info exists ::env(SAVE_SPEF)] } {
        puts "Writing extracted parasitics to $::env(SAVE_SPEF)..."
        write_spef $::env(SAVE_SPEF)
    }

    if { [info exists ::env(SAVE_GUIDE)] } {
        puts "Writing routing guides to $::env(SAVE_GUIDE)..."
        write_guides $::env(SAVE_GUIDE)
    }

    if { [info exists ::env(SAVE_SDF)] } {
        set corners [sta::corners]
        if { [llength $corners] > 1 } {
            puts "Writing SDF files for all corners..."
            set prefix [file rootname $::env(SAVE_SDF)]
            foreach corner $corners {
                set corner_name [$corner name]
                set target $prefix.$corner_name.sdf
                puts "Writing SDF for the $corner_name corner to $target..."
                write_sdf -include_typ -divider . -corner $corner_name $target
            }
        } else {
            puts "Writing SDF to $::env(SAVE_SDF)..."
            write_sdf -include_typ -divider . $::env(SAVE_SDF)
        }
    }

    if { [info exists ::env(SAVE_LIB)] && !$::env(STA_PRE_CTS)} {
        set corners [sta::corners]
        if { [llength $corners] > 1 } {
            puts "Writing timing models for all corners..."
            set prefix [file rootname $::env(SAVE_LIB)]
            foreach corner $corners {
                set corner_name [$corner name]
                set target $prefix.$corner_name.lib
                puts "Writing timing models for the $corner_name corner to $target..."
                write_timing_model -corner $corner_name $target
            }
        } else {
            puts "Writing timing model to $::env(SAVE_LIB)..."
            write_timing_model $::env(SAVE_LIB)
        }
    }
}

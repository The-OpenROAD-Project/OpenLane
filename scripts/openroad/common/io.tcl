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

proc read {args} {
    # This script will attempt to read all existing inputs, namely:
    #   * Lib (Single or Multicorner)
    #   * LEF
    #   * DEF (if it exists)
    #   * Verilog (if no def)
    #   * SDC

    sta::parse_key_args "read" args \
        keys {-override_libs -override_lef}\
        flags {-multi_corner}

    if { [info exists flags(-multi_corner)] } {
        define_corners ss tt ff

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
        set used_libs $::env(LIB_SYNTH_COMPLETE)
        if { [info exists keys(-override_libs)] } {
            set used_libs $keys(-override_libs)
        }

        foreach lib $used_libs {
            read_liberty $lib
        }

        if { [info exists ::env(EXTRA_LIBS)] } {
            foreach lib $::env(EXTRA_LIBS) {
                read_liberty $lib
            }
        }
    }

    set used_lef $::env(MERGED_LEF)
    if { [info exists keys(-override_lef)] } {
        set used_lef $keys(-override_lef)
    }

    if {[catch {read_lef $used_lef} errmsg]} {
        puts stderr $errmsg
        exit 1
    }

    if { $::env(CURRENT_DEF) == 0 } {
        if {[catch {read_verilog $::env(CURRENT_NETLIST)} errmsg]} {
            puts stderr $errmsg
            exit 1
        }
        link_design $::env(DESIGN_NAME)
    } else {
        if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
            puts stderr $errmsg
            exit 1
        }
    }

    if { [info exists ::env(CURRENT_SDC)] } {
        if {[catch {read_sdc -echo $::env(CURRENT_SDC)}]} {
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
        puts "Writing SDF to $::env(SAVE_SDF)..."
        write_sdf $::env(SAVE_SDF)
    }
}
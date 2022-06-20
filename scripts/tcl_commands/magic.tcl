# Copyright 2020-2021 Efabless Corporation
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

proc run_magic {args} {
    TIMER::timer_start
    increment_index
    puts_info "Running Magic to generate various views..."
    # |----------------------------------------------------|
    # |----------------   6. TAPE-OUT ---------------------|
    # |----------------------------------------------------|
    puts_info "Streaming out GDS-II with Magic..."
    set ::env(CURRENT_STAGE) signoff
    # the following MAGTYPE better be mag for clean GDS generation
    # use load -dereference to ignore it later if needed

    set ::env(MAGTYPE) mag
    # Generate GDS and MAG views
    set ::env(MAGIC_GDS) $::env(signoff_results)/$::env(DESIGN_NAME).magic.gds

    run_magic_script\
        -indexed_log [index_file $::env(signoff_logs)/gdsii.log]\
        $::env(SCRIPTS_DIR)/magic/mag_gds.tcl

    if { $::env(PRIMARY_SIGNOFF_TOOL) == "magic" } {
        set ::env(CURRENT_GDS) $::env(signoff_results)/$::env(DESIGN_NAME).gds
        file copy -force $::env(MAGIC_GDS) $::env(CURRENT_GDS)
    }

    file copy -force $::env(MAGIC_MAGICRC) $::env(signoff_results)/.magicrc
    # Take a PNG screenshot
    scrot_klayout -log $::env(cts_logs)/screenshot.log

    if { ($::env(MAGIC_GENERATE_LEF) && $::env(MAGIC_GENERATE_MAGLEF)) || $::env(MAGIC_INCLUDE_GDS_POINTERS) } {
        puts_info "Generating MAGLEF views..."

        # Generate mag file that includes GDS pointers
        set ::env(MAGTYPE) mag
        run_magic_script\
            -indexed_log [index_file $::env(signoff_logs)/gds_ptrs.log]\
            $::env(SCRIPTS_DIR)/magic/gds_pointers.tcl

        # Only keep the properties section in the file
        try_catch sed -i -n "/^<< properties >>/,/^<< end >>/p" $::env(signoff_tmpfiles)/gds_ptrs.mag
    }

    # If desired, copy GDS_* properties into the mag/ view
    if { $::env(MAGIC_INCLUDE_GDS_POINTERS) } {
        copy_gds_properties $::env(signoff_tmpfiles)/gds_ptrs.mag $::env(signoff_results)/$::env(DESIGN_NAME).mag
    }

    if { $::env(MAGIC_GENERATE_LEF) } {
        # Generate LEF view
        set ::env(MAGTYPE) maglef
        run_magic_script\
            -indexed_log [index_file $::env(signoff_logs)/lef.log]\
            $::env(SCRIPTS_DIR)/magic/lef.tcl

        if { $::env(MAGIC_GENERATE_MAGLEF) } {
            # Generate MAGLEF view
            set ::env(MAGTYPE) maglef

            run_magic_script\
                -indexed_log [index_file $::env(signoff_logs)/maglef.log]\
                $::env(SCRIPTS_DIR)/magic/maglef.tcl

            # By default, copy the GDS properties into the maglef/ view
            copy_gds_properties $::env(signoff_tmpfiles)/gds_ptrs.mag $::env(signoff_results)/$::env(DESIGN_NAME).lef.mag
        }
    }
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "gdsii - magic"
}


proc run_magic_drc {args} {
    increment_index
    TIMER::timer_start
    puts_info "Running Magic DRC..."

    set ::env(drc_prefix) $::env(signoff_reports)/drc
    # Has to be maglef for DRC Checking
    set ::env(MAGTYPE) maglef

    run_magic_script\
        -indexed_log [index_file $::env(signoff_logs)/drc.log]\
        $::env(SCRIPTS_DIR)/magic/drc.tcl

    puts_info "Converting Magic DRC Violations to Magic Readable Format..."
    try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/drc_rosetta.py magic to_tcl\
        -o $::env(drc_prefix).tcl \
        $::env(drc_prefix).rpt

    puts_info "Converting Magic DRC Violations to Klayout XML Database..."
    try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/drc_rosetta.py magic to_tr\
        -o $::env(drc_prefix).tr \
        $::env(drc_prefix).rpt

    try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/drc_rosetta.py tr to_klayout\
        -o $::env(drc_prefix).klayout.xml \
        --design-name $::env(DESIGN_NAME) \
        $::env(drc_prefix).tr

    try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/drc_rosetta.py magic to_tr\
        -o $::env(drc_prefix).rdb \
        $::env(drc_prefix).rpt

    file copy -force $::env(MAGIC_MAGICRC) $::env(signoff_results)/.magicrc
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "drc - magic"

    quit_on_magic_drc -log $::env(drc_prefix).tr
}

proc run_magic_spice_export {args} {
    TIMER::timer_start
    increment_index
    if { [info exist ::env(MAGIC_EXT_USE_GDS)] && $::env(MAGIC_EXT_USE_GDS) } {
        set extract_type "gds.spice"
        puts_info "Running Magic Spice Export from GDS..."
        # GDS extracted file design.gds.spice, log file magic_gds.spice.log
    } else {
        set extract_type "spice"
        puts_info "Running Magic Spice Export from LEF..."
        # LEF extracted file design.spice (copied to design.lef.spice), log file magic_spice.log
    }

    set ::env(magic_extract_prefix) [index_file $::env(signoff_logs)/ext2]

    set ::env(EXT_NETLIST) $::env(signoff_results)/$::env(DESIGN_NAME).$extract_type

    # the following MAGTYPE has to be maglef for the purpose of LVS
    # otherwise underlying device circuits would be considered
    set ::env(_tmp_magic_extract_type) $extract_type
    set ::env(MAGTYPE) maglef

    run_magic_script\
        -indexed_log [index_file $::env(signoff_logs)/$extract_type.log]\
        $::env(SCRIPTS_DIR)/magic/extract_spice.tcl

    unset ::env(_tmp_magic_extract_type)

    if { $extract_type == "spice" } {
        file copy -force $::env(signoff_results)/$::env(DESIGN_NAME).spice $::env(signoff_results)/$::env(DESIGN_NAME).lef.spice
    }
    file rename -force {*}[glob $::env(signoff_results)/*.ext] $::env(signoff_tmpfiles)
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "$extract_type extraction - magic"

    quit_on_illegal_overlaps -log [index_file $::env(signoff_logs)/ext2$extract_type.feedback.txt]
}

proc export_magic_view {args} {
    increment_index
    TIMER::timer_start
    set options {
        {-def required}
        {-output required}
    }
    set flags {}
    parse_key_args "export_magic_view" args arg_values $options flags_map $flags
    set script_dir $::env(signoff_tmpfiles)/magic_mag_save.tcl

    set stream [open $script_dir w]
    puts $stream $commands
    close $stream

    set ::env(_tmp_save_mag) $arg_values(-output)
    set ::env(_tmp_def_in) $arg_values(-def)

    run_magic_script\
        -indexed_log [index_file $::env(signoff_logs)/save_mag.log]\
        $script_dir

    unset ::env(_tmp_save_mag)
    unset ::env(_tmp_def_in)

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "mag export - magic"
}

proc run_magic_antenna_check {args} {
    increment_index
    TIMER::timer_start
    puts_info "Running Magic Antenna Checks..."
    set feedback_file [index_file $::env(signoff_reports)/antenna.feedback.txt]

    # the following MAGTYPE has to be mag; antennacheck needs to know
    # about the underlying devices, layers, etc.
    set ::env(MAGTYPE) mag

    set antenna_log [index_file $::env(signoff_logs)/antenna.log]

    set ::env(_tmp_feedback_file) $feedback_file

    run_magic_script\
        -indexed_log $antenna_log\
        $::env(SCRIPTS_DIR)/magic/antenna_check.tcl

    unset ::env(_tmp_feedback_file)

    set antenna_rpt [index_file $::env(signoff_reports)/antenna.rpt]

    # process the log
    try_catch awk "/Cell:/ {print \$2}" $antenna_log > $antenna_rpt

    set ::env(ANTENNA_VIOLATOR_LIST) $antenna_rpt

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "antenna check - magic"

}

proc copy_gds_properties {from to} {
    # copy GDS properties from $from to $to
    set gds_properties [list]
    set fp [open $from r]
    set mag_lines [split [read $fp] "\n"]
    foreach line $mag_lines {
        if { [string first "string GDS_" $line] != -1 } {
            lappend gds_properties $line
        }
    }
    close $fp

    set fp [open $to r]
    set mag_lines [split [read $fp] "\n"]
    set new_mag_lines [list]
    foreach line $mag_lines {
        if { [string first "<< end >>" $line] != -1 } {
            lappend new_mag_lines [join $gds_properties "\n"]
        }
        lappend new_mag_lines $line
    }
    close $fp

    set fp [open $to w]
    puts $fp [join $new_mag_lines "\n"]
    close $fp
}

package provide openlane 0.9

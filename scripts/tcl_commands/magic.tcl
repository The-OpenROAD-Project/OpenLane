# Copyright 2020-2022 Efabless Corporation
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
    set log [index_file $::env(signoff_logs)/gdsii.log]
    puts_info "Streaming out GDSII with Magic (log: [relpath . $log])..."
    # the following MAGTYPE better be mag for clean GDS generation
    # use load -dereference to ignore it later if needed

    set ::env(MAGTYPE) mag
    # Generate GDS and MAG views
    set ::env(MAGIC_GDS) $::env(signoff_results)/$::env(DESIGN_NAME).magic.gds

    run_magic_script\
        -indexed_log $log\
        $::env(SCRIPTS_DIR)/magic/def/mag_gds.tcl

    if { $::env(PRIMARY_SIGNOFF_TOOL) == "magic" } {
        set ::env(CURRENT_GDS) $::env(signoff_results)/$::env(DESIGN_NAME).gds
        file copy -force $::env(MAGIC_GDS) $::env(CURRENT_GDS)
    }

    file copy -force $::env(MAGIC_MAGICRC) $::env(signoff_results)/.magicrc
    # Take a PNG screenshot
    scrot_klayout -log $::env(cts_logs)/screenshot.log

    if { ($::env(MAGIC_GENERATE_LEF) && $::env(MAGIC_GENERATE_MAGLEF)) || $::env(MAGIC_INCLUDE_GDS_POINTERS) } {
        set log [index_file $::env(signoff_logs)/gds_ptrs.log]
        puts_info "Generating MAGLEF views..."

        # Generate mag file that includes GDS pointers
        set ::env(MAGTYPE) mag
        run_magic_script $::env(SCRIPTS_DIR)/magic/gds/mag_with_pointers.tcl\
            -indexed_log $log

        # Only keep the properties section in the file
        try_exec sed -i.bak -n "/^<< properties >>/,/^<< end >>/p" $::env(signoff_tmpfiles)/gds_ptrs.mag
        exec rm -f $::env(signoff_tmpfiles)/gds_ptrs.mag.bak
    }

    # If desired, copy GDS_* properties into the mag/ view
    if { $::env(MAGIC_INCLUDE_GDS_POINTERS) } {
        copy_gds_properties $::env(signoff_tmpfiles)/gds_ptrs.mag $::env(signoff_results)/$::env(DESIGN_NAME).mag
    }

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "gdsii - magic"

    if { $::env(MAGIC_GENERATE_LEF) } {
        # Generate LEF view
        TIMER::timer_start
        set ::env(MAGTYPE) mag
        set log [index_file $::env(signoff_logs)/lef.log]
        puts_info "Generating lef with Magic ($log)..."
        run_magic_script\
            -indexed_log $log\
            $::env(SCRIPTS_DIR)/magic/lef.tcl
        unset ::env(MAGTYPE)

        if { $::env(MAGIC_GENERATE_MAGLEF) } {
            # Generate MAGLEF view
            set ::env(MAGTYPE) maglef

            run_magic_script\
                -indexed_log [index_file $::env(signoff_logs)/maglef.log]\
                $::env(SCRIPTS_DIR)/magic/lef/maglef.tcl

            # By default, copy the GDS properties into the maglef/ view
            copy_gds_properties $::env(signoff_tmpfiles)/gds_ptrs.mag $::env(signoff_results)/$::env(DESIGN_NAME).lef.mag
        }
        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "lef - magic"
    }
}

proc run_magic_drc {args} {
    increment_index
    TIMER::timer_start
    set log [index_file $::env(signoff_logs)/drc.log]
    puts_info "Running Magic DRC (log: [relpath . $log])..."

    set ::env(drc_prefix) $::env(signoff_reports)/drc
    # Has to be maglef for DRC Checking
    set ::env(MAGTYPE) maglef

    run_magic_script $::env(SCRIPTS_DIR)/magic/drc.tcl\
        -indexed_log $log

    puts_info "Converting Magic DRC database to various tool-readable formats..."
    try_exec python3 $::env(SCRIPTS_DIR)/drc_rosetta.py magic to_tcl\
        -o $::env(drc_prefix).tcl \
        $::env(drc_prefix).rpt

    try_exec python3 $::env(SCRIPTS_DIR)/drc_rosetta.py magic to_tr\
        -o $::env(drc_prefix).tr \
        $::env(drc_prefix).rpt

    try_exec python3 $::env(SCRIPTS_DIR)/drc_rosetta.py tr to_klayout\
        -o $::env(drc_prefix).klayout.xml \
        --design-name $::env(DESIGN_NAME) \
        $::env(drc_prefix).tr

    try_exec python3 $::env(SCRIPTS_DIR)/drc_rosetta.py magic to_rdb\
        -o $::env(drc_prefix).rdb \
        $::env(drc_prefix).rpt

    file copy -force $::env(MAGIC_MAGICRC) $::env(signoff_results)/.magicrc
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "drc - magic"

    if { [info exists ::env(QUIT_ON_MAGIC_DRC)] && $::env(QUIT_ON_MAGIC_DRC) } {
        quit_on_magic_drc -log $::env(drc_prefix).tr
    }
}

proc run_magic_spice_export {args} {
    TIMER::timer_start
    increment_index
    set log ""
    if { [info exist ::env(MAGIC_EXT_USE_GDS)] && $::env(MAGIC_EXT_USE_GDS) } {
        set extract_type "gds.spice"
        set log [index_file $::env(signoff_logs)/$extract_type.log]
        puts_info "Running Magic Spice Export from GDS (log: [relpath . $log])..."
        # GDS extracted file design.gds.spice, log file magic_gds.spice.log
    } else {
        set extract_type "spice"
        set log [index_file $::env(signoff_logs)/$extract_type.log]
        puts_info "Running Magic Spice Export from LEF (log: [relpath . $log])..."
        # LEF extracted file design.spice (copied to design.lef.spice), log file magic_spice.log
    }

    set ::env(EXT_NETLIST) $::env(signoff_results)/$::env(DESIGN_NAME).$extract_type
    set feedback_file [index_file $::env(signoff_reports)/$extract_type.ext_feedback.txt]

    # the following MAGTYPE has to be maglef for the purpose of LVS
    # otherwise underlying device circuits would be considered
    set ::env(_tmp_magic_extract_type) $extract_type
    set ::env(_tmp_magic_feedback_file) $feedback_file
    set ::env(MAGTYPE) maglef

    run_magic_script $::env(SCRIPTS_DIR)/magic/extract_spice.tcl\
        -indexed_log $log

    unset ::env(_tmp_magic_extract_type)
    unset ::env(_tmp_magic_feedback_file)

    if { $extract_type == "spice" } {
        file copy -force $::env(signoff_results)/$::env(DESIGN_NAME).spice $::env(signoff_results)/$::env(DESIGN_NAME).lef.spice
    }

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "$extract_type extraction - magic"

    if { [info exists ::env(QUIT_ON_ILLEGAL_OVERLAPS)] && $::env(QUIT_ON_ILLEGAL_OVERLAPS) } {
        quit_on_illegal_overlaps -log $feedback_file
    }
}

proc export_magic_view {args} {
    set options {
        {-def required}
        {-output required}
    }
    set flags {}
    parse_key_args "export_magic_view" args arg_values $options flags_map $flags
    increment_index
    TIMER::timer_start

    set log [index_file $::env(signoff_logs)/save_mag.log]
    puts_info "Running Magic Antenna Checks (log: [relpath . $log])..."

    set script_dir [index_file $::env(signoff_tmpfiles)/mag_save]
    set script_path $script_dir/mag.tcl

    file mkdir script_dir
    file copy -force $::env(SCRIPT_DIR)/magic/def/mag.tcl $script_path

    set backup_def $::env(CURRENT_DEF)

    set ::env(SAVE_MAG) $arg_values(-output)
    set ::env(CURRENT_DEF) $arg_values(-def)

    run_magic_script\
        -indexed_log [index_file $::env(signoff_logs)/save_mag.log]\
        $script_dir

    set ::env(CURRENT_DEF) $backup_def

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "mag export - magic"
}

proc run_magic_antenna_check {args} {
    increment_index
    TIMER::timer_start
    set log [index_file $::env(signoff_logs)/magic_antenna.log]
    puts_info "Running Magic Antenna Checks (log: [relpath . $log])..."

    set feedback_file [index_file $::env(signoff_reports)/antenna.feedback.txt]

    # the following MAGTYPE has to be mag; antennacheck needs to know
    # about the underlying devices, layers, etc.
    set ::env(MAGTYPE) mag

    set ::env(_tmp_feedback_file) $feedback_file

    run_magic_script $::env(SCRIPTS_DIR)/magic/def/antenna_check.tcl\
        -indexed_log $log

    unset ::env(_tmp_feedback_file)

    set antenna_violators_rpt [index_file $::env(signoff_reports)/antenna_violators.rpt]

    # process the log
    try_exec awk "/Cell:/ {print \$2}" $log > $antenna_violators_rpt

    set ::env(ANTENNA_VIOLATOR_LIST) $antenna_violators_rpt

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

proc erase_box {args} {
    set options {
        {-input optional}
        {-output optional}
        {-box required}
    }
    set flags {}

    parse_key_args "erase_box" args arg_values $options flags_map $flags

    set_if_unset arg_values(-input) $::env(CURRENT_GDS)
    set_if_unset arg_values(-output) $arg_values(-input)

    increment_index
    TIMER::timer_start
    set log [index_file $::env(signoff_logs)/erase_box.log]
    puts_info "Erasing a box with Magic... (log: [relpath . $log])..."

    set gds_backup $::env(CURRENT_GDS)
    set ::env(CURRENT_GDS) $arg_values(-input)
    set ::env(SAVE_GDS) $arg_values(-output)
    set ::env(_tmp_mag_box_coordinates) $arg_values(-box)

    run_magic_script $::env(SCRIPTS_DIR)/magic/gds/erase_box.tcl\
        -indexed_log $log

    set ::env(CURRENT_GDS) $gds_backup
    unset ::env(_tmp_mag_box_coordinates)
    unset ::env(SAVE_GDS)
}

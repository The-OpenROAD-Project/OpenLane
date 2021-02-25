# Copyright 2020 Efabless Corporation
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

package require json
package require openlane_utils

proc set_netlist {netlist args} {
    set options {}

    set flags {
        -lec
    }
    set args_copy $args

    parse_key_args "set_netlist" args arg_values $options flags_map $flags

    puts_info "Changing netlist from $::env(CURRENT_NETLIST) to $netlist"

    set ::env(PREV_NETLIST) $::env(CURRENT_NETLIST)
    set ::env(CURRENT_NETLIST) $netlist

    set replace [string map {/ \\/} $::env(CURRENT_NETLIST)]
    try_catch sed -i -e "s/\\(set ::env(CURRENT_NETLIST)\\).*/\\1 $replace/" "$::env(GLB_CFG_FILE)"

    set replace [string map {/ \\/} $::env(PREV_NETLIST)]
    try_catch sed -i -e "s/\\(set ::env(PREV_NETLIST)\\).*/\\1 $replace/" "$::env(GLB_CFG_FILE)"

    if { [info exists flags_map(-lec)] && [file exists $::env(PREV_NETLIST)] } {
        logic_equiv_check -rhs $::env(PREV_NETLIST) -lhs $::env(CURRENT_NETLIST)
    }
}

proc set_def {def} {
    puts_info "Changing layout from $::env(CURRENT_DEF) to $def"
    set ::env(CURRENT_DEF) $def
    set replace [string map {/ \\/} $def]
    exec sed -i -e "s/\\(set ::env(CURRENT_DEF)\\).*/\\1 $replace/" "$::env(GLB_CFG_FILE)"
}

proc set_guide {guide} {
    puts_info "Changing layout from $::env(CURRENT_GUIDE) to $guide"
    set ::env(CURRENT_GUIDE) $guide
    set replace [string map {/ \\/} $guide]
    exec sed -i -e "s/\\(set ::env(CURRENT_GUIDE)\\).*/\\1 $replace/" "$::env(GLB_CFG_FILE)"
}

proc prep_lefs {args} {
    puts_info "Preparing LEF Files"
    puts_info "Extracting the number of available metal layers from $::env(TECH_LEF)"
    try_catch python3 $::env(SCRIPTS_DIR)/extract_metal_layers.py -t $::env(TECH_LEF) -o $::env(TMP_DIR)/met_layers_list.txt
    set tech_metal_layers_string [exec cat $::env(TMP_DIR)/met_layers_list.txt]
    set tech_metal_layers_string_strip [join $tech_metal_layers_string " "]
    set ::env(TECH_METAL_LAYERS) [split $tech_metal_layers_string_strip]
    set ::env(MAX_METAL_LAYER) [llength $::env(TECH_METAL_LAYERS)]
    puts_info "The number of available metal layers is $::env(MAX_METAL_LAYER)"
    puts_info "The available metal layers are $tech_metal_layers_string_strip"
    puts_info "Merging LEF Files..."
    try_catch $::env(SCRIPTS_DIR)/mergeLef.py -i $::env(TECH_LEF) $::env(CELLS_LEF) -o $::env(TMP_DIR)/merged_unpadded.lef |& tee $::env(TERMINAL_OUTPUT)

    set ::env(MERGED_LEF_UNPADDED) $::env(TMP_DIR)/merged_unpadded.lef
    # pad lef
    set ::env(CELLS_LEF_UNPADDED) $::env(TMP_DIR)/merged_unpadded.lef

    if { [info exist ::env(EXTRA_LEFS)] } {
        try_catch $::env(SCRIPTS_DIR)/mergeLef.py -i $::env(MERGED_LEF_UNPADDED) {*}$::env(EXTRA_LEFS) -o $::env(MERGED_LEF_UNPADDED) |& tee $::env(TERMINAL_OUTPUT)
        puts_info "Merging the following extra LEFs: $::env(EXTRA_LEFS)"
    }

    file copy -force $::env(CELLS_LEF_UNPADDED) $::env(TMP_DIR)/merged.lef
    set ::env(CELLS_LEF) $::env(TMP_DIR)/merged.lef
    if { $::env(USE_GPIO_PADS) } {
        if { [info exists ::env(USE_GPIO_ROUTING_LEF)] && $::env(USE_GPIO_ROUTING_LEF)} {
            set ::env(GPIO_PADS_LEF) $::env(GPIO_PADS_LEF_CORE_SIDE)
        }
        puts_info "Merging the following GPIO LEF views: $::env(GPIO_PADS_LEF)"

        file copy $::env(CELLS_LEF) $::env(CELLS_LEF).old
        try_catch $::env(SCRIPTS_DIR)/mergeLef.py -i $::env(CELLS_LEF).old {*}$::env(GPIO_PADS_LEF) -o $::env(CELLS_LEF)

        file copy $::env(CELLS_LEF_UNPADDED) $::env(CELLS_LEF_UNPADDED).old
        try_catch $::env(SCRIPTS_DIR)/mergeLef.py -i $::env(CELLS_LEF_UNPADDED).old {*}$::env(GPIO_PADS_LEF) -o $::env(CELLS_LEF_UNPADDED)

        file delete $::env(CELLS_LEF).old $::env(CELLS_LEF_UNPADDED).old
    }

    set ::env(MERGED_LEF) $::env(CELLS_LEF)

    widen_site_width
    use_widened_lefs

}

proc gen_exclude_list {args} {
    puts_info "Generating Exclude List..."
    set options {
        {-lib required}
    }
    set flags {
        -drc_exclude_only
        -create_dont_use_list
    }
    parse_key_args "gen_exclude_list" args arg_values $options flags_map $flags

    # Set if unset for the two env vars:
    if {![info exists ::env(NO_SYNTH_CELL_LIST)]} {
        set ::env(NO_SYNTH_CELL_LIST) $::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(STD_CELL_LIBRARY)/no_synth.cells
    }

    if {![info exists ::env(DRC_EXCLUDE_CELL_LIST)]} {
        set ::env(DRC_EXCLUDE_CELL_LIST) $::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(STD_CELL_LIBRARY)/drc_exclude.cells
    }

    # Copy the drc exclude list into the run directory, if it exists.
    if { [file exists $::env(DRC_EXCLUDE_CELL_LIST)] } {
        file copy -force $::env(DRC_EXCLUDE_CELL_LIST) $arg_values(-lib).exclude.list
    }

    # If you're not told to only use the drc exclude list, and if the no_synth.cells exists, merge the two lists
    if { (![info exists flags_map(-drc_exclude_only)]) && [file exists $::env(NO_SYNTH_CELL_LIST)] } {
        set out [open $arg_values(-lib).exclude.list a]
        set in [open $::env(NO_SYNTH_CELL_LIST)]
        fcopy $in $out
        close $in
        close $out
    }

    if { [file exists $arg_values(-lib).exclude.list] && [info exists flags_map(-create_dont_use_list)] } {
        puts_info "Creating ::env(DONT_USE_CELLS)..."
        set fp [open "$arg_values(-lib).exclude.list" r]
        set x [read $fp]
        set y [split $x]
        set ::env(DONT_USE_CELLS) [join $y " "]
        close $fp
    }


}

proc trim_lib {args} {
    puts_info "Trimming Liberty..."
    set options {
        {-input optional}
        {-output optional}
    }
    set flags {
        -drc_exclude_only
    }
    parse_key_args "trim_lib" args arg_values $options flags_map $flags
    set_if_unset arg_values(-input) $::env(LIB_SYNTH_COMPLETE)
    set_if_unset arg_values(-output) $::env(LIB_SYNTH)

    if { [info exists flags_map(-drc_exclude_only)] } {
        gen_exclude_list -lib $arg_values(-output) -drc_exclude_only
    } else {
        gen_exclude_list -lib $arg_values(-output)
    }

    # Trim the liberty with the generated list, if it exists.
    if { ! [file exists $arg_values(-output).exclude.list] } {
	set fid [open $arg_values(-output).exclude.list w]
	close $fid
    }
    try_catch $::env(SCRIPTS_DIR)/libtrim.pl $arg_values(-input) $arg_values(-output).exclude.list > $arg_values(-output)
}

proc source_config {config_file} {
    puts_info "Sourcing Configurations from $config_file"
    if { ![file exists $config_file] } {
        puts_err "Configuration file $config_file not found"
        return -code error
    }
    if { [file extension $config_file] == ".tcl" } {
        # for trusted end-users only
        source $config_file
    } elseif { [file extension $config_file] == ".json" } {
        set json_chan [open $config_file r]
        set config_content [read $json_chan]
        close $json_chan

        if { [catch {json::json2dict "$config_content"} config_dict] } {
            puts_err "Failed to parse JSON file $config_file"
            return -code error
        }
        dict for {config_key config_value} $config_dict {
            # TODO after refactor: check if config_key is a valid configuration
            set ::env($config_key) $config_value
        }
    } else {
        puts_err "Configuration file $config_file with invalid extension"
        return -code error
    }

    return -code ok
}

proc prep {args} {

    set ::env(timer_start) [clock seconds]
    set ::env(SCRIPTS_DIR) "$::env(OPENLANE_ROOT)/scripts"
    TIMER::timer_start
    set options {
        {-design required}
        {-tag optional}
        {-config_tag optional}
        {-config_file optional}
        {-run_path optional}
        {-src optional}
    }

    set flags {
        -init_design_config
        -disable_output
        -overwrite
    }

    set args_copy $args
    parse_key_args "prep" args arg_values $options flags_map $flags

    # Storing the current state of environment variables
    set ::env(INIT_ENV_VAR_ARRAY) [split [array names ::env] " "]

    if { [info exists arg_values(-config_tag)] } {
        if { [info exists arg_values(-config_file)] } {
            puts_err "Cannot specify both -config_tag and -config_file"
            return -code error
        }
        set config_tag $arg_values(-config_tag)
    } else {
        set config_tag "config"
    }
    set src_files ""

    set ::env(DESIGN_DIR) [file normalize $arg_values(-design)]
    if { ![file exists $::env(DESIGN_DIR)] } {
        set ::env(DESIGN_DIR) [file normalize $::env(OPENLANE_ROOT)/designs/$arg_values(-design)/]
    }

    if { [info exists flags_map(-init_design_config)] } {
        set config_tag "config"
        if { [info exists arg_values(-tag) ] } {
            set config_tag $arg_values(-tag)
        }

        if { [info exists arg_values(-src) ] } {
            set src_files $arg_values(-src)
        }

        init_design $arg_values(-design) $config_tag $src_files
        puts_success "Done..."
        exit 0
    }

    if { ! [info exists flags_map(-disable_output)] } {
        set ::env(TERMINAL_OUTPUT) ">&@stdout"
    } else {
        set ::env(TERMINAL_OUTPUT) "/dev/null"
    }

    set ::env(datetime) [clock format [clock seconds] -format %d-%m_%H-%M]
    if { [lsearch -exact $args_copy -tag ] >= 0} {
        set tag "$arg_values(-tag)"
    } else {
        set tag $::env(datetime)
    }

    set ::env(CONFIGS) [glob $::env(OPENLANE_ROOT)/configuration/*.tcl]

    if { [info exists arg_values(-config_file)] } {
        set ::env(DESIGN_CONFIG) $arg_values(-config_file)
    } else {
        if { [file exists $::env(DESIGN_DIR)/$config_tag.tcl] } {
            set ::env(DESIGN_CONFIG) $::env(DESIGN_DIR)/$config_tag.tcl
        } else {
            set ::env(DESIGN_CONFIG) $::env(DESIGN_DIR)/$config_tag.json
        }
    }

    if { ! [file exists $::env(DESIGN_CONFIG)] } {
        puts_err "No design configuration found at $::env(DESIGN_CONFIG)"
        return -code error
    }

    puts_info "Using design configuration at $::env(DESIGN_CONFIG)"

    foreach config $::env(CONFIGS) {
        source $config
    }

    # needs to be sourced first since it can choose to determine the PDK and SCL
    source_config $::env(DESIGN_CONFIG)


    # DEPRECATED PDK_VARIANT
    handle_deprecated_config PDK_VARIANT STD_CELL_LIBRARY

    # Diagnostics
    if { ! [info exists ::env(PDK_ROOT)] || $::env(PDK_ROOT) == "" } {
        puts_err "PDK_ROOT is not specified. Please make sure you have it set."
        return -code error
    } else {
        puts_info "PDKs root directory: $::env(PDK_ROOT)"
    }

    if { ! [info exists ::env(PDK)] } {
        puts_err "PDK is not specified."
        return -code error
    } else {
        puts_info "PDK: $::env(PDK)"
        puts_info "Setting PDKPATH to $::env(PDK_ROOT)/$::env(PDK)"
        set ::env(PDKPATH) $::env(PDK_ROOT)/$::env(PDK)
    }

    if { ! [info exists ::env(STD_CELL_LIBRARY)] } {
        puts_err "STD_CELL_LIBRARY is not specified."
        return -code error
    } else {
        puts_info "Standard Cell Library: $::env(STD_CELL_LIBRARY)"
    }


    # source PDK and SCL specific configurations
    set pdk_config $::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/config.tcl
    set scl_config $::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(STD_CELL_LIBRARY)/config.tcl
    source $pdk_config
    source $scl_config

    # needs to be resourced to make sure it overrides the above
    source_config $::env(DESIGN_CONFIG)

    # DEPRECATED CONFIGS
    handle_deprecated_config LIB_MIN LIB_FASTEST
    handle_deprecated_config LIB_MAX LIB_SLOWEST
    handle_deprecated_config CELL_PAD_EXECLUDE CELL_PAD_EXCLUDE; # typo

    if { [info exists arg_values(-run_path)] } {
        set run_path "[file normalize $arg_values(-run_path)]/$tag"
    } else {
        set run_path $::env(DESIGN_DIR)/runs/$tag
    }


    #
    ############################
    # Prep directories and files
    ############################
    #
    set ::env(RUN_TAG)		"$tag"
    set ::env(RUN_DIR) 		"$run_path"
    set ::env(RESULTS_DIR) 	"$::env(RUN_DIR)/results"
    set ::env(TMP_DIR) 		"$::env(RUN_DIR)/tmp"
    set ::env(LOG_DIR) 		"$::env(RUN_DIR)/logs"
    set ::env(REPORTS_DIR) 	"$::env(RUN_DIR)/reports"
    set ::env(GLB_CFG_FILE) 	"$::env(RUN_DIR)/config.tcl"

    set skip_basic_prep 0

    if { [file exists $::env(RUN_DIR)] } {
        if { [info exists flags_map(-overwrite)] } {
            puts_warn "Removing exisiting run $::env(RUN_DIR)"
            after 1000
            file delete -force $::env(RUN_DIR)
        } else {
            puts_warn "A run for $::env(DESIGN_NAME) with tag '$tag' already exists. Pass -overwrite option to overwrite it"
            puts_info "Now you can run commands that pick up where '$tag' left off"
            after 1000
            set skip_basic_prep 1
        }
    }


    # file mkdir *ensures* they exists (no problem if they already do)
    file mkdir $::env(RESULTS_DIR) $::env(TMP_DIR) $::env(LOG_DIR) $::env(REPORTS_DIR)

    puts_info "Current run directory is $::env(RUN_DIR)"

    if { ! $skip_basic_prep } {
        prep_lefs

        set ::env(LIB_SYNTH_COMPLETE) $::env(LIB_SYNTH)
        set ::env(LIB_SYNTH) $::env(TMP_DIR)/trimmed.lib
        trim_lib

        set tracks_copy $::env(TMP_DIR)/tracks_copy.info
        file copy -force $::env(TRACKS_INFO_FILE) $tracks_copy
        set ::env(TRACKS_INFO_FILE) $tracks_copy

        if { $::env(USE_GPIO_PADS) } {
            if { ! [info exists ::env(VERILOG_FILES_BLACKBOX)] } {
                set ::env(VERILOG_FILES_BLACKBOX) ""
            }
            if { [info exists ::env(GPIO_PADS_VERILOG)] } {
                lappend ::env(VERILOG_FILES_BLACKBOX) {*}$::env(GPIO_PADS_VERILOG)
            } else {
                puts_warn "GPIO_PADS_VERILOG is not set; cannot read as a blackbox"
            }
        }
    }

    if { [file exists $::env(GLB_CFG_FILE)] } {
        if { [info exists flags_map(-overwrite)] } {
            puts_info "Removing $::env(GLB_CFG_FILE)"
            file delete $::env(GLB_CFG_FILE)
        } else {
            puts_info "Sourcing $::env(GLB_CFG_FILE)\nAny changes to the DESIGN config file will NOT be applied"
            source $::env(GLB_CFG_FILE)
            if { [info exists ::env(CURRENT_DEF)] && $::env(CURRENT_DEF) != 0 } {
                puts_info "Current DEF: $::env(CURRENT_DEF)."
                puts_info "Use 'set_def file_name.def' if you'd like to change it."
            }
            after 1000
        }
    }

    set tmp_output {
        {yosys synthesis/yosys}
        {opensta synthesis/opensta}
        {verilog2def floorplan/verilog2def}
        {ioPlacer floorplan/ioPlacer}
        {pdn floorplan/pdn}
        {tapcell floorplan/tapcell}
        {replaceio placement/replace}
        {openphysyn placement/openphysyn}
        {resizer placement/resizer}
        {opendp placement/opendp}
        {addspacers routing/addspacers}
        {fastroute routing/fastroute}
        {tritonRoute routing/tritonRoute}
        {magic magic/magic}
        {cts cts/cts}
        {lvs lvs/lvs}
        {cvc cvc/cvc}
        {klayout klayout/klayout}
    }

    set final_output \
        [list  \
        [list yosys synthesis/$::env(DESIGN_NAME).synthesis] \
        [list tapcell floorplan/$::env(DESIGN_NAME).floorplan] \
        [list opendp placement/$::env(DESIGN_NAME).placement] \
        [list tritonRoute routing/$::env(DESIGN_NAME)] \
        [list cts cts/$::env(DESIGN_NAME).cts] \
        [list magic magic/$::env(DESIGN_NAME)] \
        [list lvs lvs/$::env(DESIGN_NAME).lvs] \
        [list cvc cvc/$::env(DESIGN_NAME)] \
        [list klayout klayout/$::env(DESIGN_NAME)] 
        ]

    array set results_file_name [make_array $final_output $::env(RESULTS_DIR)/]
    array set reports_file_name [make_array $tmp_output $::env(REPORTS_DIR)/]
    array set logs_file_name [make_array $tmp_output $::env(LOG_DIR)/]
    array set tmp_file_name [make_array $tmp_output $::env(TMP_DIR)/]

    foreach {key value} [array get results_file_name] {
        set ::env(${key}_result_file_tag) $value
    }
    foreach {key value} [array get reports_file_name] {
        set ::env(${key}_report_file_tag) $value
    }
    foreach {key value} [array get logs_file_name] {
        set ::env(${key}_log_file_tag) $value
    }
    foreach {key value} [array get tmp_file_name] {
        set ::env(${key}_tmp_file_tag) $value
    }

    set util 	$::env(FP_CORE_UTIL)
    set density $::env(PL_TARGET_DENSITY)

    set stages {synthesis floorplan placement cts routing magic lvs cvc klayout}
    foreach stage $stages {
        file mkdir\
            $::env(RESULTS_DIR)/$stage \
            $::env(TMP_DIR)/$stage  \
            $::env(LOG_DIR)/$stage \
            $::env(REPORTS_DIR)/$stage

        if { ! [file exists $::env(TMP_DIR)/$stage/merged_unpadded.lef] } {
            file link -symbolic $::env(TMP_DIR)/$stage/merged_unpadded.lef ../../tmp/merged_unpadded.lef
        }
        if { ! [file exists $::env(RESULTS_DIR)/$stage/merged_unpadded.lef] } {
            file link -symbolic $::env(RESULTS_DIR)/$stage/merged_unpadded.lef ../../tmp/merged_unpadded.lef
        }
    }

    # Fill config file
    puts_info "Storing configs into config.tcl ..."
    exec echo "# Run configs" > $::env(GLB_CFG_FILE)
    set_log ::env(PDK_ROOT) $::env(PDK_ROOT) $::env(GLB_CFG_FILE) 1
    foreach index [lsort [array names ::env]] {
        if { $index != "INIT_ENV_VAR_ARRAY" } {
            if { $index ni $::env(INIT_ENV_VAR_ARRAY) } {
                set_log ::env($index) $::env($index) $::env(GLB_CFG_FILE) 1
            }
        }
    }

    # Fill config file with special cases
    if { ! [info exists ::env(SYNTH_MAX_TRAN)] } {
        if { [info exists ::env(CLOCK_PERIOD)] } {
            if { [info exists ::env(DEFAULT_MAX_TRAN)] } {
                set ::env(SYNTH_MAX_TRAN) [expr min([expr {0.1*$::env(CLOCK_PERIOD)}], $::env(DEFAULT_MAX_TRAN))]
            } else {
                set ::env(SYNTH_MAX_TRAN) [expr {0.1*$::env(CLOCK_PERIOD)}]
            }
        } else {
            set ::env(SYNTH_MAX_TRAN) 0
        }
        set_log ::env(SYNTH_MAX_TRAN) $::env(SYNTH_MAX_TRAN) $::env(GLB_CFG_FILE) 1
    }
    if { $::env(SYNTH_TOP_LEVEL) } {
        set_log ::env(SYNTH_SCRIPT) "$::env(OPENLANE_ROOT)/scripts/synth_top.tcl" $::env(GLB_CFG_FILE) 0
    }
    set_log ::env(SYNTH_OPT) 0 $::env(GLB_CFG_FILE) 0
    set_log ::env(PL_INIT_COEFF) 0.00002 $::env(GLB_CFG_FILE) 0
    set_log ::env(PL_IO_ITER) 5 $::env(GLB_CFG_FILE) 0

    if { ! [info exists ::env(CURRENT_DEF)] } {
        set ::env(CURRENT_DEF) 0
        set_log ::env(CURRENT_DEF) $::env(CURRENT_DEF) $::env(GLB_CFG_FILE) 1
    }

    if { ! [info exists ::env(CURRENT_GUIDE)] } {
        set ::env(CURRENT_GUIDE) 0
        set_log ::env(CURRENT_GUIDE) $::env(CURRENT_GUIDE) $::env(GLB_CFG_FILE) 1
    }

    if { ! [info exists ::env(CURRENT_INDEX)] } {
        set ::env(CURRENT_INDEX) 0
        set_log ::env(CURRENT_INDEX) $::env(CURRENT_INDEX) $::env(GLB_CFG_FILE) 1
    }

    if { ! [info exists ::env(CURRENT_NETLIST)] } {
        set ::env(CURRENT_NETLIST) 0
        set_log ::env(CURRENT_NETLIST) $::env(CURRENT_NETLIST) $::env(GLB_CFG_FILE) 1
    }

    if { ! [info exists ::env(PREV_NETLIST)] } {
        set ::env(PREV_NETLIST) 0
        set_log ::env(PREV_NETLIST) $::env(PREV_NETLIST) $::env(GLB_CFG_FILE) 1
    }

    if { [file exists $::env(PDK_ROOT)/$::env(PDK)/SOURCES] } {
		file copy -force $::env(PDK_ROOT)/$::env(PDK)/SOURCES $::env(RUN_DIR)/PDK_SOURCES
	}
    if { [info exists ::env(OPENLANE_VERSION) ] } {
        try_catch echo "openlane $::env(OPENLANE_VERSION)" > $::env(RUN_DIR)/OPENLANE_VERSION
    }

    puts_info "Preparation complete"
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> [index_file $::env(LOG_DIR)/prep_runtime.txt 0]
    return -code ok
}

proc padframe_gen {args} {
    puts_info "Generating Padframe..."
    set options {{-folder required}}
    set flags {}
    parse_key_args "padframe_gen" args arg_values $options flags_map $flags
    set pf_src_tmp [file normalize $arg_values(-folder)]
    #
    set pfg_exec $::env(SCRIPTS_DIR)/pfg.py
    #   set pf_src $::env(DESIGN_DIR)/src
    #   set pf_src_tmp $::env(TMP_DIR)/src
    #   file copy $pf_src $pf_src_tmp

    fake_display_buffer

    exec $pfg_exec -nogui -tech-path=$::env(PDK_ROOT)/$::env(PDK) \
        -project-path=$pf_src_tmp -cfg \
        |& tee $::env(TERMINAL_OUTPUT) [index_file $pf_src_tmp/pfg.log]
    kill_display_buffer
}

proc padframe_gen_legacy {args} {
    set pfg_exec $::env(SCRIPTS_DIR)/pfg.py
    set pf_src $::env(DESIGN_DIR)/src
    set pf_src_tmp $::env(TMP_DIR)/src
    file copy $pf_src $pf_src_tmp

    fake_display_buffer

    exec $pfg_exec -nogui -tech-path=$::env(PDK_ROOT)/$::env(PDK) \
        -project-path=$pf_src_tmp -cfg \
        |& tee $::env(TERMINAL_OUTPUT) [index_file $pf_src_tmp/pfg.log]
    kill_display_buffer
}


proc save_views {args} {
    set options {
        {-lef_path optional}
        {-mag_path optional}
        {-maglef_path optional}
        {-def_path optional}
        {-gds_path optional}
        {-verilog_path optional}
        {-spice_path optional}
        {-save_path optional}
        {-tag required}
    }

    set flags {}
    parse_key_args "save_views" args arg_values $options flags_map $flags
    if { [info exists arg_values(-save_path)]\
        && $arg_values(-save_path) != "" } {
        set path "[file normalize $arg_values(-save_path)]"
    } else {
        set path $::env(DESIGN_DIR)
    }
    puts_info "Saving Magic Views in $path"

    if { [info exists arg_values(-lef_path)] } {
        set destination $path/lef
        file mkdir $destination
        if { [file exists $arg_values(-lef_path)] } {
            file copy -force $arg_values(-lef_path) $destination/$arg_values(-tag).lef
        }
    }

    if { [info exists arg_values(-mag_path)] } {
        set destination $path/mag
        file mkdir $destination
        if { [file exists $arg_values(-mag_path)] } {
            file copy -force $arg_values(-mag_path) $destination/$arg_values(-tag).mag
        }
    }

    if { [info exists arg_values(-maglef_path)] } {
        set destination $path/maglef
        file mkdir $destination
        if { [file exists $arg_values(-maglef_path)] } {
            file copy -force $arg_values(-maglef_path) $destination/$arg_values(-tag).mag
        }
    }

    if { [info exists arg_values(-def_path)] } {
        set destination $path/def
        file mkdir $destination
        if { [file exists $arg_values(-def_path)] } {
            file copy -force $arg_values(-def_path) $destination/$arg_values(-tag).def
        }
    }

    if { [info exists arg_values(-gds_path)] } {
        set destination $path/gds
        file mkdir $destination
        if { [file exists $arg_values(-gds_path)] } {
            file copy -force $arg_values(-gds_path) $destination/$arg_values(-tag).gds
        }
    }
    if { [info exists arg_values(-verilog_path)] } {
        set destination $path/verilog/gl
        file mkdir $destination
        if { [file exists $arg_values(-verilog_path)] } {
            file copy -force $arg_values(-verilog_path) $destination/$arg_values(-tag).v
        }
    }

    if { [info exists arg_values(-spice_path)] } {
        set destination $path/spi/lvs
        file mkdir $destination
        if { [file exists $arg_values(-spice_path)] } {
            file copy -force $arg_values(-spice_path) $destination/$arg_values(-tag).spice
        }
    }
}


# to be done after detailed routing and run_magic_antenna_check
proc heal_antenna_violators {args} {
    # requires a pre-existing report containing a list of cells (-pins?)
	# that need the real diode in place of the fake diode:
	# $::env(magic_tmp_file_tag).antenna_violators.rpt or $::env(REPORTS_DIR)/routing/antenna.rpt
	# => fixes the routed def
	if { ($::env(DIODE_INSERTION_STRATEGY) == 2) || ($::env(DIODE_INSERTION_STRATEGY) == 5) } {
        TIMER::timer_start
        puts_info "Healing Antenna Violators..."
		if { $::env(USE_ARC_ANTENNA_CHECK) == 1 } {
			#ARC specific
			try_catch python3 $::env(SCRIPTS_DIR)/extract_antenna_violators.py -i [index_file $::env(REPORTS_DIR)/routing/antenna.rpt 0] -o [index_file $::env(TMP_DIR)/vios.txt 0]
		} else {
            #Magic Specific
			set report_file [open [index_file $::env(magic_report_file_tag).antenna_violators.rpt 0] r]
			set violators [split [string trim [read $report_file]]]
			close $report_file
			# may need to speed this up for extremely huge files using hash tables
			exec echo $violators >> [index_file $::env(TMP_DIR)/vios.txt 0]
		}
		#replace violating cells with real diodes
		try_catch python3 $::env(SCRIPTS_DIR)/fakeDiodeReplace.py -v [index_file $::env(TMP_DIR)/vios.txt 0] -d $::env(tritonRoute_result_file_tag).def -f $::env(FAKEDIODE_CELL) -t $::env(DIODE_CELL)
		puts_info "DONE HEALING ANTENNA VIOLATORS"
        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" >> [index_file $::env(LOG_DIR)/antenna_heal_runtime.txt 0]
	}
}


proc li1_hack_start {args} {
    puts_info "Starting the li1 Hack..."
    try_catch touch $::env(TMP_DIR)/li1HackTmpFile.txt
    try_catch python3 $::env(SCRIPTS_DIR)/li1_hack_start.py -d $::env(CURRENT_DEF) -l $::env(MERGED_LEF_UNPADDED) -t $::env(TMP_DIR)/li1HackTmpFile.txt
}

proc li1_hack_end {args} {
    puts_info "Ending the li1 Hack..."
    try_catch python3 $::env(SCRIPTS_DIR)/li1_hack_end.py -d $::env(CURRENT_DEF) -t $::env(TMP_DIR)/li1HackTmpFile.txt
}

proc widen_site_width {args} {

    set ::env(MERGED_LEF_UNPADDED_ORIGINAL) $::env(MERGED_LEF_UNPADDED)
    set ::env(MERGED_LEF_ORIGINAL) $::env(MERGED_LEF)

    if { $::env(WIDEN_SITE) == 1 && $::env(WIDEN_SITE_IS_FACTOR) == 1 } {
        set ::env(MERGED_LEF_UNPADDED_WIDENED) $::env(MERGED_LEF_UNPADDED)
        set ::env(MERGED_LEF_WIDENED) $::env(MERGED_LEF)
    } else {
        puts_info "Widenning Site Width..."
        set ::env(MERGED_LEF_UNPADDED_WIDENED) $::env(TMP_DIR)/merged_unpadded_wider.lef
        set ::env(MERGED_LEF_WIDENED) $::env(TMP_DIR)/merged_wider.lef
        if { $::env(WIDEN_SITE_IS_FACTOR) == 1 } {
            try_catch python3 $::env(SCRIPTS_DIR)/widenSiteLef.py -l $::env(MERGED_LEF_UNPADDED) -w $::env(WIDEN_SITE) -f -o $::env(MERGED_LEF_UNPADDED_WIDENED)
            try_catch python3 $::env(SCRIPTS_DIR)/widenSiteLef.py -l $::env(MERGED_LEF) -w $::env(WIDEN_SITE) -f -o $::env(MERGED_LEF_WIDENED)

        } else {
            try_catch python3 $::env(SCRIPTS_DIR)/widenSiteLef.py -l $::env(MERGED_LEF_UNPADDED) -w $::env(WIDEN_SITE) -o $::env(MERGED_LEF_UNPADDED_WIDENED)
            try_catch python3 $::env(SCRIPTS_DIR)/widenSiteLef.py -l $::env(MERGED_LEF) -w $::env(WIDEN_SITE) -o $::env(MERGED_LEF_WIDENED)
        }
    }
}

proc use_widened_lefs {args} {
    if { $::env(WIDEN_SITE) != 1 || $::env(WIDEN_SITE_IS_FACTOR) != 1 } {
        set ::env(MERGED_LEF_UNPADDED) $::env(MERGED_LEF_UNPADDED_WIDENED)
        set ::env(MERGED_LEF) $::env(MERGED_LEF_WIDENED)
    }
}

proc use_original_lefs {args} {
    if { $::env(WIDEN_SITE) != 1 || $::env(WIDEN_SITE_IS_FACTOR) != 1 } {
        set ::env(MERGED_LEF_UNPADDED) $::env(MERGED_LEF_UNPADDED_ORIGINAL)
        set ::env(MERGED_LEF) $::env(MERGED_LEF_ORIGINAL)
    }
}


proc label_macro_pins {args} {
    TIMER::timer_start
    puts_info "Labeling macro pins..."
    set options {
        {-lef required}
        {-netlist_def required}
        {-pad_pin_name optional}
        {-output optional}
        {-extra_args optional}
    }
    set flags {}
    parse_key_args "label_macro_pins" args arg_values $options flags_map $flags

    set output_def $::env(CURRENT_DEF)
    set extra_args ""

    if {[info exists arg_values(-output)]} {
        set output_def $arg_values(-output)
    }

    if {[info exists arg_values(-extra_args)]} {
        set extra_args $arg_values(-extra_args)
    }

    set_if_unset arg_values(-pad_pin_name) ""

    try_catch python3 $::env(SCRIPTS_DIR)/label_macro_pins.py\
        --lef $arg_values(-lef)\
        --input-def $::env(CURRENT_DEF)\
        --netlist-def $arg_values(-netlist_def)\
        --pad-pin-name $arg_values(-pad_pin_name)\
        -o $output_def\
        {*}$extra_args |& tee [index_file $::env(LOG_DIR)/label_macro_pins.log] $::env(TERMINAL_OUTPUT)
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> [index_file $::env(LOG_DIR)/label_macro_pins_runtime.txt 0]
}


proc write_verilog {filename args} {
    TIMER::timer_start
    puts_info "Writing Verilog..."
    set ::env(SAVE_NETLIST) $filename

    set options {
        {-def optional}
    }
    set flags {
        -canonical
    }
    parse_key_args "write_verilog" args arg_values $options flags_map $flags

    set_if_unset arg_values(-def) $::env(CURRENT_DEF)

    set ::env(INPUT_DEF) $arg_values(-def)

    try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_write_verilog.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(LOG_DIR)/write_verilog.log]
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> [index_file $::env(LOG_DIR)/write_verilog_runtime.txt 0]
    if { [info exists flags_map(-canonical)] } {
        yosys_rewrite_verilog $filename
    }
}

proc set_layer_tracks {args} {
    puts_info "Setting Layer Tracks..."
    set options {
        {-defFile required}
        {-layer required}
        {-valuesFile required}
        {-originalFile required}
    }
    set flags {}
    parse_key_args "set_layer_tracks" args arg_values $options flags_map $flags

    try_catch python3 $::env(SCRIPTS_DIR)/setLayerTracks.py -d $arg_values(-defFile) -l $arg_values(-layer) -v $arg_values(-valuesFile) -o $arg_values(-originalFile)

}

proc run_or_antenna_check {args} {
    TIMER::timer_start
    puts_info "Running OpenROAD Antenna Rule Checker..."
	try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_antenna_check.tcl |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(LOG_DIR)/routing/or_antenna.log]
    try_catch mv -f $::env(REPORTS_DIR)/routing/antenna.rpt [index_file $::env(REPORTS_DIR)/routing/antenna.rpt]
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" >> [index_file $::env(LOG_DIR)/routing/or_antenna_runtime.txt 0]

}

proc run_antenna_check {args} {
    puts_info "Running Antenna Checks..."
	if { $::env(USE_ARC_ANTENNA_CHECK) == 1 } {
		run_or_antenna_check
	} else {
		run_magic_antenna_check
	}
}

package provide openlane 0.9

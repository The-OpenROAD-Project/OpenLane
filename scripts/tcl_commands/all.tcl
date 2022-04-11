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

package require json
package require openlane_utils


proc save_state {args} {
    set ::env(INIT_ENV_VAR_ARRAY) [split [array names ::env] " "]
    puts_info "Saving runtime environment..."
    set_log ::env(PDK_ROOT) $::env(PDK_ROOT) $::env(GLB_CFG_FILE) 1
    foreach index [lsort [array names ::env]] {
        if { $index != "INIT_ENV_VAR_ARRAY" && $index != "PS1" } {
            set escaped_env_var [string map {\" \\\"} $::env($index)]
            set escaped_env_var [string map {\$ \\\$} $escaped_env_var]
            set_log ::env($index) $escaped_env_var $::env(GLB_CFG_FILE) 1
        }
    }
}

proc set_netlist {netlist args} {
    set options {}

    set flags {
        -lec
    }
    set args_copy $args

    parse_key_args "set_netlist" args arg_values $options flags_map $flags

    set netlist_relative [relpath . $netlist]

    puts_verbose "Changing netlist to '$netlist_relative'..."

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
    set def_relative [relpath . $def]
    puts_verbose "Changing layout to '$def_relative'..."
    set ::env(CURRENT_DEF) $def
    set replace [string map {/ \\/} $def]
    exec sed -i -e "s/\\(set ::env(CURRENT_DEF)\\).*/\\1 $replace/" "$::env(GLB_CFG_FILE)"
}

proc set_guide {guide} {
    set guide_relative [relpath . $guide]
    puts_verbose "Changing guide to '$guide_relative'..."
    set ::env(CURRENT_GUIDE) $guide
    set replace [string map {/ \\/} $guide]
    exec sed -i -e "s/\\(set ::env(CURRENT_GUIDE)\\).*/\\1 $replace/" "$::env(GLB_CFG_FILE)"
}

proc prep_lefs {args} {
    set options {
        {-tech_lef optional}
        {-cell_lef optional}
        {-corner optional}
        {-env_var optional}
    }

    set flags {-no_widen}

    parse_key_args "prep_lefs" args arg_values $options flags_map $flags

    set_if_unset arg_values(-tech_lef) $::env(TECH_LEF)
    set_if_unset arg_values(-cell_lef) $::env(CELLS_LEF)
    set_if_unset arg_values(-env_var) MERGED_LEF
    set_if_unset arg_values(-corner) nom

    if { ![file exists $arg_values(-tech_lef)] } {
        if { $arg_values(-env_var) == "MERGED_LEF" } {
            puts_err "Nominal process corner '$arg_values(-tech_lef)' not found."
            return -code error
        }
        puts_info "'$arg_values(-tech_lef)' not found, skipping..."
        return
    }
    puts_info "Preparing LEF files for the $arg_values(-corner) corner..."

    if { $arg_values(-corner) == "nom" } {
        puts_verbose "Extracting the number of available metal layers from $arg_values(-tech_lef)"

        set ::env(TECH_METAL_LAYERS)  [exec python3 $::env(SCRIPTS_DIR)/extract_metal_layers.py $arg_values(-tech_lef)]
        set ::env(MAX_METAL_LAYER) [llength $::env(TECH_METAL_LAYERS)]

        puts_verbose "The available metal layers ($::env(MAX_METAL_LAYER)) are $::env(TECH_METAL_LAYERS)"
        puts_verbose "Merging LEF Files..."
    }

    set mlu $::env(TMP_DIR)/merged.unpadded.$arg_values(-corner).lef

    try_catch $::env(SCRIPTS_DIR)/mergeLef.py\
        -o $mlu\
        -i $arg_values(-tech_lef) $arg_values(-cell_lef)\
        |& tee $::env(TERMINAL_OUTPUT)

    set mlu_relative [relpath . $mlu]
    puts_verbose "Created merged LEF without pads at '$mlu_relative'..."

    # Merged Extra Lefs (if they exist)
    if { [info exist ::env(EXTRA_LEFS)] } {
        try_catch $::env(SCRIPTS_DIR)/mergeLef.py\
            -o $mlu\
            -i $mlu {*}$::env(EXTRA_LEFS)\
            |& tee $::env(TERMINAL_OUTPUT)
        puts_verbose "Added extra lefs to '$mlu_relative'..."
    }

    # Merge optimization TLEF/CLEF (if exists)
    if { [info exist ::env(STD_CELL_LIBRARY_OPT)] && $::env(STD_CELL_LIBRARY_OPT) != $::env(STD_CELL_LIBRARY) } {
        try_catch $::env(SCRIPTS_DIR)/mergeLef.py\
            -o $mlu\
            -i $mlu $::env(TECH_LEF_OPT) {*}$::env(CELLS_LEF_OPT) |& tee $::env(TERMINAL_OUTPUT)
        puts_verbose "Added optimization library tech lef and cell lefs to '$mlu_relative'..."
    }

    # Merge pads (if GPIO_PADS_LEF exists)
    set ml $::env(TMP_DIR)/merged.$arg_values(-corner).lef
    set ml_relative [relpath . $ml]
    if { $::env(USE_GPIO_PADS) } {
        if { [info exists ::env(USE_GPIO_ROUTING_LEF)] && $::env(USE_GPIO_ROUTING_LEF)} {
            set ::env(GPIO_PADS_LEF) $::env(GPIO_PADS_LEF_CORE_SIDE)
        }

        puts_verbose "Merging the following GPIO LEF views: $::env(GPIO_PADS_LEF)..."
        try_catch $::env(SCRIPTS_DIR)/mergeLef.py\
            -o $ml\
            -i $mlu {*}$::env(GPIO_PADS_LEF)
        puts_verbose "Created '$ml_relative' with gpio pads."
    } else {
        file copy -force $mlu $ml
        puts_verbose "Created '$ml_relative' unaltered."
    }

    set ::env($arg_values(-env_var)_UNPADDED) $mlu
    set ::env($arg_values(-env_var)) $ml

    if { ![info exists flags_map(-no_widen)] } {
        widen_site_width
        use_widened_lefs
    }
}

proc gen_exclude_list {args} {
    puts_verbose "Generating cell exclude list..."
    set options {
        {-lib required}
        {-drc_exclude_list optional}
        {-synth_exclude_list optional}
        {-output optional}
    }
    set flags {
        -drc_exclude_only
        -create_dont_use_list
    }
    parse_key_args "gen_exclude_list" args arg_values $options flags_map $flags

    set_if_unset arg_values(-drc_exclude_list) $::env(DRC_EXCLUDE_CELL_LIST)
    set_if_unset arg_values(-synth_exclude_list) $::env(NO_SYNTH_CELL_LIST)
    set_if_unset arg_values(-output) $arg_values(-lib).exclude.list

    # Copy the drc exclude list into the run directory, if it exists.
    foreach list_file $arg_values(-drc_exclude_list) {
        set out  [open $arg_values(-output) a]
        if { [file exists $list_file] } {
            set in [open $list_file]
            fcopy $in $out
            close $in
        }
        close $out
    }

    # If you're not told to only use the drc exclude list, and if the no_synth.cells exists, merge the two lists
    if { (![info exists flags_map(-drc_exclude_only)]) && [file exists $arg_values(-synth_exclude_list)] } {
        set out [open $arg_values(-output) a]
        set in [open $arg_values(-synth_exclude_list)]
        fcopy $in $out
        close $in
        close $out
    }

    if { [file exists $arg_values(-output)] && [info exists flags_map(-create_dont_use_list)] } {
        puts_verbose "Creating ::env(DONT_USE_CELLS)..."
        set x [cat "$arg_values(-output)"]
        set y [split $x]
        set ::env(DONT_USE_CELLS) [join $y " "]
    }


}

proc trim_lib {args} {
    puts_verbose "Trimming Liberty..."
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

    try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/libtrim.py\
        --cell-file $arg_values(-output).exclude.list\
        --output $arg_values(-output)\
        $arg_values(-input)
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
        set config_content [cat $config_file]

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
    TIMER::timer_start
    set options {
        {-design required}
        {-tag optional}
        {-config_tag optional}
        {-config_file optional}
        {-run_path optional}
        {-src optional}
        {-override_env optional}
        {-verbose optional}
    }

    set flags {
        -init_design_config
        -overwrite
        -last_run
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
        set ::env(DESIGN_DIR) [file normalize $::env(OPENLANE_ROOT)/designs/$arg_values(-design)]
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

    set_if_unset arg_values(-verbose) "0"
    set ::env(OPENLANE_VERBOSE) $arg_values(-verbose)


    set ::env(TERMINAL_OUTPUT) "/dev/null"
    if { $::env(OPENLANE_VERBOSE) >= 2 } {
        set ::env(TERMINAL_OUTPUT) ">&@stdout"
    }

    set ::env(START_TIME) [clock format [clock seconds] -format %Y.%m.%d_%H.%M.%S ]

    if { [info exists flags_map(-last_run)] } {
        if { [info exists arg_values(-tag)] } {
            puts_err "Cannot specify a tag with -last_run set."
            return -code error
        }

        set arg_values(-tag) [exec python3 ./scripts/most_recent_run.py $::env(DESIGN_DIR)/runs]
    }

    set_if_unset arg_values(-tag) "RUN_$::env(START_TIME)"
    set tag $arg_values(-tag)


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

    if { [info exists arg_values(-override_env)] } {
        set env_overrides [split $arg_values(-override_env) ',']
        foreach override $env_overrides {
            set kva [split $override '=']
            set key [lindex $kva 0]
            set value [lindex $kva 1]
            set ::env(${key}) $value
        }
    }


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

    if { ! [info exists ::env(STD_CELL_LIBRARY_OPT)] } {
        set ::env(STD_CELL_LIBRARY_OPT) $::env(STD_CELL_LIBRARY)
        puts_info "Optimization Standard Cell Library is set to: $::env(STD_CELL_LIBRARY_OPT)"
    } else {
        puts_info "Optimization Standard Cell Library: $::env(STD_CELL_LIBRARY_OPT)"
    }

    if {![info exists ::env(PDN_CFG)]} {
        set ::env(PDN_CFG) $::env(SCRIPTS_DIR)/openroad/pdn_cfg.tcl
    }

    # source PDK and SCL specific configurations
    set pdk_config $::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/config.tcl
    set scl_config $::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(STD_CELL_LIBRARY)/config.tcl
    source $pdk_config

    # Value set by PDK for some reason
    if { [info exists ::env(GLB_RT_L1_ADJUSTMENT) ] } {
        unset ::env(GLB_RT_L1_ADJUSTMENT)
    }

    source $scl_config

    # needs to be resourced to make sure it overrides the above
    source_config $::env(DESIGN_CONFIG)

    # DEPRECATED CONFIGS
    handle_deprecated_config LIB_MIN LIB_FASTEST;
    handle_deprecated_config LIB_MAX LIB_SLOWEST;
    handle_deprecated_config CELL_PAD_EXECLUDE CELL_PAD_EXCLUDE;
    handle_deprecated_config ROUTING_OPT_ITERS DRT_OPT_ITERS;
    handle_deprecated_config FP_HORIZONTAL_HALO FP_PDN_HORIZONTAL_HALO;
    handle_deprecated_config FP_VERTICAL_HALO FP_PDN_VERTICAL_HALO;

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
    set ::env(LOGS_DIR) 		"$::env(RUN_DIR)/logs"
    set ::env(REPORTS_DIR) 	"$::env(RUN_DIR)/reports"
    set ::env(GLB_CFG_FILE) 	"$::env(RUN_DIR)/config.tcl"

    set skip_basic_prep 0

    if { [file exists $::env(RUN_DIR)] } {
        if { [info exists flags_map(-overwrite)] } {
            puts_warn "Removing existing run at $::env(RUN_DIR)..."
            after 1000
            file delete -force $::env(RUN_DIR)
        } elseif { ![info exists flags_map(-last_run)] } {
            puts_warn "A run for $::env(DESIGN_NAME) with tag '$tag' already exists. Pass the -overwrite option to overwrite it."
            after 1000
            set skip_basic_prep 1
        }
    }


    # file mkdir *ensures* they exists (no problem if they already do)
    file mkdir $::env(RESULTS_DIR) $::env(TMP_DIR) $::env(LOGS_DIR) $::env(REPORTS_DIR)

    puts_info "Current run directory is $::env(RUN_DIR)"

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


    set run_subfolder_structure [list \
        synthesis\
        floorplan\
        placement\
        cts\
        routing\
        eco\
        signoff
    ]

    foreach subfolder $run_subfolder_structure {

        set ::env(${subfolder}_reports) $::env(REPORTS_DIR)/$subfolder
        file mkdir $::env(${subfolder}_reports)

        set ::env(${subfolder}_logs) $::env(LOGS_DIR)/$subfolder
        file mkdir $::env(${subfolder}_logs)

        set ::env(${subfolder}_tmpfiles) $::env(TMP_DIR)/$subfolder
        file mkdir $::env(${subfolder}_tmpfiles)

        set ::env(${subfolder}_results) $::env(RESULTS_DIR)/$subfolder
        file mkdir $::env(${subfolder}_results)
    }

    set util 	$::env(FP_CORE_UTIL)
    set density $::env(PL_TARGET_DENSITY)

    # Fill config file
    puts_verbose "Storing configs into config.tcl ..."
    exec echo "# Run configs" > $::env(GLB_CFG_FILE)
    set_log ::env(PDK_ROOT) $::env(PDK_ROOT) $::env(GLB_CFG_FILE) 1
    foreach index [lsort [array names ::env]] {
        if { $index != "INIT_ENV_VAR_ARRAY" } {
            if { $index ni $::env(INIT_ENV_VAR_ARRAY) } {
                set_log ::env($index) $::env($index) $::env(GLB_CFG_FILE) 1
            }
        }
    }

    # Process LEFs and LIB files
    if { ! $skip_basic_prep } {
        prep_lefs -tech_lef $::env(TECH_LEF) -corner nom -env_var MERGED_LEF

        if { [info exists ::env(TECH_LEF_MIN)] } {
            prep_lefs -tech_lef $::env(TECH_LEF_MIN) -corner min -env_var MERGED_LEF_MIN -no_widen
        }
        if { [info exists ::env(TECH_LEF_MAX)] } {
            prep_lefs -tech_lef $::env(TECH_LEF_MAX) -corner max -env_var MERGED_LEF_MAX -no_widen
        }

        set ::env(LIB_SYNTH_COMPLETE) $::env(LIB_SYNTH)
        # merge synthesis libraries
        set ::env(LIB_SYNTH_MERGED) $::env(synthesis_tmpfiles)/merged.lib
        try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/mergeLib.py\
            --output $::env(LIB_SYNTH_MERGED)\
            --name $::env(PDK)_merged\
            {*}$::env(LIB_SYNTH_COMPLETE)

        # trim synthesis library
        set ::env(LIB_SYNTH) $::env(synthesis_tmpfiles)/trimmed.lib
        trim_lib -input $::env(LIB_SYNTH_MERGED)

        # trim resizer library
        if { ! [info exists ::env(LIB_RESIZER_OPT) ] } {
            set ::env(LIB_RESIZER_OPT) [list]
            foreach lib $::env(LIB_SYNTH_COMPLETE) {
                set fbasename [file rootname [file tail $lib]]
                set lib_resizer $::env(synthesis_tmpfiles)/resizer_$fbasename.lib
                file copy -force $lib $lib_resizer
                lappend ::env(LIB_RESIZER_OPT) $lib_resizer
            }

            if { $::env(STD_CELL_LIBRARY_OPT) != $::env(STD_CELL_LIBRARY) } {
                foreach lib $::env(LIB_SYNTH_OPT) {
                    set fbasename [file rootname [file tail $lib]]
                    set lib_resizer $::env(synthesis_tmpfiles)/resizer_opt_$fbasename.lib
                    file copy -force $lib $lib_resizer
                    lappend ::env(LIB_RESIZER_OPT) $lib_resizer
                }
            }
        }

        if { ! [info exists ::env(DONT_USE_CELLS)] } {
            if { $::env(STD_CELL_LIBRARY_OPT) != $::env(STD_CELL_LIBRARY) } {
                set drc_exclude_list "$::env(DRC_EXCLUDE_CELL_LIST) $::env(DRC_EXCLUDE_CELL_LIST_OPT)"
            } else {
                set drc_exclude_list "$::env(DRC_EXCLUDE_CELL_LIST)"
            }
            gen_exclude_list -lib resizer_opt -drc_exclude_list $drc_exclude_list -output $::env(synthesis_tmpfiles)/resizer_opt.exclude.list -drc_exclude_only -create_dont_use_list
        }

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
        set_log ::env(SYNTH_SCRIPT) "$::env(SCRIPTS_DIR)/yosys/synth_top.tcl" $::env(GLB_CFG_FILE) 0
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

    # Convert Tracks
    if { $::env(TRACKS_INFO_FILE) != "" } {
        set tracks_processed $::env(routing_tmpfiles)/config.tracks
        try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/new_tracks.py -i $::env(TRACKS_INFO_FILE) -o $tracks_processed
        set ::env(TRACKS_INFO_FILE_PROCESSED) $tracks_processed
    }

    if { [info exists ::env(EXTRA_GDS_FILES)] } {
        puts_info "Looking for files defined in ::env(EXTRA_GDS_FILES) $::env(EXTRA_GDS_FILES) ..."
        assert_files_exist $::env(EXTRA_GDS_FILES)
    }


    if [catch {exec python3 $::env(OPENLANE_ROOT)/dependencies/verify_versions.py} ::env(VCHECK_OUTPUT)] {
        if { $::env(QUIT_ON_MISMATCHES) == "1" } {
            puts_err $::env(VCHECK_OUTPUT)
            puts_err "Please update your environment. OpenLane will now quit."
            flow_fail
            return -code error
        }
        
        puts_warn "OpenLane may not function properly: $::env(VCHECK_OUTPUT)"
    }

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "openlane design prep"
    return -code ok
}

proc padframe_gen {args} {
    puts_info "Generating Padframe..."
    set options {{-folder required}}
    set flags {}
    parse_key_args "padframe_gen" args arg_values $options flags_map $flags
    set pf_src_tmp [file normalize $arg_values(-folder)]
    #
    set pfg_exec $::env(SCRIPTS_DIR)/padframe_generator.py
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
    set pfg_exec $::env(SCRIPTS_DIR)/padframe_generator.py
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
        {-sdf_path optional}
        {-spef_path optional}
        {-sdc_path optional}
        {-save_path optional}
    }

    set flags {}
    parse_key_args "save_views" args arg_values $options flags_map $flags
    if { [info exists arg_values(-save_path)]\
        && $arg_values(-save_path) != "" } {
        set path "[file normalize $arg_values(-save_path)]"
    } else {
        set path $::env(RESULTS_DIR)/final
    }
    puts_info "Saving final set of views in '$path'..."

    if { [info exists arg_values(-lef_path)] } {
        set destination $path/lef
        file mkdir $destination
        if { [file exists $arg_values(-lef_path)] } {
            file copy -force $arg_values(-lef_path) $destination/$::env(DESIGN_NAME).lef
        }
    }

    if { [info exists arg_values(-mag_path)] } {
        set destination $path/mag
        file mkdir $destination
        if { [file exists $arg_values(-mag_path)] } {
            file copy -force $arg_values(-mag_path) $destination/$::env(DESIGN_NAME).mag
        }
    }

    if { [info exists arg_values(-maglef_path)] } {
        set destination $path/maglef
        file mkdir $destination
        if { [file exists $arg_values(-maglef_path)] } {
            file copy -force $arg_values(-maglef_path) $destination/$::env(DESIGN_NAME).mag
        }
    }

    if { [info exists arg_values(-def_path)] } {
        set destination $path/def
        file mkdir $destination
        if { [file exists $arg_values(-def_path)] } {
            file copy -force $arg_values(-def_path) $destination/$::env(DESIGN_NAME).def
        }
    }

    if { [info exists arg_values(-gds_path)] } {
        set destination $path/gds
        file mkdir $destination
        if { [file exists $arg_values(-gds_path)] } {
            file copy -force $arg_values(-gds_path) $destination/$::env(DESIGN_NAME).gds
        }
    }
    if { [info exists arg_values(-verilog_path)] } {
        set destination $path/verilog/gl
        file mkdir $destination
        if { [file exists $arg_values(-verilog_path)] } {
            file copy -force $arg_values(-verilog_path) $destination/$::env(DESIGN_NAME).v
        }
    }

    if { [info exists arg_values(-spice_path)] } {
        set destination $path/spi/lvs
        file mkdir $destination
        if { [file exists $arg_values(-spice_path)] } {
            file copy -force $arg_values(-spice_path) $destination/$::env(DESIGN_NAME).spice
        }
    }

    if { [info exists arg_values(-spef_path)] } {
        set destination $path/spef
        file mkdir $destination
        if { [file exists $arg_values(-spef_path)] } {
            file copy -force $arg_values(-spef_path) $destination/$::env(DESIGN_NAME).spef
        }
    }

    if { [info exists arg_values(-sdf_path)] } {
        set destination $path/sdf
        file mkdir $destination
        if { [file exists $arg_values(-sdf_path)] } {
            file copy -force $arg_values(-sdf_path) $destination/$::env(DESIGN_NAME).sdf
        }
    }

    if { [info exists arg_values(-sdc_path)] } {
        set destination $path/sdc
        file mkdir $destination
        if { [file exists $arg_values(-sdc_path)] } {
            file copy -force $arg_values(-sdc_path) $destination/$::env(DESIGN_NAME).sdc
        }
    }
}


# to be done after detailed routing and run_magic_antenna_check
proc heal_antenna_violators {args} {
    # requires a pre-existing report containing a list of cells (-pins?)
    # that need the real diode in place of the fake diode:
    # => fixes the routed def
    if { ($::env(DIODE_INSERTION_STRATEGY) == 2) || ($::env(DIODE_INSERTION_STRATEGY) == 5) } {
        increment_index
        TIMER::timer_start
        puts_info "Healing Antenna Violators..."
        if { $::env(USE_ARC_ANTENNA_CHECK) == 1 } {
            #ARC specific
            if { [info exists ::env(ANTENNA_CHECKER_LOG)] } {
                try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/extract_antenna_violators.py -i $::env(ANTENNA_CHECKER_LOG) -o [index_file $::env(routing_reports)/violators.txt]
            } else {
                puts_err "Ran heal_antenna_violators without running the antenna check first."
                flow_fail
            }
        } else {
            #Magic Specific
            set report_file [open [index_file $::env(routing_reports)/antenna_violators.rpt] r]
            set violators [split [string trim [read $report_file]]]
            close $report_file
            # may need to speed this up for extremely huge files using hash tables
            exec echo $violators >> [index_file $::env(routing_reports)/violators.txt]
        }
        #replace violating cells with real diodes
        try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/fake_diode_replace.py -v [index_file $::env(routing_reports)/violators.txt] -d $::env(routing_results)/$::env(DESIGN_NAME).def -f $::env(FAKEDIODE_CELL) -t $::env(DIODE_CELL)
        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "heal antenna violators - custom"
    }
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
            try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/widen_site_lef.py -l $::env(MERGED_LEF_UNPADDED) -w $::env(WIDEN_SITE) -f -o $::env(MERGED_LEF_UNPADDED_WIDENED)
            try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/widen_site_lef.py -l $::env(MERGED_LEF) -w $::env(WIDEN_SITE) -f -o $::env(MERGED_LEF_WIDENED)

        } else {
            try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/widen_site_lef.py -l $::env(MERGED_LEF_UNPADDED) -w $::env(WIDEN_SITE) -o $::env(MERGED_LEF_UNPADDED_WIDENED)
            try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/widen_site_lef.py -l $::env(MERGED_LEF) -w $::env(WIDEN_SITE) -o $::env(MERGED_LEF_WIDENED)
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

    try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/label_macro_pins.py\
        --lef $arg_values(-lef)\
        --input-def $::env(CURRENT_DEF)\
        --netlist-def $arg_values(-netlist_def)\
        --pad-pin-name $arg_values(-pad_pin_name)\
        -o $output_def\
        {*}$extra_args |& tee [index_file $::env(signoff_logs)/label_macro_pins.log] $::env(TERMINAL_OUTPUT)
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "label macro pins - label_macro_pins.py"
}


proc write_verilog {filename args} {
    increment_index
    TIMER::timer_start
    puts_info "Writing Verilog..."
    set ::env(SAVE_NETLIST) $filename

    set options {
        {-def optional}
        {-log optional}
    }
    set flags {
        -canonical
    }
    parse_key_args "write_verilog" args arg_values $options flags_map $flags

    set_if_unset arg_values(-def) $::env(CURRENT_DEF)
    set_if_unset arg_values(-log) /dev/null

    set ::env(INPUT_DEF) $arg_values(-def)

    run_openroad_script $::env(SCRIPTS_DIR)/openroad/write_verilog.tcl -indexed_log [index_file $arg_values(-log)]
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "write verilog - openroad"
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

    try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/set_layer_tracks.py -d $arg_values(-defFile) -l $arg_values(-layer) -v $arg_values(-valuesFile) -o $arg_values(-originalFile)

}

proc run_or_antenna_check {args} {
    TIMER::timer_start
    increment_index
    puts_info "Running OpenROAD Antenna Rule Checker..."
    set antenna_log [index_file $::env(signoff_logs)/antenna.log]
    run_openroad_script $::env(SCRIPTS_DIR)/openroad/antenna_check.tcl -indexed_log $antenna_log
    set ::env(ANTENNA_CHECKER_LOG) $antenna_log
    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "antenna check - openroad"
}

proc run_antenna_check {args} {
    puts_info "Running Antenna Checks..."
    if { $::env(USE_ARC_ANTENNA_CHECK) == 1 } {
        run_or_antenna_check
    } else {
        run_magic_antenna_check
    }
}

proc or_gui {args} {
    run_openroad_script -gui $::env(SCRIPTS_DIR)/openroad/gui.tcl
}

package provide openlane 0.9

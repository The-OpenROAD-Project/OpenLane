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

# Initial Copy
foreach key [array names ::env] {
    set ::initial_env($key) $::env($key)
}

set ::env(SCRIPTS_DIR) "$::env(OPENLANE_ROOT)/scripts"

proc save_state {{start_comment "Saved State"}} {
    puts_info "Saving runtime environment..."
    set_and_log ::env(PDK_ROOT) $::env(PDK_ROOT)
    exec echo "# $start_comment" > $::env(GLB_CFG_FILE)
    foreach index [lsort [array names ::env]] {
        if { ![info exists ::initial_env($index)] || $index == "PDK" || $index == "STD_CELL_LIBRARY" } {
            set_and_log ::env($index) $::env($index)
        }
    }
}

proc set_netlist {args} {
    set options {}

    set flags {
        -lec
    }

    parse_key_args "set_netlist" args arg_values $options flags_map $flags

    set netlist [lindex $args 0]
    set netlist_relative [relpath . $netlist]

    puts_verbose "Changing netlist to '$netlist_relative'..."

    set previous_netlist $::env(CURRENT_NETLIST)
    set ::env(CURRENT_NETLIST) $netlist

    set replace [string map {/ \\/} $::env(CURRENT_NETLIST)]
    try_exec sed -i.bak -e "s/\\(set ::env(CURRENT_NETLIST)\\).*/\\1 $replace/" "$::env(GLB_CFG_FILE)"
    exec rm -f "$::env(GLB_CFG_FILE).bak"

    if { [info exists flags_map(-lec)] && $::env(LEC_ENABLE) && [file exists $previous_netlist] } {
        logic_equiv_check -lhs $previous_netlist -rhs $netlist
    }
}

proc set_def {def} {
    set def_relative [relpath . $def]
    puts_verbose "Changing layout to '$def_relative'..."
    set ::env(CURRENT_DEF) $def
    set replace [string map {/ \\/} $def]
    exec sed -i.bak -e "s/\\(set ::env(CURRENT_DEF)\\).*/\\1 $replace/" "$::env(GLB_CFG_FILE)"
    exec rm -f "$::env(GLB_CFG_FILE).bak"
}

proc set_odb {odb} {
    set odb_relative [relpath . $odb]
    puts_verbose "Changing database to '$odb_relative'..."
    set ::env(CURRENT_ODB) $odb
    set replace [string map {/ \\/} $odb]
    exec sed -i.bak -e "s/\\(set ::env(CURRENT_ODB)\\).*/\\1 $replace/" "$::env(GLB_CFG_FILE)"
    exec rm -f "$::env(GLB_CFG_FILE).bak"
}

proc set_sdc {sdc} {
    set sdc_relative [relpath . $sdc]
    puts_verbose "Changing timing constraints to '$sdc_relative'..."
    set ::env(CURRENT_SDC) $sdc
    set replace [string map {/ \\/} $sdc]
    exec sed -i.bak -e "s/\\(set ::env(CURRENT_SDC)\\).*/\\1 $replace/" "$::env(GLB_CFG_FILE)"
    exec rm -f "$::env(GLB_CFG_FILE).bak"
}

proc set_guide {guide} {
    set guide_relative [relpath . $guide]
    puts_verbose "Changing guide to '$guide_relative'..."
    set ::env(CURRENT_GUIDE) $guide
    set replace [string map {/ \\/} $guide]
    exec sed -i.bak -e "s/\\(set ::env(CURRENT_GUIDE)\\).*/\\1 $replace/" "$::env(GLB_CFG_FILE)"
    exec rm -f "$::env(GLB_CFG_FILE).bak"
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

    set merged_lef_path $::env(TMP_DIR)/merged.$arg_values(-corner).lef

    if { ![file exists $arg_values(-tech_lef)] } {
        if { $arg_values(-env_var) == "MERGED_LEF" } {
            puts_err "Nominal process corner '$arg_values(-tech_lef)' not found."
            throw_error
        }
        puts_info "'$arg_values(-tech_lef)' not found, skipping..."
        return
    }
    puts_info "Preparing LEF files for the $arg_values(-corner) corner..."

    if { $arg_values(-corner) == "nom" } {
        puts_verbose "Extracting the number of available metal layers from $arg_values(-tech_lef)..."

        if { [info exists ::env(METAL_LAYER_NAMES)] } {
            set ::env(TECH_METAL_LAYERS) $::env(METAL_LAYER_NAMES)
        } else {
            try_exec $::env(OPENROAD_BIN) -exit -no_init -python\
                $::env(SCRIPTS_DIR)/odbpy/lefutil.py get_metal_layers\
                -o $::env(TMP_DIR)/layers.list\
                $arg_values(-tech_lef)

            set ::env(TECH_METAL_LAYERS)  [cat $::env(TMP_DIR)/layers.list]
        }
        set ::env(MAX_METAL_LAYER) [llength $::env(TECH_METAL_LAYERS)]

        puts_verbose "The available metal layers ($::env(MAX_METAL_LAYER)) are $::env(TECH_METAL_LAYERS)."
        puts_verbose "Merging LEF Files..."
    }

    try_exec $::env(SCRIPTS_DIR)/mergeLef.py\
        -o $merged_lef_path\
        -i $arg_values(-tech_lef) $arg_values(-cell_lef)\
        |& tee $::env(TERMINAL_OUTPUT)

    set mlp_relative [relpath . $merged_lef_path]
    puts_verbose "Created merged LEF without pads at '$mlp_relative'..."

    # Merged Extra Lefs (if they exist)
    if { [info exist ::env(EXTRA_LEFS)] } {
        try_exec $::env(SCRIPTS_DIR)/mergeLef.py\
            -o $merged_lef_path\
            -i $merged_lef_path {*}$::env(EXTRA_LEFS)\
            |& tee $::env(TERMINAL_OUTPUT)
        puts_verbose "Added extra lefs to '$mlp_relative'..."
    }

    # Merge optimization TLEF/CLEF (if exists)
    if { [info exist ::env(STD_CELL_LIBRARY_OPT)] && $::env(STD_CELL_LIBRARY_OPT) != $::env(STD_CELL_LIBRARY) } {
        try_exec $::env(SCRIPTS_DIR)/mergeLef.py\
            -o $merged_lef_path\
            -i $merged_lef_path $::env(TECH_LEF_OPT) {*}$::env(CELLS_LEF_OPT) |& tee $::env(TERMINAL_OUTPUT)
        puts_verbose "Added optimization library tech lef and cell lefs to '$mlp_relative'..."
    }

    # Merge pads (if GPIO_PADS_LEF exists)
    if { $::env(USE_GPIO_PADS) } {
        if { [info exists ::env(USE_GPIO_ROUTING_LEF)] && $::env(USE_GPIO_ROUTING_LEF)} {
            set ::env(GPIO_PADS_LEF) $::env(GPIO_PADS_LEF_CORE_SIDE)
        }

        puts_verbose "Merging the following GPIO LEF views: $::env(GPIO_PADS_LEF)..."
        try_exec $::env(SCRIPTS_DIR)/mergeLef.py\
            -o $merged_lef_path\
            -i $merged_lef_path {*}$::env(GPIO_PADS_LEF)
        puts_verbose "Created '$mlp_relative' with gpio pads."
    }

    set ::env($arg_values(-env_var)) $merged_lef_path
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
        puts $out ""
        close $out
    }

    # If you're not told to only use the drc exclude list, merge the two lists
    if { (![info exists flags_map(-drc_exclude_only)]) && [file exists $arg_values(-synth_exclude_list)] } {
        foreach list_file $arg_values(-synth_exclude_list) {
            set out  [open $arg_values(-output) a]
            if { [file exists $list_file] } {
                set in [open $list_file]
                fcopy $in $out
                close $in
            }
            puts $out ""
            close $out
        }
    }

    if { [file exists $arg_values(-output)] } {
        puts_verbose "Creating ::env(DONT_USE_CELLS)..."
        set x [cat "$arg_values(-output)"]
        set y [split $x]
        set ::env(DONT_USE_CELLS) [join $y " "]
        puts_verbose "Created ::env(DONT_USE_CELLS): {$::env(DONT_USE_CELLS)}"
    }
}

proc trim_lib {args} {
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

    puts_verbose "Trimming liberty files \{$arg_values(-input)\} into $arg_values(-output)..."

    set no_synth_list "$::env(NO_SYNTH_CELL_LIST)"
    if { [info exists ::env(NO_SYNTH_CELL_LIST_OPT)] } {
        set no_synth_list "$no_synth_list $::env(NO_SYNTH_CELL_LIST_OPT)"
    }

    if { [info exists flags_map(-drc_exclude_only)] } {
        gen_exclude_list -lib $arg_values(-output) -drc_exclude_only
    } else {
        gen_exclude_list -lib $arg_values(-output) -synth_exclude_list $no_synth_list
    }

    # Trim the liberty with the generated list, if it exists.
    if { ! [file exists $arg_values(-output).exclude.list] } {
        set fid [open $arg_values(-output).exclude.list w]
        close $fid
    }

    try_exec python3 $::env(SCRIPTS_DIR)/libtrim.py\
        --cell-file $arg_values(-output).exclude.list\
        --output $arg_values(-output)\
        {*}$arg_values(-input)
}

proc merge_lib {args} {
    set options {
        {-inputs required}
        {-output required}
        {-name optional}
    }

    set flags {}

    parse_key_args "merge_lib" args arg_values $options flags_map $flags

    puts_verbose "Merging liberty files \{{*}$arg_values(-inputs)\} into \{$arg_values(-output)\}..."

    set_if_unset arg_values(-name) "$::env(PDK)_merged"

    try_exec python3 $::env(SCRIPTS_DIR)/mergeLib.py\
        --output $arg_values(-output)\
        --name $arg_values(-name)\
        {*}$arg_values(-inputs)
}

proc source_config {args} {
    set options {
        {-run_path optional}
        {-expose optional}
    }
    set flags {-process_info_only}

    parse_key_args "source_config" args arg_values $options flags_map $flags

    if { ![info exists arg_values(-run_path)] } {
        if { ![info exists ::env(RUN_DIR)] } {
            puts_err "source_config needs either the -run_path option or ::env(RUN_DIR) set."
            throw_error
        } else {
            set_if_unset $arg_values(-run_path) $::env(RUN_DIR)
        }
    }
    set_if_unset arg_values(-expose) ""

    set exposed_vars [split $arg_values(-expose) ","]

    set config_file [lindex $args 0]
    set config_file_rel [relpath . $config_file]

    if { ![file exists $config_file] } {
        puts_err "$config_file_rel error: file not found"
        throw_error
    }

    set ext [file extension $config_file]
    set config_in_path $arg_values(-run_path)/config_in.tcl

    if { $ext == ".tcl" } {
        # for trusted end-users only
        if { [info exist flags_map(-process_info_only)] } {
            if { [catch {exec python3 $::env(SCRIPTS_DIR)/config/tcl.py extract-process-info --output $config_in_path $config_file} errmsg] } {
                puts_err $errmsg
                exit -1
            }
        } else {
            exec cp $config_file $config_in_path
        }
    } elseif { $ext == ".json" } {
        set arg_list [list]

        lappend arg_list from-json
        lappend arg_list $config_file

        if { [info exist flags_map(-process_info_only)] } {
            lappend arg_list --extract-process-info
        }

        foreach exposed_var $exposed_vars {
            lappend arg_list --expose $exposed_var
        }

        lappend arg_list --output $config_in_path

        if { [catch {exec python3 $::env(SCRIPTS_DIR)/config/tcl.py {*}$arg_list} errmsg] } {
            puts_err $errmsg
            exit -1
        }

    } else {
        puts_err "$config_file error: unsupported extension '$ext'"
        throw_error
    }


    source $config_in_path
}

set global_verbose_level 0
proc set_verbose {level} {
    global global_verbose_level
    set global_verbose_level $level
    set ::env(TERMINAL_OUTPUT) "/dev/null"
    if { $global_verbose_level >= 2 } {
        set ::env(TERMINAL_OUTPUT) ">&@stdout"
    }
}

proc load_overrides {args} {
    set options {}
    set flags {-process_info_only}
    parse_key_args "load_overrides" args arg_values $options flags_map $flags

    set overrides [lindex $args 0]

    set process_info_allowlist [list]
    lappend process_info_allowlist PDK
    lappend process_info_allowlist STD_CELL_LIBRARY
    lappend process_info_allowlist STD_CELL_LIBRARY_OPT

    set env_overrides [split $overrides ',']
    foreach override $env_overrides {
        set kva [split $override '=']
        set key [lindex $kva 0]
        set value [lindex $kva 1]
        if { [info exists flags_map(-process_info_only)] || [lsearch -exact $process_info_allowlist $key] != -1} {
            set ::env(${key}) $value
        }
    }
}

proc prep {args} {
    set ::env(timer_start) [clock seconds]
    TIMER::timer_start
    set options {
        {-design optional}
        {-tag optional}
        {-config_file optional}
        {-run_path optional}
        {-src optional}
        {-override_env optional}
        {-verbose optional}
        {-test_mismatches optional}
        {-expose_env optional}
    }

    set flags {
        -init_design_config
        -add_to_designs
        -overwrite
        -last_run
        -ignore_mismatches
    }

    set args_copy $args
    parse_key_args "prep" args arg_values $options flags_map $flags

    set_if_unset arg_values(-test_mismatches) "all"
    set_if_unset arg_values(-src) ""
    set_if_unset arg_values(-design) "."
    set_if_unset arg_values(-verbose) 0
    set_if_unset arg_values(-expose_env) ""

    if [catch {exec python3 $::env(OPENLANE_ROOT)/dependencies/verify_versions.py $arg_values(-test_mismatches)} ::env(VCHECK_OUTPUT)] {
        if { ![info exists flags_map(-ignore_mismatches)]} {
            puts_err $::env(VCHECK_OUTPUT)
            puts_err "Please update your environment. OpenLane will now quit."
            exit -1
        }

        puts_warn "OpenLane may not function properly: $::env(VCHECK_OUTPUT)"
    }

    # Normalize Design Directory
    set ::env(DESIGN_DIR) [file normalize $arg_values(-design)]
    if { ![file exists $::env(DESIGN_DIR)] } {
        set ::env(DESIGN_DIR) [file normalize $::env(OPENLANE_ROOT)/designs/$arg_values(-design)]
    }

    # Create the design (if applicable)
    if { [info exists flags_map(-init_design_config)] } {
        set filename "$::env(DESIGN_DIR)/config.json"

        if { [info exists arg_values(-config_file)] } {
            set filename $arg_values(-config_file)
        }

        set basename [file tail $filename]

        set arg_list [list]

        lappend arg_list --design-dir $::env(DESIGN_DIR)
        lappend arg_list --config-file-name $basename
        lappend arg_list --design-name $arg_values(-design)
        if { [info exists flags_map(-add_to_designs)] } {
            lappend arg_list --add-to-designs
        }
        lappend arg_list {*}$arg_values(-src)

        set filename [exec python3 $::env(SCRIPTS_DIR)/config/init.py {*}$arg_list]

        set filename_rel [relpath . $filename]

        puts_success "$filename_rel created with the default configuration. Please update the values as you see fit."
        exit 0
    }

    # Check Design Directory
    if { ![file exists $::env(DESIGN_DIR)] } {
        puts_err "Design $arg_values(-design) not found."
        exit -1
    }

    # Output
    set_if_unset arg_values(-verbose) "0"
    set_verbose $arg_values(-verbose)

    # Extract or Create Run Tag and Run Directory
    set ::env(START_TIME) [clock format [clock seconds] -format %Y.%m.%d_%H.%M.%S ]

    if { [info exists flags_map(-last_run)] } {
        if { [info exists arg_values(-tag)] } {
            puts_err "Cannot specify a tag with -last_run set."
            throw_error
        }

        set arg_values(-tag) [exec python3 ./scripts/most_recent_run.py $::env(DESIGN_DIR)/runs]
    }

    set_if_unset arg_values(-tag) "RUN_$::env(START_TIME)"
    set tag $arg_values(-tag)

    set ::env(CONFIGS) [cat $::env(OPENLANE_ROOT)/configuration/load_order.txt]

    if { [info exists arg_values(-run_path)] } {
        set run_path "[file normalize $arg_values(-run_path)]/$tag"
    } else {
        set run_path $::env(DESIGN_DIR)/runs/$tag
    }

    file mkdir $run_path

    # Configuration
    ## 0. Global Configurations
    if { [info exists arg_values(-config_file)] } {
        set ::env(DESIGN_CONFIG) $arg_values(-config_file)
    } else {
        if { [file exists $::env(DESIGN_DIR)/config.tcl] } {
            set ::env(DESIGN_CONFIG) $::env(DESIGN_DIR)/config.tcl
        } elseif { [file exists $::env(DESIGN_DIR)/config.json] } {
            set ::env(DESIGN_CONFIG) $::env(DESIGN_DIR)/config.json
        } else {
            puts_err "No design configuration (config.json/config.tcl) found in $::env(DESIGN_DIR)."
            throw_error
        }
    }

    foreach config $::env(CONFIGS) {
        source $::env(OPENLANE_ROOT)/configuration/$config
    }

    ## 1. Configuration File (Process Info Only)
    set config_file_rel [relpath . $::env(DESIGN_CONFIG)]

    puts_info "Using configuration in '$config_file_rel'..."
    source_config -process_info_only\
        -run_path $run_path $::env(DESIGN_CONFIG)\
        -expose $arg_values(-expose_env)

    ## 2. Overrides (Process Info Only)
    if { [info exists arg_values(-override_env)] } {
        load_overrides -process_info_only $arg_values(-override_env)
    }

    if { ! [info exists ::env(PDK_ROOT)] || $::env(PDK_ROOT) == "" } {
        puts_err "PDK_ROOT is not specified. Please make sure you have it set."
        exit -1
    } else {
        puts_info "PDK Root: $::env(PDK_ROOT)"
    }

    if { ! [info exists ::env(PDK)] } {
        puts_err "PDK is not specified."
        exit -1
    } else {
        puts_info "Process Design Kit: $::env(PDK)"
        puts_verbose "Setting PDKPATH to $::env(PDK_ROOT)/$::env(PDK)"
        set ::env(PDKPATH) $::env(PDK_ROOT)/$::env(PDK)
    }

    ## 3. PDK-Specific Config
    if { [info exists ::env(STD_CELL_LIBRARY)] } {
        set scl_path "$::env(PDK_ROOT)/$::env(PDK)/libs.ref/$::env(STD_CELL_LIBRARY)"
        if { ![file exists $scl_path] } {
            puts_err "Standard Cell Library '$::env(STD_CELL_LIBRARY)' not found in PDK."
            exit -1
        }
    }
    set pdk_config $::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/config.tcl
    source $pdk_config

    ## 4. SCL-Specific Config
    puts_info "Standard Cell Library: $::env(STD_CELL_LIBRARY)"
    set ::env(SCLPATH) $::env(PDKPATH)/$::env(STD_CELL_LIBRARY)
    if { ! [info exists ::env(STD_CELL_LIBRARY_OPT)] } {
        set ::env(STD_CELL_LIBRARY_OPT) $::env(STD_CELL_LIBRARY)
        puts_verbose "Optimization SCL also set to $::env(STD_CELL_LIBRARY_OPT)."
    } else {
        puts_info "Optimization Standard Cell Library: $::env(STD_CELL_LIBRARY_OPT)"
    }

    if {![info exists ::env(FP_PDN_CFG)]} {
        set ::env(FP_PDN_CFG) $::env(SCRIPTS_DIR)/openroad/common/pdn_cfg.tcl
    }

    set scl_config $::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(STD_CELL_LIBRARY)/config.tcl
    source $scl_config

    ### 4a. Optimization SCL Config (If Applicable)
    set opt_scl_used [expr {$::env(STD_CELL_LIBRARY)} ne {$::env(STD_CELL_LIBRARY_OPT)}]
    if { $opt_scl_used } {
        set opt_config $::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(STD_CELL_LIBRARY_OPT)/config.tcl
        set opt_config_out $run_path/config_opt.tcl

        exec python3 $::env(SCRIPTS_DIR)/config/extract_opt_variables.py\
            --output $opt_config_out\
            --pdk-root $::env(PDK_ROOT)\
            --pdk $::env(PDK)\
            --opt-scl $::env(STD_CELL_LIBRARY_OPT)\
            $pdk_config\
            $opt_config

        source $opt_config_out
    }

    ## 5. Design-Specific Config
    source_config\
        -run_path $run_path $::env(DESIGN_CONFIG)\
        -expose $arg_values(-expose_env)

    ## 6. Overrides
    if { [info exists arg_values(-override_env)] } {
        load_overrides $arg_values(-override_env)
    }

    set ::env(OPENLANE_VERBOSE) $arg_values(-verbose)

    # DEPRECATED CONFIGS
    ## PDK
    handle_deprecated_pdk_config SYNTH_MAX_TRAN MAX_TRANSITION_CONSTRAINT
    handle_deprecated_pdk_config SYNTH_MAX_FANOUT MAX_FANOUT_CONSTRAINT
    handle_deprecated_pdk_config SYNTH_CAP_LOAD OUTPUT_CAP_LOAD
    handle_deprecated_pdk_config WIRE_RC_LAYER DATA_WIRE_RC_LAYER

    ## Flow
    handle_diode_insertion_strategy

    handle_deprecated_config SYNTH_TOP_LEVEL SYNTH_ELABORATE_ONLY

    handle_deprecated_config VERILATOR_RELATIVE_INCLUDES LINTER_RELATIVE_INCLUDES

    handle_deprecated_config FP_HORIZONTAL_HALO FP_PDN_HORIZONTAL_HALO
    handle_deprecated_config FP_VERTICAL_HALO FP_PDN_VERTICAL_HALO

    handle_deprecated_config LIB_RESIZER_OPT RSZ_LIB
    handle_deprecated_config UNBUFFER_NETS RSZ_DONT_TOUCH_RX

    ### Checkers/Quitting
    handle_deprecated_config CHECK_ASSIGN_STATEMENTS QUIT_ON_ASSIGN_STATEMENTS
    handle_deprecated_config CHECK_UNMAPPED_CELLS QUIT_ON_UNMAPPED_CELLS
    handle_deprecated_config QUIT_ON_VERILATOR_WARNINGS QUIT_ON_LINTER_WARNINGS
    handle_deprecated_config QUIT_ON_VERILATOR_ERRORS QUIT_ON_LINTER_ERRORS

    ### Flow Control
    handle_deprecated_config CLOCK_TREE_SYNTH RUN_CTS
    handle_deprecated_config TAP_DECAP_INSERTION RUN_TAP_DECAP_INSERTION
    handle_deprecated_config RUN_ROUTING_DETAILED RUN_DRT
    handle_deprecated_config FILL_INSERTION RUN_FILL_INSERTION
    handle_deprecated_config RUN_VERILATOR RUN_LINTER

    ### PDN
    handle_deprecated_config FP_PDN_RAILS_LAYER FP_PDN_RAIL_LAYER
    handle_deprecated_config FP_PDN_UPPER_LAYER FP_PDN_HORIZONTAL_LAYER
    handle_deprecated_config FP_PDN_LOWER_LAYER FP_PDN_VERTICAL_LAYER
    handle_deprecated_config PDN_CFG FP_PDN_CFG

    ### GLB_RT -> GRT (Document using ‡)
    handle_deprecated_config GLB_RT_ALLOW_CONGESTION GRT_ALLOW_CONGESTION
    handle_deprecated_config GLB_RT_OVERFLOW_ITERS GRT_OVERFLOW_ITERS
    handle_deprecated_config GLB_RT_ANT_ITERS GRT_ANT_ITERS
    handle_deprecated_config GLB_RT_ESTIMATE_PARASITICS GRT_ESTIMATE_PARASITICS
    handle_deprecated_config GLB_RT_MAX_DIODE_INS_ITERS GRT_MAX_DIODE_INS_ITERS
    handle_deprecated_config GLB_RT_OBS GRT_OBS
    handle_deprecated_config GLB_RT_ADJUSTMENT GRT_ADJUSTMENT
    handle_deprecated_config GLB_RT_MACRO_EXTENSION GRT_MACRO_EXTENSION
    handle_deprecated_config GLB_RT_LAYER_ADJUSTMENTS GRT_LAYER_ADJUSTMENTS

    ### Spelling (No need to document)
    handle_deprecated_config CELL_PAD_EXECLUDE CELL_PAD_EXCLUDE
    handle_deprecated_config SYNTH_CLOCK_UNCERTAINITY SYNTH_CLOCK_UNCERTAINTY

    #
    ############################
    # Prep directories and files
    ############################
    #

    set skip_basic_prep 0

    set ::env(RUN_TAG)		"$tag"
    set ::env(RUN_DIR) 		"$run_path"
    set ::env(RESULTS_DIR) 	"$::env(RUN_DIR)/results"
    set ::env(TMP_DIR) 		"$::env(RUN_DIR)/tmp"
    set ::env(LOGS_DIR)     "$::env(RUN_DIR)/logs"
    set ::env(REPORTS_DIR) 	"$::env(RUN_DIR)/reports"
    set ::env(GLB_CFG_FILE) "$::env(RUN_DIR)/config.tcl"

    puts_info "Run Directory: $::env(RUN_DIR)"

    if { [file exists $::env(GLB_CFG_FILE)] } {
        if { [info exists flags_map(-overwrite)] } {
            puts_info "Removing existing $::env(RUN_DIR)..."
            after 1000
            file delete -force $::env(RUN_DIR)
        } else {
            puts_err "A run for $::env(DESIGN_NAME) with tag '$tag' already exists. Pass the -overwrite option to overwrite it or use a different tag"
            throw_error
        }
    }

    # file mkdir works like shell mkdir -p, i.e., its OK if it already exists
    file mkdir $::env(RESULTS_DIR) $::env(TMP_DIR) $::env(LOGS_DIR) $::env(REPORTS_DIR)

    set run_subfolder_structure [list \
        synthesis\
        floorplan\
        placement\
        cts\
        routing\
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

    if { ![info exists ::env(PL_TARGET_DENSITY)] } {
        set ::env(PL_TARGET_DENSITY) [expr ($::env(FP_CORE_UTIL) + 10.0 + (5 * $::env(GPL_CELL_PADDING))) / 100.0]
    }

    set util 	$::env(FP_CORE_UTIL)
    set density $::env(PL_TARGET_DENSITY)

    # Fill config file
    save_state "Initial Config"

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
        set ::env(LIB_SYNTH_MERGED) $::env(synthesis_tmpfiles)/merged.lib

        merge_lib\
            -output $::env(LIB_SYNTH_MERGED)\
            -name $::env(PDK)_merged\
            -inputs $::env(LIB_SYNTH_COMPLETE)

        # trim synthesis library
        set ::env(LIB_SYNTH) $::env(synthesis_tmpfiles)/trimmed.lib
        trim_lib\
            -output $::env(LIB_SYNTH)\
            -input $::env(LIB_SYNTH_MERGED)

        # set resizer library
        # trimming behavior is done using DONT_USE_CELLS
        if { ! [info exists ::env(RSZ_LIB) ] } {
            set ::env(RSZ_LIB) [list]
            lappend ::env(RSZ_LIB) $::env(LIB_SYNTH_COMPLETE)
            if { $::env(STD_CELL_LIBRARY_OPT) != $::env(STD_CELL_LIBRARY) } {
                lappend ::env(RSZ_LIB) $::env(LIB_SYNTH_OPT)
            }
        }

        if { ! [info exists ::env(RSZ_LIB_FASTEST)] } {
            set ::env(RSZ_LIB_FASTEST) [list]
            lappend ::env(RSZ_LIB_FASTEST) $::env(LIB_FASTEST)
        }

        if { ! [info exists ::env(RSZ_LIB_SLOWEST)] } {
            set ::env(RSZ_LIB_SLOWEST) [list]
            lappend ::env(RSZ_LIB_SLOWEST) $::env(LIB_SLOWEST)
        }

        # trim the lib for CTS to only exclude cells with drc errors
        if { ! [info exists ::env(LIB_CTS) ] } {
            set ::env(LIB_CTS) $::env(cts_tmpfiles)/cts.lib
            trim_lib\
                -output $::env(LIB_CTS)\
                -input $::env(LIB_SYNTH_COMPLETE)\
                -drc_exclude_only
        }

        if { ! [info exists ::env(LIB_CTS_FASTEST) ] } {
            set ::env(LIB_CTS_FASTEST) $::env(cts_tmpfiles)/cts-fastest.lib
            trim_lib\
                -output $::env(LIB_CTS_FASTEST)\
                -input $::env(LIB_FASTEST)\
                -drc_exclude_only
        }

        if { ! [info exists ::env(LIB_CTS_SLOWEST) ] } {
            set ::env(LIB_CTS_SLOWEST) $::env(cts_tmpfiles)/cts-slowest.lib
            trim_lib\
                -output $::env(LIB_CTS_SLOWEST)\
                -input $::env(LIB_SLOWEST)\
                -drc_exclude_only
        }

        if { ! [info exists ::env(DONT_USE_CELLS)] } {
            if { $::env(STD_CELL_LIBRARY_OPT) != $::env(STD_CELL_LIBRARY) } {
                set drc_exclude_list "$::env(DRC_EXCLUDE_CELL_LIST) $::env(DRC_EXCLUDE_CELL_LIST_OPT)"
            } else {
                set drc_exclude_list "$::env(DRC_EXCLUDE_CELL_LIST)"
            }

            puts_verbose $drc_exclude_list

            gen_exclude_list \
                -lib resizer_opt \
                -drc_exclude_list $drc_exclude_list \
                -drc_exclude_only \
                -output $::env(synthesis_tmpfiles)/resizer_opt.exclude.list
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


        # Convert Tracks
        if { $::env(TRACKS_INFO_FILE) != "" } {
            set tracks_processed $::env(routing_tmpfiles)/config.tracks
            try_exec python3 $::env(SCRIPTS_DIR)/new_tracks.py -i $::env(TRACKS_INFO_FILE) -o $tracks_processed
            set ::env(TRACKS_INFO_FILE_PROCESSED) $tracks_processed
        }

        set ::env(BASIC_PREP_COMPLETE) {1}
    }

    if { $::env(SYNTH_ELABORATE_ONLY) } {
        set_and_log ::env(SYNTH_SCRIPT) "$::env(SCRIPTS_DIR)/yosys/elaborate.tcl"
    }
    set_and_log ::env(SYNTH_OPT) 0
    set_and_log ::env(PL_INIT_COEFF) 0.00002
    set_and_log ::env(PL_IO_ITER) 5

    if { ! [info exists ::env(CURRENT_INDEX)] } {
        set_and_log ::env(CURRENT_INDEX) 0
    }

    if { ! [info exists ::env(CURRENT_DEF)] } {
        set_and_log ::env(CURRENT_DEF) 0
    }

    if { ! [info exists ::env(CURRENT_GUIDE)] } {
        set_and_log ::env(CURRENT_GUIDE) 0
    }

    if { ! [info exists ::env(CURRENT_NETLIST)] } {
        set_and_log ::env(CURRENT_NETLIST) 0
    }

    if { ! [info exists ::env(CURRENT_POWERED_NETLIST)] } {
        set_and_log ::env(CURRENT_POWERED_NETLIST) 0
    }

    if { ! [info exists ::env(CURRENT_ODB)] } {
        set_and_log ::env(CURRENT_ODB) 0
    }

    if { [file exists $::env(PDK_ROOT)/$::env(PDK)/SOURCES] } {
        file copy -force $::env(PDK_ROOT)/$::env(PDK)/SOURCES $::env(RUN_DIR)/PDK_SOURCES
    }

    if { [info exists ::env(OPENLANE_COMMIT) ] } {
        try_exec echo "OpenLane $::env(OPENLANE_COMMIT)" > $::env(RUN_DIR)/OPENLANE_COMMIT
    }

    if { [info exists ::env(EXTRA_GDS_FILES)] } {
        puts_verbose "Verifying existence of files defined in ::env(EXTRA_GDS_FILES)..."
        assert_files_exist "$::env(EXTRA_GDS_FILES)"
    }

    if { [info exists ::env(VERILOG_STA_NETLISTS)] } {
        puts_verbose "Verifying existence of files defined in ::env(VERILOG_STA_NETLISTS)..."
        assert_files_exist "$::env(VERILOG_STA_NETLISTS)"
    }

    if { [info exists ::env(EXTRA_SPEFS)] } {
        if { [expr [llength $::env(EXTRA_SPEFS)] % 4] != 0 } {
            puts_err "Please define EXTRA_SPEFS correctly. i.e. : <module1> <min1> <nom1> <max1> <module2> ..."
            flow_fail
        }
    }

    if { [info exists ::env(VSRC_LOC_FILES)] } {
        if { [expr [llength $::env(VSRC_LOC_FILES)] % 2] != 0 } {
            puts_err "Please define VSRC_LOC_FILES correctly. i.e. : net1 file1 net2 file2 ..."
            flow_fail
        }
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
        {-nl_path optional}
        {-pnl_path optional}
        {-spice_path optional}
        {-sdf_path optional}
        {-mc_sdf_dir optional}
        {-spef_path optional}
        {-mc_spef_dir optional}
        {-sdc_path optional}
        {-lib_path optional}
        {-save_path optional}
    }

    set flags {}
    parse_key_args "save_views" args arg_values $options flags_map $flags


    if { [info exists arg_values(-verilog_path)] } {
        puts_warn "The argument -verilog_path is ambiguous and deprecated."
        puts_warn "You may use either -nl_path for unpowered or -pnl_path for powered netlists."

        if { ![info exists arg_values(-pnl_path)] } {
            puts_warn "Setting -pnl_path to '$arg_values(-verilog_path)'..."
            set arg_values(-pnl_path) $arg_values(-verilog_path)
        }
    }

    if { [info exists arg_values(-save_path)]\
        && $arg_values(-save_path) != "" } {
        set path "[file normalize $arg_values(-save_path)]"
    } else {
        set path $::env(RESULTS_DIR)/final
    }
    set path_rel [relpath . $path]
    puts_info "Saving current set of views in '$path_rel'..."

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

    if { [info exists arg_values(-nl_path)] } {
        set destination $path/verilog/gl
        file mkdir $destination
        if { [file exists $arg_values(-nl_path)] } {
            set nl_file_path $destination/$::env(DESIGN_NAME).nl.v
            set f [open $nl_file_path w]
            puts $f "// This is the unpowered netlist."
            puts $f [cat $arg_values(-nl_path)]
            close $f
        }
    }

    if { [info exists arg_values(-pnl_path)] } {
        set destination $path/verilog/gl
        file mkdir $destination
        if { [file exists $arg_values(-pnl_path)] } {
            file copy -force $arg_values(-pnl_path) $destination/$::env(DESIGN_NAME).v
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

    if { [info exists arg_values(-mc_spef_dir)] } {
        set destination $path/spef/multicorner
        if { [file exists $arg_values(-mc_spef_dir)] } {
            file mkdir $destination
            file copy -force {*}[glob $arg_values(-mc_spef_dir)/*] $destination
        }
    }

    if { [info exists arg_values(-sdf_path)] } {
        set destination $path/sdf
        file mkdir $destination
        if { [file exists $arg_values(-sdf_path)] } {
            file copy -force $arg_values(-sdf_path) $destination/$::env(DESIGN_NAME).sdf
        }
    }


    if { [info exists arg_values(-mc_sdf_dir)] } {
        set destination $path/sdf/multicorner
        if { [file exists $arg_values(-mc_sdf_dir)] } {
            file delete -force $destination
            file copy -force $arg_values(-mc_sdf_dir) $destination
        }
    }


    if { [info exists arg_values(-sdc_path)] } {
        set destination $path/sdc
        file mkdir $destination
        if { [file exists $arg_values(-sdc_path)] } {
            file copy -force $arg_values(-sdc_path) $destination/$::env(DESIGN_NAME).sdc
        }
    }

    if { [info exists arg_values(-lib_path)] } {
        set destination $path/lib
        file mkdir $destination
        if { [file exists $arg_values(-lib_path)] } {
            file copy -force $arg_values(-lib_path) $destination/$::env(DESIGN_NAME).lib
        }
    }
}


# to be done after detailed routing and run_magic_antenna_check
proc heal_antenna_violators {args} {
    puts_err "heal_antenna_violators is no longer supported"
    throw_error
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


    set_if_unset arg_values(-output) $::env(CURRENT_DEF)
    set_if_unset arg_values(-extra_args) ""
    set_if_unset arg_values(-pad_pin_name) ""

    manipulate_layout $::env(SCRIPTS_DIR)/odbpy/label_macro_pins.py\
        -indexed_log [index_file $::env(signoff_logs)/label_macro_pins.log]\
        -output_def $arg_values(-output)\
        -output $arg_values(-output).odb\
        -input $::env(CURRENT_ODB) \
        --netlist-def $arg_values(-netlist_def)\
        --pad-pin-name $arg_values(-pad_pin_name)\
        {*}$arg_values(-extra_args)

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "label macro pins - label_macro_pins.py"
}


proc write_verilog {args} {
    set options {
        {-def optional}
        {-indexed_log optional}
        {-powered_to optional}
    }
    set flags {-no_global_connect}
    parse_key_args "write_verilog" args arg_values $options flags_map $flags

    set_if_unset arg_values(-indexed_log) /dev/null

    increment_index
    TIMER::timer_start
    puts_info "Writing Verilog (log: [relpath . $arg_values(-indexed_log)])..."

    set filename [lindex $args 0]

    set save_arg "odb=/dev/null,netlist=$filename"

    if { [info exists arg_values(-powered_to)] } {
        set save_arg "$save_arg,powered_netlist=$arg_values(-powered_to)"
    }

    if { [info exists flags_map(-no_global_connect)] } {
        set ::env(WRITE_VIEWS_NO_GLOBAL_CONNECT) 1
    }

    set arg_list [list]
    lappend arg_list -indexed_log $arg_values(-indexed_log)
    lappend arg_list -save $save_arg
    set current_def_backup $::env(CURRENT_DEF)
    if { [info exists arg_values(-def)] } {
        set ::env(CURRENT_DEF) $arg_values(-def)
        lappend arg_list -def_in
    }

    run_openroad_script $::env(SCRIPTS_DIR)/openroad/write_views.tcl\
        {*}$arg_list

    set $::env(CURRENT_DEF) $current_def_backup

    if { [info exists flags_map(-no_global_connect)] } {
        set ::env(WRITE_VIEWS_NO_GLOBAL_CONNECT) 0
    }

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "write verilog - openroad"
}

proc run_or_antenna_check {args} {
    increment_index
    TIMER::timer_start
    set log [index_file $::env(signoff_logs)/arc.log]

    puts_info "Running OpenROAD Antenna Rule Checker (log: [relpath . $log])..."

    run_openroad_script $::env(SCRIPTS_DIR)/openroad/antenna_check.tcl -indexed_log $log

    set antenna_violators_rpt [index_file $::env(signoff_reports)/antenna_violators.rpt]
    set antenna_violators_plain [index_file $::env(signoff_reports)/antenna_violators_pins.txt]

    try_exec python3 $::env(SCRIPTS_DIR)/extract_antenna_violators.py\
        --output $antenna_violators_rpt\
        --plain-out $antenna_violators_plain\
        $log

    set ::env(ANTENNA_VIOLATOR_LIST) $antenna_violators_rpt

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "antenna check - openroad"
}

proc run_antenna_check {args} {
    if { $::env(USE_ARC_ANTENNA_CHECK) == 1 } {
        run_or_antenna_check
    } else {
        run_magic_antenna_check
    }
}

proc run_irdrop_report {args} {
    increment_index
    TIMER::timer_start
    set log [index_file $::env(signoff_logs)/irdrop.log]
    puts_info "Creating IR Drop Report (log: [relpath . $log])..."

    if { ![info exists ::env(VSRC_LOC_FILES)] } {
        puts_warn "VSRC_LOC_FILES is not defined. The IR drop analysis will run, but the values may be inaccurate."
    }

    set rpt [index_file $::env(signoff_reports)/irdrop]

    set ::env(_tmp_save_rpt_prefix) $rpt
    run_openroad_script $::env(SCRIPTS_DIR)/openroad/irdrop.tcl -indexed_log $log
    unset ::env(_tmp_save_rpt_prefix)

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "ir drop report - openroad"
}

proc or_gui {args} {
    if { ![info exists ::env(CURRENT_ODB)] || $::env(CURRENT_ODB) == 0 } {
        puts_err "CURRENT_ODB is unset."
        throw_error
    }
    run_openroad_script -gui $::env(SCRIPTS_DIR)/openroad/gui.tcl
}

proc save_final_views {args} {
    set options {
        {-save_path optional}
    }
    set flags {}
    parse_key_args "save_final_views" args arg_values $options flags_map $flags

    set arg_list [list]

    # If they don't exist, save_views will simply not copy them
    lappend arg_list -lef_path $::env(signoff_results)/$::env(DESIGN_NAME).lef
    lappend arg_list -gds_path $::env(signoff_results)/$::env(DESIGN_NAME).gds
    lappend arg_list -mag_path $::env(signoff_results)/$::env(DESIGN_NAME).mag
    lappend arg_list -maglef_path $::env(signoff_results)/$::env(DESIGN_NAME).lef.mag
    lappend arg_list -spice_path $::env(signoff_results)/$::env(DESIGN_NAME).spice

    # Guaranteed to have default values
    lappend arg_list -def_path $::env(CURRENT_DEF)
    lappend arg_list -nl_path $::env(CURRENT_NETLIST)

    # Not guaranteed to have default values
    if { [info exists ::env(CURRENT_POWERED_NETLIST)] } {
        lappend arg_list -pnl_path $::env(CURRENT_POWERED_NETLIST)
    }
    if { [info exists ::env(CURRENT_SPEF)] } {
        lappend arg_list -spef_path $::env(CURRENT_SPEF)
    }
    if { [info exists ::env(MC_SPEF_DIR)]} {
        lappend arg_list -mc_spef_dir $::env(MC_SPEF_DIR)
    }
    if { [info exists ::env(CURRENT_SDF)] } {
        lappend arg_list -sdf_path $::env(CURRENT_SDF)
    }
    if { [info exists ::env(MC_SDF_DIR)]} {
        lappend arg_list -mc_sdf_dir $::env(MC_SDF_DIR)
    }
    if { [info exists ::env(CURRENT_SDC)] } {
        lappend arg_list -sdc_path $::env(CURRENT_SDC)
    }
    if { [info exists ::env(CURRENT_LIB)] } {
        lappend arg_list -lib_path $::env(CURRENT_LIB)
    }


    # Add the path if it exists...
    if { [info exists arg_values(-save_path) ] } {
        lappend arg_list -save_path $arg_values(-save_path)
    }

    # Aaand fire!
    save_views {*}$arg_list

}

proc run_post_run_hooks {} {
    if { [file exists $::env(DESIGN_DIR)/hooks/post_run.py]} {
        puts_info "Running post run hook..."
        set result [exec $::env(OPENROAD_BIN) -exit -no_init -python $::env(DESIGN_DIR)/hooks/post_run.py]
        puts_info "$result"
    } else {
        puts_verbose "No post-run hook found, skipping..."
    }
}

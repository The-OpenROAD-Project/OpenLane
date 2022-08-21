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

    set merged_lef_path $::env(TMP_DIR)/merged.$arg_values(-corner).lef

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
        puts_verbose "Extracting the number of available metal layers from $arg_values(-tech_lef)..."

        if { [info exists ::env(METAL_LAYER_NAMES)] } {
            set ::env(TECH_METAL_LAYERS) $::env(METAL_LAYER_NAMES)
        } else {
            try_catch openroad -python\
                $::env(SCRIPTS_DIR)/odbpy/lefutil.py get_metal_layers\
                -o $::env(TMP_DIR)/layers.list\
                $arg_values(-tech_lef)
            set ::env(TECH_METAL_LAYERS)  [cat $::env(TMP_DIR)/layers.list]
        }
        set ::env(MAX_METAL_LAYER) [llength $::env(TECH_METAL_LAYERS)]

        puts_verbose "The available metal layers ($::env(MAX_METAL_LAYER)) are $::env(TECH_METAL_LAYERS)."
        puts_verbose "Merging LEF Files..."
    }

    try_catch $::env(SCRIPTS_DIR)/mergeLef.py\
        -o $merged_lef_path\
        -i $arg_values(-tech_lef) $arg_values(-cell_lef)\
        |& tee $::env(TERMINAL_OUTPUT)

    set mlp_relative [relpath . $merged_lef_path]
    puts_verbose "Created merged LEF without pads at '$mlp_relative'..."

    # Merged Extra Lefs (if they exist)
    if { [info exist ::env(EXTRA_LEFS)] } {
        try_catch $::env(SCRIPTS_DIR)/mergeLef.py\
            -o $merged_lef_path\
            -i $merged_lef_path {*}$::env(EXTRA_LEFS)\
            |& tee $::env(TERMINAL_OUTPUT)
        puts_verbose "Added extra lefs to '$mlp_relative'..."
    }

    # Merge optimization TLEF/CLEF (if exists)
    if { [info exist ::env(STD_CELL_LIBRARY_OPT)] && $::env(STD_CELL_LIBRARY_OPT) != $::env(STD_CELL_LIBRARY) } {
        try_catch $::env(SCRIPTS_DIR)/mergeLef.py\
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
        try_catch $::env(SCRIPTS_DIR)/mergeLef.py\
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
        puts $out ""
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
        puts_verbose "Created ::env(DONT_USE_CELLS): {$::env(DONT_USE_CELLS)}"
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
        {*}$arg_values(-input)
}

proc source_config {args} {
    set options {
        {-run_path optional}
    }
    set flags {}
    parse_key_args "source_config" args arg_values $options flags_map $flags

    if { ![info exists arg_values(-run_path)] } {
        if { ![info exists ::env(RUN_DIR)] } {
            puts_err "source_config needs either the -run_path option or ::env(RUN_DIR) set."
            return -code error
        } else {
            set_if_unset $arg_values(-run_path) $::env(RUN_DIR)
        }
    }

    set config_file [lindex $args 0]
    set config_file_rel [relpath . $config_file]

    if { ![file exists $config_file] } {
        puts_err "$config_file_rel error: file not found"
        return -code error
    }

    set ext [file extension $config_file]
    set config_in_path $arg_values(-run_path)/config_in.tcl

    if { $ext == ".tcl" } {
        # for trusted end-users only
        exec cp $config_file $config_in_path
    } elseif { $ext == ".json" } {
        set scl NULL
        set arg_list [list]
        lappend arg_list --pdk $::env(PDK)
        if { [info exists ::env(STD_CELL_LIBRARY)] } {
            lappend arg_list --scl $::env(STD_CELL_LIBRARY)
        }
        lappend arg_list --output $config_in_path
        lappend arg_list --design-dir $::env(DESIGN_DIR)

        if { [catch {exec python3 $::env(SCRIPTS_DIR)/config/to_tcl.py from-json $config_file {*}$arg_list} errmsg] } {
            puts_err $errmsg
            exit -1
        }

    } else {
        puts_err "$config_file error: unsupported extension '$ext'"
        return -code error
    }


    if { ![info exists ::env(STD_CELL_LIBRARY)] } {
        set ::env(STD_CELL_LIBRARY) {}
        source $config_in_path
        unset ::env(STD_CELL_LIBRARY)
    } else {
        source $config_in_path
    }
}

proc load_overrides {overrides} {
    set env_overrides [split $overrides ',']
    foreach override $env_overrides {
        set kva [split $override '=']
        set key [lindex $kva 0]
        set value [lindex $kva 1]
        set ::env(${key}) $value
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
    }

    set flags {
        -init_design_config
        -add_to_designs
        -overwrite
        -last_run
    }

    set args_copy $args
    parse_key_args "prep" args arg_values $options flags_map $flags

    # Storing the current state of environment variables
    set ::env(INIT_ENV_VAR_ARRAY) [split [array names ::env] " "]
    set_if_unset arg_values(-src) ""
    set_if_unset arg_values(-design) "."

    set ::env(DESIGN_DIR) [file normalize $arg_values(-design)]
    if { ![file exists $::env(DESIGN_DIR)] } {
        set ::env(DESIGN_DIR) [file normalize $::env(OPENLANE_ROOT)/designs/$arg_values(-design)]
    }

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

    set ::env(CONFIGS) [cat $::env(OPENLANE_ROOT)/configuration/load_order.txt]

    if { [info exists arg_values(-config_file)] } {
        set ::env(DESIGN_CONFIG) $arg_values(-config_file)
    } else {
        if { [file exists $::env(DESIGN_DIR)/config.tcl] } {
            set ::env(DESIGN_CONFIG) $::env(DESIGN_DIR)/config.tcl
        } elseif { [file exists $::env(DESIGN_DIR)/config.json] } {
            set ::env(DESIGN_CONFIG) $::env(DESIGN_DIR)/config.json
        } else {
            puts_err "No design configuration (config.json/config.tcl) found in $::env(DESIGN_DIR)."
            return -code error
        }
    }

    foreach config $::env(CONFIGS) {
        source $::env(OPENLANE_ROOT)/configuration/$config
    }

    if { [info exists arg_values(-run_path)] } {
        set run_path "[file normalize $arg_values(-run_path)]/$tag"
    } else {
        set run_path $::env(DESIGN_DIR)/runs/$tag
    }

    file mkdir $run_path

    # Needs to be preliminarily sourced at this point, as the PDK
    # and STD_CELL_LIBRARY values can be in this file.
    set config_file_rel [relpath . $::env(DESIGN_CONFIG)]

    puts_info "Using configuration in '$config_file_rel'..."
    source_config -run_path $run_path $::env(DESIGN_CONFIG)

    if { [info exists arg_values(-override_env)] } {
        load_overrides $arg_values(-override_env)
    }

    # Diagnostics
    if { ! [info exists ::env(PDK_ROOT)] || $::env(PDK_ROOT) == "" } {
        puts_err "PDK_ROOT is not specified. Please make sure you have it set."
        return -code error
    } else {
        puts_info "PDK Root: $::env(PDK_ROOT)"
    }

    if { ! [info exists ::env(PDK)] } {
        puts_err "PDK is not specified."
        return -code error
    } else {
        puts_info "Process Design Kit: $::env(PDK)"
        puts_verbose "Setting PDKPATH to $::env(PDK_ROOT)/$::env(PDK)"
        set ::env(PDKPATH) $::env(PDK_ROOT)/$::env(PDK)
    }

    # Source PDK and SCL specific configurations
    set pdk_config $::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/config.tcl
    source $pdk_config

    if { ! [info exists ::env(STD_CELL_LIBRARY)] } {
        puts_err "STD_CELL_LIBRARY is not specified."
        return -code error
    } else {
        puts_info "Standard Cell Library: $::env(STD_CELL_LIBRARY)"
    }

    if { ! [info exists ::env(STD_CELL_LIBRARY_OPT)] } {
        set ::env(STD_CELL_LIBRARY_OPT) $::env(STD_CELL_LIBRARY)
        puts_verbose "Optimization SCL also set to $::env(STD_CELL_LIBRARY_OPT)."
    } else {
        puts_info "Optimization Standard Cell Library: $::env(STD_CELL_LIBRARY_OPT)"
    }

    if {![info exists ::env(PDN_CFG)]} {
        set ::env(PDN_CFG) $::env(SCRIPTS_DIR)/openroad/pdn_cfg.tcl
    }

    set scl_config $::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(STD_CELL_LIBRARY)/config.tcl
    source $scl_config

    # Re-source/re-override to make sure it overrides any configurations from the previous two sources
    source_config -run_path $run_path $::env(DESIGN_CONFIG)
    if { [info exists arg_values(-override_env)] } {
        load_overrides $arg_values(-override_env)
    }

    set_if_unset arg_values(-verbose) "0"
    set ::env(OPENLANE_VERBOSE) $arg_values(-verbose)

    # DEPRECATED CONFIGS
    handle_deprecated_config LIB_MIN LIB_FASTEST;
    handle_deprecated_config LIB_MAX LIB_SLOWEST;

    handle_deprecated_config FP_HORIZONTAL_HALO FP_PDN_HORIZONTAL_HALO;
    handle_deprecated_config FP_VERTICAL_HALO FP_PDN_VERTICAL_HALO;

    handle_deprecated_config CELL_PAD_EXECLUDE CELL_PAD_EXCLUDE;

    handle_deprecated_config GLB_RT_ALLOW_CONGESTION GRT_ALLOW_CONGESTION;
    handle_deprecated_config GLB_RT_OVERFLOW_ITERS GRT_OVERFLOW_ITERS;
    handle_deprecated_config GLB_RT_ANT_ITERS GRT_ANT_ITERS;
    handle_deprecated_config GLB_RT_ESTIMATE_PARASITICS GRT_ESTIMATE_PARASITICS;
    handle_deprecated_config GLB_RT_MAX_DIODE_INS_ITERS GRT_MAX_DIODE_INS_ITERS;
    handle_deprecated_config GLB_RT_OBS GRT_OBS;
    handle_deprecated_config GLB_RT_ADJUSTMENT GRT_ADJUSTMENT;
    handle_deprecated_config GLB_RT_MACRO_EXTENSION GRT_MACRO_EXTENSION;
    handle_deprecated_config GLB_RT_LAYER_ADJUSTMENTS GRT_LAYER_ADJUSTMENTS;

    handle_deprecated_config RUN_ROUTING_DETAILED RUN_DRT; # Why the hell is this even an option?


    if [catch {exec python3 $::env(OPENLANE_ROOT)/dependencies/verify_versions.py} ::env(VCHECK_OUTPUT)] {
        if { $::env(QUIT_ON_MISMATCHES) == "1" } {
            puts_err $::env(VCHECK_OUTPUT)
            puts_err "Please update your environment. OpenLane will now quit."
            exit -1
        }

        puts_warn "OpenLane may not function properly: $::env(VCHECK_OUTPUT)"
    }


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
            if { ![info exists flags_map(-last_run)] } {
                puts_warn "A run for $::env(DESIGN_NAME) with tag '$tag' already exists. Pass the -overwrite option to overwrite it."
                after 1000
            }
            puts_info "Sourcing $::env(GLB_CFG_FILE). Note that any changes to the DESIGN config file will NOT be applied."
            source $::env(GLB_CFG_FILE)
            if { [info exists ::env(CURRENT_DEF)] && $::env(CURRENT_DEF) != 0 } {
                puts_info "Current DEF: $::env(CURRENT_DEF)."
                puts_info "Use 'set_def file_name.def' if you'd like to change it."
            }
            after 1000
            if { [info exists ::env(BASIC_PREP_COMPLETE)] && "$::env(BASIC_PREP_COMPLETE)" == "1"} {
                set skip_basic_prep 1
            }
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

    if { ![info exists ::env(PL_TARGET_DENSITY)] } {
        set ::env(PL_TARGET_DENSITY) [expr ($::env(FP_CORE_UTIL) + 5.0) / 100.0]
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


        # Convert Tracks
        if { $::env(TRACKS_INFO_FILE) != "" } {
            set tracks_processed $::env(routing_tmpfiles)/config.tracks
            try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/new_tracks.py -i $::env(TRACKS_INFO_FILE) -o $tracks_processed
            set ::env(TRACKS_INFO_FILE_PROCESSED) $tracks_processed
        }

        set ::env(BASIC_PREP_COMPLETE) {1}
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

    if { [info exists ::env(EXTRA_GDS_FILES)] } {
        puts_verbose "Verifying existence of files defined in ::env(EXTRA_GDS_FILES)..."
        assert_files_exist "$::env(EXTRA_GDS_FILES)"
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
        if { ![info exists ::env(ANTENNA_VIOLATOR_LIST)] } {
            puts_err "Attempted to run heal_antenna_violators without running an antenna check first."
            flow_fail
        }

        increment_index
        TIMER::timer_start
        puts_info "Healing Antenna Violators..."

        #replace violating cells with real diodes
        try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/odbpy/diodes.py\
            replace_fake\
            --output $::env(routing_results)/$::env(DESIGN_NAME).def\
            --input-lef $::env(MERGED_LEF)\
            --violations-file $::env(ANTENNA_VIOLATOR_LIST)\
            --fake-diode $::env(FAKEDIODE_CELL)\
            --true-diode $::env(DIODE_CELL)\
            $::env(routing_results)/$::env(DESIGN_NAME).def

        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "heal antenna violators - openlane"
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

    try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/odbpy/label_macro_pins.py\
        --input-lef $arg_values(-lef)\
        --netlist-def $arg_values(-netlist_def)\
        --pad-pin-name $arg_values(-pad_pin_name)\
        --output $output_def\
        {*}$extra_args $::env(CURRENT_DEF)\
        |& tee [index_file $::env(signoff_logs)/label_macro_pins.log] $::env(TERMINAL_OUTPUT)
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
    increment_index
    TIMER::timer_start
    set log [index_file $::env(signoff_logs)/antenna.log]
    puts_info "Running OpenROAD Antenna Rule Checker (log: [relpath . $log])..."

    run_openroad_script $::env(SCRIPTS_DIR)/openroad/antenna_check.tcl -indexed_log $log

    set antenna_violators_rpt [index_file $::env(signoff_reports)/antenna_violators.rpt]
    try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/extract_antenna_violators.py\
        --output $antenna_violators_rpt\
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

    set rpt [index_file $::env(signoff_reports)/irdrop.rpt]

    set ::env(_tmp_save_rpt) $rpt
    run_openroad_script $::env(SCRIPTS_DIR)/openroad/irdrop.tcl -indexed_log $log
    unset ::env(_tmp_save_rpt)

    TIMER::timer_stop
    exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "ir drop report - openroad"
}

proc or_gui {args} {
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
    lappend arg_list -verilog_path $::env(CURRENT_NETLIST)

    # Not guaranteed to have default values
    if { [info exists ::env(CURRENT_SPEF)] } {
        lappend arg_list -spef_path $::env(CURRENT_SPEF)
    }
    if { [info exists ::env(CURRENT_SDF)] } {
        lappend arg_list -sdf_path $::env(CURRENT_SDF)
    }
    if { [info exists ::env(CURRENT_SDC)] } {
        lappend arg_list -sdc_path $::env(CURRENT_SDC)
    }

    # Add the path if it exists...
    if { [info exists arg_values(-save_path) ] } {
        lappend arg_list -save_path $arg_values(-save_path)
    }

    # Aaand fire!
    save_views {*}$arg_list

}

package provide openlane 0.9

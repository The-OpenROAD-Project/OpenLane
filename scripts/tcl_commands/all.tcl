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

    puts_info "Changing netlist from $::env(CURRENT_NETLIST) $netlist"

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
    set ::env(CURRENT_DEF) $def
    set replace [string map {/ \\/} $def]
    exec sed -i -e "s/\\(set ::env(CURRENT_DEF)\\).*/\\1 $replace/" "$::env(GLB_CFG_FILE)"
}

proc prep_lefs {args} {
    try_catch $::env(SCRIPTS_DIR)/mergeLef.py -i $::env(TECH_LEF) $::env(CELLS_LEF) -o $::env(TMP_DIR)/merged_unpadded.lef |& tee $::env(TERMINAL_OUTPUT)
    set ::env(MERGED_LEF_UNPADDED) $::env(TMP_DIR)/merged_unpadded.lef
    # pad lef
    set ::env(CELLS_LEF_UNPADDED) $::env(TMP_DIR)/merged_unpadded.lef

    try_catch $::env(SCRIPTS_DIR)/padLefMacro.py -s $::env(PLACE_SITE) -r $::env(CELL_PAD) -i $::env(CELLS_LEF_UNPADDED) -o $::env(TMP_DIR)/merged.lef -e "$::env(CELL_PAD_EXCLUDE)" |& tee $::env(TERMINAL_OUTPUT)
    set ::env(CELLS_LEF) $::env(TMP_DIR)/merged.lef
    if { $::env(USE_GPIO_PADS) } {
        file copy $::env(CELLS_LEF) $::env(CELLS_LEF).old
        try_catch $::env(SCRIPTS_DIR)/mergeLef.py -i $::env(CELLS_LEF).old {*}$::env(GPIO_PADS_LEF) -o $::env(CELLS_LEF)

        file copy $::env(CELLS_LEF_UNPADDED) $::env(CELLS_LEF_UNPADDED).old
        try_catch $::env(SCRIPTS_DIR)/mergeLef.py -i $::env(CELLS_LEF_UNPADDED).old {*}$::env(GPIO_PADS_LEF) -o $::env(CELLS_LEF_UNPADDED)

        file delete $::env(CELLS_LEF).old $::env(CELLS_LEF_UNPADDED).old
    }

    set ::env(MERGED_LEF) $::env(CELLS_LEF)

    try_catch sed -i -E "s/CLASS PAD.*$/CLASS PAD ;/g" $::env(MERGED_LEF)
    try_catch sed -i -E "s/CLASS PAD.*$/CLASS PAD ;/g" $::env(MERGED_LEF_UNPADDED)

    widen_site_width
    use_widened_lefs

}

proc trim_lib {args} {
    set options {
        {-input optional}
        {-output optional}
    }
    set flags {}
    parse_key_args "trim_lib" args arg_values $options flags_map $flags
    
    set_if_unset arg_values(-input) $::env(LIB_SYNTH_COMPLETE)    
    set_if_unset arg_values(-output) $::env(LIB_SYNTH)

    set scl_no_synth_lib $::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(STD_CELL_LIBRARY)/no_synth.cells
    if { [file exists $scl_no_synth_lib] } {
        try_catch $::env(SCRIPTS_DIR)/libtrim.pl $arg_values(-input) $scl_no_synth_lib > $arg_values(-output)
    } else {
        file copy -force $arg_values(-input) $arg_values(-output)
    }
}

proc source_config {config_file} {
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
        puts_err "No design configuration found"
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
            puts_info "Removing exisiting run $::env(RUN_DIR)"
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

    if { ! $skip_basic_prep } {
        prep_lefs
        set ::env(LIB_SYNTH_COMPLETE) $::env(LIB_SYNTH)
        set ::env(LIB_SYNTH) $::env(TMP_DIR)/trimmed.lib
        trim_lib
        set tracks_copy $::env(TMP_DIR)/tracks_copy.info
        file copy -force $::env(TRACKS_INFO_FILE) $tracks_copy
        set ::env(TRACKS_INFO_FILE) $tracks_copy
    }

    if { [file exists $::env(GLB_CFG_FILE)] } {
        if { [info exists flags_map(-overwrite)] } {
            puts_info "Removing $::env(GLB_CFG_FILE)"
            file delete $::env(GLB_CFG_FILE)
        } else {
            puts_info "Sourcing $::env(GLB_CFG_FILE)\nAny changes to the DESIGN config file will NOT be applied"
            source $::env(GLB_CFG_FILE)
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
        {opendp placement/opendp}
        {addspacers routing/addspacers}
        {fastroute routing/fastroute}
        {tritonRoute routing/tritonRoute}
        {magic magic/magic}
        {cts cts/cts}
        {lvs lvs/lvs}
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

    set stages {synthesis floorplan placement cts routing magic lvs}
    foreach stage $stages {
        file mkdir\
            $::env(RESULTS_DIR)/$stage \
            $::env(TMP_DIR)/$stage  \
            $::env(LOG_DIR)/$stage \
            $::env(REPORTS_DIR)/$stage
    }

    # Fill config file
    #General
    exec echo "# General config" > $::env(GLB_CFG_FILE)
    set_log ::env(PDK) $::env(PDK) $::env(GLB_CFG_FILE) 1
    set_log ::env(STD_CELL_LIBRARY) $::env(STD_CELL_LIBRARY) $::env(GLB_CFG_FILE) 1
    # set_log ::env(PDK_VARIANT) $::env(PDK_VARIANT) $::env(GLB_CFG_FILE) 1; # DEPRECATED
    set_log ::env(PDK_ROOT) $::env(PDK_ROOT) $::env(GLB_CFG_FILE) 1
    set_log ::env(CELL_PAD) $::env(CELL_PAD) $::env(GLB_CFG_FILE) 1
    set_log ::env(MERGED_LEF) $::env(MERGED_LEF) $::env(GLB_CFG_FILE) 1
    set_log ::env(MERGED_LEF_UNPADDED) $::env(MERGED_LEF_UNPADDED) $::env(GLB_CFG_FILE) 1
    set_log ::env(TRACKS_INFO_FILE) $::env(TRACKS_INFO_FILE) $::env(GLB_CFG_FILE) 1
    set_log ::env(TECH_LEF) $::env(TECH_LEF) $::env(GLB_CFG_FILE) 1
    # Design
    exec echo "# Design config" >> $::env(GLB_CFG_FILE)
    set_log ::env(CLOCK_PERIOD) $::env(CLOCK_PERIOD) $::env(GLB_CFG_FILE) 1
    # Synthesis
    exec echo "# Synthesis config" >> $::env(GLB_CFG_FILE)
    set_log ::env(LIB_SYNTH) $::env(LIB_SYNTH) $::env(GLB_CFG_FILE) 1
    set_log ::env(LIB_SYNTH_COMPLETE) $::env(LIB_SYNTH_COMPLETE) $::env(GLB_CFG_FILE) 1
    set_log ::env(SYNTH_DRIVING_CELL) $::env(SYNTH_DRIVING_CELL) $::env(GLB_CFG_FILE) 1
    set_log ::env(SYNTH_CAP_LOAD) $::env(SYNTH_CAP_LOAD) $::env(GLB_CFG_FILE) 1; # femtofarad
    set_log ::env(SYNTH_MAX_FANOUT) $::env(SYNTH_MAX_FANOUT)  $::env(GLB_CFG_FILE) 1
    set_log ::env(SYNTH_NO_FLAT) $::env(SYNTH_NO_FLAT) $::env(GLB_CFG_FILE) 1;
    if { [info exists ::env(SYNTH_MAX_TRAN)] } {
        set_log ::env(SYNTH_MAX_TRAN) $::env(SYNTH_MAX_TRAN) $::env(GLB_CFG_FILE) 1
    } else {
        set_log ::env(SYNTH_MAX_TRAN) "\[\expr {0.1*$::env(CLOCK_PERIOD)}\]" $::env(GLB_CFG_FILE) 1
    }
    # set_log ::env(LIB_MIN) $::env(LIB_MIN) $::env(GLB_CFG_FILE) 1; # DEPRECATED
    # set_log ::env(LIB_MAX) $::env(LIB_MAX) $::env(GLB_CFG_FILE) 1; # DEPRECATED
    set_log ::env(LIB_FASTEST) $::env(LIB_FASTEST) $::env(GLB_CFG_FILE) 1
    set_log ::env(LIB_SLOWEST) $::env(LIB_SLOWEST) $::env(GLB_CFG_FILE) 1
    set_log ::env(LIB_TYPICAL) $::env(LIB_TYPICAL) $::env(GLB_CFG_FILE) 1
    if { $::env(SYNTH_TOP_LEVEL) } {
        set_log ::env(SYNTH_SCRIPT) "$::env(OPENLANE_ROOT)/scripts/synth_top.tcl" $::env(GLB_CFG_FILE) 0
    } else {
        set_log ::env(SYNTH_SCRIPT) $::env(SYNTH_SCRIPT) $::env(GLB_CFG_FILE) 1
    }
    set_log ::env(SYNTH_STRATEGY) $::env(SYNTH_STRATEGY) $::env(GLB_CFG_FILE) 1
    set_log ::env(CLOCK_BUFFER_FANOUT) $::env(CLOCK_BUFFER_FANOUT) $::env(GLB_CFG_FILE) 1
    set_log ::env(SYNTH_OPT) 0 $::env(GLB_CFG_FILE) 0

    # Floorplan
    exec echo "# Floorplan config" >> $::env(GLB_CFG_FILE)
    set_log ::env(FP_SIZING) $::env(FP_SIZING) $::env(GLB_CFG_FILE) 0; # absolute, relative
    set_log ::env(FP_CORE_UTIL) $util $::env(GLB_CFG_FILE) 1
    set_log ::env(FP_ASPECT_RATIO) $::env(FP_ASPECT_RATIO) $::env(GLB_CFG_FILE) 1
    set_log ::env(FP_CORE_MARGIN) $::env(FP_CORE_MARGIN) $::env(GLB_CFG_FILE) 1
    set_log ::env(FP_IO_HMETAL) $::env(FP_IO_HMETAL) $::env(GLB_CFG_FILE) 1
    set_log ::env(FP_IO_VMETAL) $::env(FP_IO_VMETAL) $::env(GLB_CFG_FILE) 1
    set_log ::env(FP_IO_MODE) $::env(FP_IO_MODE) $::env(GLB_CFG_FILE) 0; #0 (default, disabled) 1 fully random, 2 evenly distributed, 3 group on the middle of core edge
    if {[info exists  ::env(FP_WELLTAP_CELL)]} {
        set_log ::env(FP_WELLTAP_CELL) $::env(FP_WELLTAP_CELL) $::env(GLB_CFG_FILE) 1
    }
    set_log ::env(FP_ENDCAP_CELL) $::env(FP_ENDCAP_CELL) $::env(GLB_CFG_FILE) 1
    set_log ::env(FP_PDN_VOFFSET) $::env(FP_PDN_VOFFSET) $::env(GLB_CFG_FILE) 1
    set_log ::env(FP_PDN_VPITCH) $::env(FP_PDN_VPITCH) $::env(GLB_CFG_FILE) 1
    set_log ::env(FP_PDN_HOFFSET) $::env(FP_PDN_HOFFSET) $::env(GLB_CFG_FILE) 1
    set_log ::env(FP_PDN_HPITCH) $::env(FP_PDN_HPITCH) $::env(GLB_CFG_FILE) 1
    set_log ::env(FP_TAPCELL_DIST) $::env(FP_TAPCELL_DIST) $::env(GLB_CFG_FILE) 1

    # Placement
    exec echo "# Placement config" >> $::env(GLB_CFG_FILE)
    set_log ::env(PL_TARGET_DENSITY) $density $::env(GLB_CFG_FILE) 1
    set_log ::env(PL_INIT_COEFF) 0.00002 $::env(GLB_CFG_FILE) 0
    set_log ::env(PL_TIME_DRIVEN) $::env(PL_TIME_DRIVEN) $::env(GLB_CFG_FILE) 1
    set_log ::env(PL_LIB) $::env(PL_LIB) $::env(GLB_CFG_FILE) 1
    set_log ::env(PL_IO_ITER) 5 $::env(GLB_CFG_FILE) 0

    # CTS
    exec echo "# CTS config" >> $::env(GLB_CFG_FILE)
    set_log ::env(CTS_TARGET_SKEW) $::env(CTS_TARGET_SKEW) $::env(GLB_CFG_FILE) 1
    set_log ::env(CTS_ROOT_BUFFER) $::env(CTS_ROOT_BUFFER) $::env(GLB_CFG_FILE) 1
    set_log ::env(CTS_TECH_DIR) $::env(CTS_TECH_DIR) $::env(GLB_CFG_FILE) 1
    set_log ::env(CTS_TOLERANCE) $::env(CTS_TOLERANCE) $::env(GLB_CFG_FILE) 1

    # ROUTING
    exec echo "# Routing config" >> $::env(GLB_CFG_FILE)
    set_log ::env(GLB_RT_MAXLAYER) $::env(GLB_RT_MAXLAYER) $::env(GLB_CFG_FILE) 1
    set_log ::env(GLB_RT_ADJUSTMENT) $::env(GLB_RT_ADJUSTMENT) $::env(GLB_CFG_FILE) 1
    set_log ::env(GLB_RT_L1_ADJUSTMENT) $::env(GLB_RT_L1_ADJUSTMENT) $::env(GLB_CFG_FILE) 1
    set_log ::env(GLB_RT_L2_ADJUSTMENT) $::env(GLB_RT_L2_ADJUSTMENT) $::env(GLB_CFG_FILE) 1
    set_log ::env(GLB_RT_MINLAYER) $::env(GLB_RT_MINLAYER) $::env(GLB_CFG_FILE) 1
    set_log ::env(GLB_RT_MAXLAYER) $::env(GLB_RT_MAXLAYER) $::env(GLB_CFG_FILE) 1
    set_log ::env(GLB_RT_UNIDIRECTIONAL) $::env(GLB_RT_UNIDIRECTIONAL) $::env(GLB_CFG_FILE) 1
    set_log ::env(GLB_RT_ALLOW_CONGESTION) $::env(GLB_RT_ALLOW_CONGESTION) $::env(GLB_CFG_FILE) 1
    set_log ::env(GLB_RT_OVERFLOW_ITERS) $::env(GLB_RT_OVERFLOW_ITERS) $::env(GLB_CFG_FILE) 1

    # Flow control
    exec echo "# Flow control config" >> $::env(GLB_CFG_FILE)
    set_log ::env(RUN_SIMPLE_CTS) $::env(RUN_SIMPLE_CTS) $::env(GLB_CFG_FILE) 1
    set_log ::env(RUN_ROUTING_DETAILED) $::env(RUN_ROUTING_DETAILED) $::env(GLB_CFG_FILE) 1
    set_log ::env(CLOCK_TREE_SYNTH) $::env(CLOCK_TREE_SYNTH) $::env(GLB_CFG_FILE) 1
    set_log ::env(LEC_ENABLE) $::env(LEC_ENABLE) $::env(GLB_CFG_FILE) 1
    set_log ::env(FILL_INSERTION) $::env(FILL_INSERTION) $::env(GLB_CFG_FILE) 1
    set_log ::env(DIODE_INSERTION_STRATEGY) $::env(DIODE_INSERTION_STRATEGY) $::env(GLB_CFG_FILE) 1

    if { [info exists ::env(CURRENT_DEF)] } {
        set_log ::env(CURRENT_DEF) $::env(CURRENT_DEF) $::env(GLB_CFG_FILE) 1
    } else {
        set ::env(CURRENT_DEF) 0
        set_log ::env(CURRENT_DEF) $::env(CURRENT_DEF) $::env(GLB_CFG_FILE) 1
    }

    if { [info exists ::env(CURRENT_NETLIST)] } {
        set_log ::env(CURRENT_NETLIST) $::env(CURRENT_NETLIST) $::env(GLB_CFG_FILE) 1
    } else {
        set ::env(CURRENT_NETLIST) 0
        set_log ::env(CURRENT_NETLIST) $::env(CURRENT_NETLIST) $::env(GLB_CFG_FILE) 1
    }

    if { [info exists ::env(PREV_NETLIST)] } {
        set_log ::env(PREV_NETLIST) $::env(PREV_NETLIST) $::env(GLB_CFG_FILE) 1
    } else {
        set ::env(PREV_NETLIST) 0
        set_log ::env(PREV_NETLIST) $::env(PREV_NETLIST) $::env(GLB_CFG_FILE) 1
    }

    puts_info "Preparation complete"
    return -code ok
}

proc padframe_gen {args} {
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
        |& tee $::env(TERMINAL_OUTPUT) $pf_src_tmp/pfg.log

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
        |& tee $::env(TERMINAL_OUTPUT) $pf_src_tmp/pfg.log

    kill_display_buffer
}


proc save_views {args} {
    set options {
        {-lef_path optional}
        {-mag_path optional}
        {-def_path optional}
        {-gds_path optional}
        {-verilog_path optional}
        {-spice_path optional}
        {-save_path optional}
        {-tag required}
    }

    set flags {}
    parse_key_args "save_views" args arg_values $options flags_map $flags
    if { [info exists arg_values(-save_path)] } {
        set path "[file normalize $arg_values(-save_path)]"
    } else {
        set path $::env(DESIGN_DIR)
    }
    puts "\[INFO\]: Saving Magic Views in $path"

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
	if { $::env(DIODE_INSERTION_STRATEGY) == 2 } {
		if { $::env(USE_ARC_ANTENNA_CHECK) == 1 } {
			#ARC specific		
			try_catch python3 $::env(SCRIPTS_DIR)/extract_antenna_violators.py -i $::env(REPORTS_DIR)/routing/antenna.rpt -o $::env(TMP_DIR)/vios.txt
		} else {
            #Magic Specific
			set report_file [open $::env(magic_report_file_tag).antenna_violators.rpt r]
			set violators [split [string trim [read $report_file]]]
			close $report_file
			# may need to speed this up for extremely huge files using hash tables
			exec echo $violators >> $::env(TMP_DIR)/vios.txt
		}
		#replace violating cells with real diodes
		try_catch python3 $::env(SCRIPTS_DIR)/fakeDiodeReplace.py -v $::env(TMP_DIR)/vios.txt -d $::env(tritonRoute_result_file_tag).def -f $::env(FAKEDIODE_CELL) -t $::env(DIODE_CELL)
		puts_info "DONE HEALING ANTENNA VIOLATORS"
	}
}


proc li1_hack_start {args} {
    try_catch touch $::env(TMP_DIR)/li1HackTmpFile.txt
    try_catch python3 $::env(SCRIPTS_DIR)/li1_hack_start.py -d $::env(CURRENT_DEF) -l $::env(MERGED_LEF_UNPADDED) -t $::env(TMP_DIR)/li1HackTmpFile.txt
}

proc li1_hack_end {args} {
    try_catch python3 $::env(SCRIPTS_DIR)/li1_hack_end.py -d $::env(CURRENT_DEF) -t $::env(TMP_DIR)/li1HackTmpFile.txt
}

proc extract_macros_pin_order {args} {
    try_catch python3 $::env(SCRIPTS_DIR)/extract_pad_pin_order_mod.py -d $::env(CURRENT_DEF) -c [lindex $args 0] -o $::env(RESULTS_DIR)/pinPadOrder.txt
}

proc reorder_macro_pins {args} {
    try_catch python3 $::env(SCRIPTS_DIR)/reorder_pins.py -d $::env(CURRENT_DEF) -c [lindex $args 0] -m [lindex $args 1] -o $::env(CURRENT_DEF)
}

proc widen_site_width {args} {

    set ::env(MERGED_LEF_UNPADDED_ORIGINAL) $::env(MERGED_LEF_UNPADDED)
    set ::env(MERGED_LEF_ORIGINAL) $::env(MERGED_LEF)

    if { $::env(WIDEN_SITE) == 1 && $::env(WIDEN_SITE_IS_FACTOR) == 1 } {
        set ::env(MERGED_LEF_UNPADDED_WIDENED) $::env(MERGED_LEF_UNPADDED)
        set ::env(MERGED_LEF_WIDENED) $::env(MERGED_LEF)
    } else {
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
    puts_info "Labeling macro pins..."
    set options {
        {-lef required}
        {-netlist_def required}
        {-pad_pin_name required}
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


    try_catch python3 $::env(SCRIPTS_DIR)/label_macro_pins.py\
        --lef $arg_values(-lef)\
        --input-def $::env(CURRENT_DEF)\
        --netlist-def $arg_values(-netlist_def)\
        --pad-pin-name $arg_values(-pad_pin_name)\
        -o $output_def\
        {*}$extra_args |& tee $::env(LOG_DIR)/label_macro_pins.log $::env(TERMINAL_OUTPUT)
}


proc write_verilog {filename args} {
    set ::env(SAVE_NETLIST) $filename

    set options {
        {-def optional}
    }
    set flags {}
    parse_key_args "write_verilog" args arg_values $options flags_map $flags

    set_if_unset arg_values(-def) $::env(CURRENT_DEF)

    set ::env(INPUT_DEF) $arg_values(-def)

    try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_write_verilog.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(LOG_DIR)/write_verilog.log

    yosys_rewrite_verilog $filename
}

proc add_macro_obs {args} {
    set options {
        {-defFile required}
        {-lefFile required}
        {-obstruction required}
        {-placementX optional}
        {-placementY optional}
        {-sizeWidth required}
        {-sizeHeight required}
        {-fixed required}
        {-dbunit optional}
        {-layerNames required}
    }
    set flags {}
    parse_key_args "add_macro_obs" args arg_values $options flags_map $flags

    set px 0
    set py 0
    set db 1000

    if {[info exists arg_values(-placementX)]} {
        set px $arg_values(-placementX)
    }

    if {[info exists arg_values(-placementY)]} {
        set py $arg_values(-placementY)
    }

    if {[info exists arg_values(-dbunit)]} {
        set db $arg_values(-dbunit)
    }

    if { $arg_values(-fixed) == 1 } {
        try_catch python3 $::env(SCRIPTS_DIR)/addObstruction.py -d $arg_values(-defFile) -l $arg_values(-lefFile) -obs $arg_values(-obstruction) -ln {*}$arg_values(-layerNames) -px $px -py $py -sw $arg_values(-sizeWidth) -sh $arg_values(-sizeHeight) -db $db -f
    } else {
        try_catch python3 $::env(SCRIPTS_DIR)/addObstruction.py -d $arg_values(-defFile) -l $arg_values(-lefFile) -obs $arg_values(-obstruction) -ln {*}$arg_values(-layerNames) -px $px -py $py -sw $arg_values(-sizeWidth) -sh $arg_values(-sizeHeight) -db $db
    }

}

proc set_layer_tracks {args} {
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

	try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_antenna_check.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(LOG_DIR)/routing/or_antenna.log

}

proc run_antenna_check {args} {
	if { $::env(USE_ARC_ANTENNA_CHECK) == 1 } {
		run_or_antenna_check
	} else {
		run_magic_antenna_check
	}
}

package provide openlane 0.9

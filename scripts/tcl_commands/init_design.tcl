# Copyright (c) Efabless Corporation. All rights reserved.
# See LICENSE file in the project root for full license information.

proc init_design {design_name config_tag src_files} {
	set src "\$::env(OPENLANE_ROOT)/designs/$design_name/src"
	set src_dir "$::env(OPENLANE_ROOT)/designs/$design_name/src"
	set config_path "$::env(OPENLANE_ROOT)/designs/${design_name}/$config_tag.tcl"
	set base_config_path "$::env(OPENLANE_ROOT)/designs/${design_name}/base_config.tcl"
	puts_info "Creating design src directory $src_dir"
	exec mkdir -p $src_dir
	exec touch $config_path

	puts_info "Populating $config_path.."

	set config_user \
"# User config
set ::env(DESIGN_NAME) ${design_name}

# Change if needed
set ::env(VERILOG_FILES) \[glob $src/*.v\]


# Fill this
set ::env(CLOCK_PERIOD) \"10\"
set ::env(CLOCK_PORT) \"clk\"


set filename \$::env(OPENLANE_ROOT)/designs/\$::env(DESIGN_NAME)/\$::env(PDK)_\$::env(PDK_VARIANT)_config.tcl
if { \[file exists \$filename\] == 1} {
	source \$filename
}

"
	set config_file [open $config_path w]
		puts $config_file $config_user
		#puts $config_file $config_default
	close $config_file

	foreach src_file $src_files {
		puts_info "Copying $src_file to $src_file"
		file copy $src_file $src_dir
	}

	puts_info "Finished populating:\n$config_path \nPlease modify CLOCK_PORT, CLOCK_PERIOD and add your advanced settings to $config_path"
}

package provide openlane 0.9

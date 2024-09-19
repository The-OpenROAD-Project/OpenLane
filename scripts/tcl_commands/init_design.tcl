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


proc init_design {design_name config_tag src_files} {
    puts_warn "init_design is deprecated and will be removed in a future version."
    
    set src "\$::env(DESIGN_DIR)/src"
    set src_dir "$::env(DESIGN_DIR)/src"
    set config_path "$::env(DESIGN_DIR)/$config_tag.tcl"
    set base_config_path "$::env(DESIGN_DIR)/base_config.tcl"
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
set ::env(CLOCK_PERIOD) \"10.0\"
set ::env(CLOCK_PORT) \"clk\"

set filename \$::env(DESIGN_DIR)/\$::env(PDK)_\$::env(STD_CELL_LIBRARY)_config.tcl
if { \[file exists \$filename\] == 1} {
	source \$filename
}
"
    set config_file [open $config_path w]
    puts $config_file $config_user
    close $config_file

    foreach src_file $src_files {
        puts_info "Copying $src_file to $src_file"
        file copy $src_file $src_dir
    }

    puts_info "Finished populating:\n$config_path \nPlease modify CLOCK_PORT, CLOCK_PERIOD and add your advanced settings to $config_path"
}

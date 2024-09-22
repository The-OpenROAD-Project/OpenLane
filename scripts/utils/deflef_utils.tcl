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

proc resize_die {args} {
    set options {
        {-def required}
        {-area required}
    }
    set flags {}
    parse_key_args "resize_die" args arg_values $options flags_map $flags

    set llx [expr {[lindex $arg_values(-area) 0] * $::env(DEF_UNITS_PER_MICRON)}]
    set lly [expr {[lindex $arg_values(-area) 1] * $::env(DEF_UNITS_PER_MICRON)}]
    set urx [expr {[lindex $arg_values(-area) 2] * $::env(DEF_UNITS_PER_MICRON)}]
    set ury [expr {[lindex $arg_values(-area) 3] * $::env(DEF_UNITS_PER_MICRON)}]

    puts_info "Resizing Die to $arg_values(-area)"
    try_exec sed -i.bak -E "0,/^DIEAREA.*$/{s/^DIEAREA.*$/DIEAREA ( $llx $lly ) ( $urx $ury ) ;/}" $arg_values(-def)
    try_exec rm -f $arg_values(-def).bak
}

proc get_instance_position {args} {
    set options {
        {-instance required}
        {-def optional}
    }
    set flags {}

    parse_key_args "get_instance_position" args arg_values $options flags_map $flags

    set instance $arg_values(-instance)
    if { [info exists arg_values(-def)] } {
        set def $arg_values(-def)
    } elseif { [info exists ::env(CURRENT_DEF)] } {
        set def $::env(CURRENT_DEF)
    } else {
        puts_err "No DEF specified"
        throw_error
    }

    puts $instance
    set pos [exec sed -E -n "s/^\s*-\s+$instance.*\( (\[\[:digit:\]\]+) (\[\[:digit:\]\]+)).*;$/\12/p" $arg_values(-def)]

    return $pos
}



proc add_lefs {args} {
    set options {
        {-src required}
    }
    set flags {}

    parse_key_args "add_lefs" args arg_values $options flags_map $flags
    puts_info "Merging $arg_values(-src)"

    try_exec $::env(SCRIPTS_DIR)/mergeLef.py -i $::env(MERGED_LEF) {*}$arg_values(-src) -o $::env(MERGED_LEF).new
    try_exec mv $::env(MERGED_LEF).new $::env(MERGED_LEF)
}

proc merge_components {args} {
    set options {
        {-input optional}
        {-donor required}
        {-output optional}
    }
    set flags {}

    parse_key_args "merge_components" args arg_values $options flags_map $flags

    set_if_unset arg_values(-input) $::env(CURRENT_ODB)
    set_if_unset arg_values(-output) $arg_values(-input)

    manipulate_layout $::env(SCRIPTS_DIR)/odbpy/defutil.py merge_components \
        -output $arg_values(-output) \
        -input $arg_values(-input) \
        --with-components-from $arg_values(-donor)
}


proc move_pins {args} {
    # To be precise, this REPLACES pins in to with the ones in from.
    handle_deprecated_command relocate_pins;
}

proc relocate_pins {args} {
    set options {
        {-input optional}
        {-template required}
        {-output optional}
    }
    set flags {}

    parse_key_args "relocate_pins" args arg_values $options flags_map $flags

    set_if_unset arg_values(-input) $::env(CURRENT_ODB)
    set_if_unset arg_values(-output) $arg_values(-input)

    manipulate_layout $::env(SCRIPTS_DIR)/odbpy/defutil.py relocate_pins\
        -output $arg_values(-output)\
        -input $arg_values(-input)\
        --template-def $arg_values(-template)
}

proc remove_pins {args} {
    set options {
        {-input optional}
        {-output optional}
    }
    set flags {}
    parse_key_args "remove_pins" args arg_values $options flags_map $flags

    set_if_unset arg_values(-input) $::env(CURRENT_ODB)
    set_if_unset arg_values(-output) $arg_values(-input)

    manipulate_layout $::env(SCRIPTS_DIR)/odbpy/defutil.py remove_pins\
        -input $arg_values(-input)\
        -output $arg_values(-output)
}

proc remove_nets {args} {
    set options {
        {-input optional}
        {-output optional}
        {-rx optional}
    }
    set flags {-empty}
    parse_key_args "remove_nets" args arg_values $options flags_map $flags

    set_if_unset arg_values(-input) $::env(CURRENT_ODB)
    set_if_unset arg_values(-output) $arg_values(-input)

    set arg_list [list]
    lappend arg_list -input $arg_values(-input)
    lappend arg_list -output $arg_values(-output)

    if { [info exists arg_values(-rx)] } {
        lappend arg_list --match $arg_values(-rx)
    }

    if { [info exists flags_map(-empty)] } {
        lappend arg_list --empty-only
    }

    manipulate_layout $::env(SCRIPTS_DIR)/odbpy/defutil.py remove_nets\
        {*}$arg_list
}

proc remove_empty_nets {args} {
    handle_deprecated_command remove_nets -empty
}

proc remove_components {args} {
    set options {
        {-input required}
        {-output optional}
    }
    set flags {}
    parse_key_args "remove_components" args arg_values $options flags_map $flags

    set_if_unset arg_values(-output) $arg_values(-input)


    manipulate_layout $::env(SCRIPTS_DIR)/odbpy/defutil.py remove_components \
        -output $arg_values(-output) \
        -input $arg_values(-input)
}



proc insert_buffer {args} {
    # Copyright 2021 The University of Michigan
    # Licensed under the Apache License, Version 2.0 (the "License");
    set options {
        {-at_pin required}
        {-buffer_cell required}
        {-net_name optional}
        {-inst_name optional}
    }
    set flags {-block -place}

    parse_key_args "insert_buffer" args arg_values $options flags_map $flags

    if { ![info exists ::env(INSERT_BUFFER_COUNTER)]} {
        set ::env(INSERT_BUFFER_COUNTER) 0
    }

    set_if_unset arg_values(-net_name) "inserted_buffer_$::env(INSERT_BUFFER_COUNTER)_net"
    set_if_unset arg_values(-inst_name) "inserted_buffer_$::env(INSERT_BUFFER_COUNTER)"

    set pin_type "ITerm"
    if { [info exists flags_map(-block)] } {
        set pin_type "BTerm"
    }

    if { ![info exists flags_map(-place)] } {
        set ::env(INSERT_BUFFER_NO_PLACE) "1"
    }


    set ::env(INSERT_BUFFER_COMMAND) "$arg_values(-at_pin) $pin_type $arg_values(-buffer_cell) $arg_values(-net_name) $arg_values(-inst_name)"
    run_openroad_script $::env(SCRIPTS_DIR)/openroad/insert_buffer.tcl\
        -indexed_log [index_file $::env(routing_logs)/insert_buffer.log]\
        -save "to=$::env(routing_tmpfiles),def,odb"
    unset ::env(INSERT_BUFFER_COMMAND)

    if { ![info exists flags_map(-place)] } {
        unset ::env(INSERT_BUFFER_NO_PLACE)
    }

    incr ::env(INSERT_BUFFER_COUNTER)
}

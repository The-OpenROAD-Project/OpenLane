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

#
proc remove_pins {args} {
  set options {{-input required}}
  set flags {}
  parse_key_args "remove_pins" args arg_values $options flags_map $flags
  try_catch $::env(SCRIPTS_DIR)/remove_pins.sh $arg_values(-input)
}

proc remove_empty_nets {args} {
  set options {{-input required}}
  set flags {}
  parse_key_args "remove_empty_nets" args arg_values $options flags_map $flags
  try_catch $::env(SCRIPTS_DIR)/remove_empty_nets.sh $arg_values(-input)
}

proc resize_die {args} {
  set options {\
    {-def required} \
    {-area required}
  }
  set flags {}
  parse_key_args "resize_die" args arg_values $options flags_map $flags

  set llx [expr {[lindex $arg_values(-area) 0] * $::env(DEF_UNITS_PER_MICRON)}]
  set lly [expr {[lindex $arg_values(-area) 1] * $::env(DEF_UNITS_PER_MICRON)}]
  set urx [expr {[lindex $arg_values(-area) 2] * $::env(DEF_UNITS_PER_MICRON)}]
  set ury [expr {[lindex $arg_values(-area) 3] * $::env(DEF_UNITS_PER_MICRON)}]
  puts_info "Resizing Die to $arg_values(-area)"
  try_catch sed -i -E "0,/^DIEAREA.*$/{s/^DIEAREA.*$/DIEAREA ( $llx $lly ) ( $urx $ury ) ;/}" $arg_values(-def)
}

proc get_instance_position {args} {
  set options {\
    {-instance required}\
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
	return -code error
  }

  puts $instance
  set pos [exec sed -E -n "s/^\s*-\s+$instance.*\( (\[\[:digit:\]\]+) (\[\[:digit:\]\]+) \).*;$/\1 \2/p" $arg_values(-def)]

  return $pos
}



proc add_lefs {args} {
  set options {{-src required} \
     \
  }
  set flags {}
  parse_key_args "add_lefs" args arg_values $options flags_map $flags
  puts_info "Merging $arg_values(-src)"


  if { $::env(WIDEN_SITE) == 1 && $::env(WIDEN_SITE_IS_FACTOR) == 1 } {

    try_catch $::env(SCRIPTS_DIR)/mergeLef.py -i $::env(MERGED_LEF) {*}$arg_values(-src) -o $::env(MERGED_LEF).new
    try_catch $::env(SCRIPTS_DIR)/mergeLef.py -i $::env(MERGED_LEF_UNPADDED) {*}$arg_values(-src) -o $::env(MERGED_LEF_UNPADDED).new

    try_catch mv $::env(MERGED_LEF).new $::env(MERGED_LEF)
    try_catch mv $::env(MERGED_LEF_UNPADDED).new $::env(MERGED_LEF_UNPADDED)

  } else {
    # The original lef
    try_catch $::env(SCRIPTS_DIR)/mergeLef.py -i $::env(MERGED_LEF_ORIGINAL) {*}$arg_values(-src) -o $::env(MERGED_LEF_ORIGINAL).new
    try_catch $::env(SCRIPTS_DIR)/mergeLef.py -i $::env(MERGED_LEF_UNPADDED_ORIGINAL) {*}$arg_values(-src) -o $::env(MERGED_LEF_UNPADDED_ORIGINAL).new

    try_catch mv $::env(MERGED_LEF_ORIGINAL).new $::env(MERGED_LEF_ORIGINAL)
    try_catch mv $::env(MERGED_LEF_UNPADDED_ORIGINAL).new $::env(MERGED_LEF_UNPADDED_ORIGINAL)

    # The modified lef
    try_catch $::env(SCRIPTS_DIR)/mergeLef.py -i $::env(MERGED_LEF_WIDENED) {*}$arg_values(-src) -o $::env(MERGED_LEF_WIDENED).new
    try_catch $::env(SCRIPTS_DIR)/mergeLef.py -i $::env(MERGED_LEF_UNPADDED_WIDENED) {*}$arg_values(-src) -o $::env(MERGED_LEF_UNPADDED_WIDENED).new

    try_catch mv $::env(MERGED_LEF_WIDENED).new $::env(MERGED_LEF_WIDENED)
    try_catch mv $::env(MERGED_LEF_UNPADDED_WIDENED).new $::env(MERGED_LEF_UNPADDED_WIDENED)
  }
}

proc merge_components {args} {
  set options {{-input1 required} \
    {-input2 required} \
    {-output required} \
  }
  set flags {}
  parse_key_args "merge_components" args arg_values $options flags_map $flags
  try_catch $::env(SCRIPTS_DIR)/merge_components.sh $arg_values(-input1) $arg_values(-input2) $arg_values(-output)
}


proc move_pins {args} {
  set options {{-from required} \
    {-to required} \
  }
  set flags {}
  parse_key_args "move_pins" args arg_values $options flags_map $flags
  try_catch $::env(SCRIPTS_DIR)/mv_pins.sh $arg_values(-from) $arg_values(-to)
}

proc zeroize_origin_lef {args} {
  set options {{-file required} \
  }
  set flags {}
  parse_key_args "zeroize_origin_lef" args arg_values $options flags_map $flags
  exec cp $arg_values(-file) $arg_values(-file).original
  try_catch python3 $::env(SCRIPTS_DIR)/zeroize_origin_lef.py < $arg_values(-file) > $arg_values(-file).zeroized
  exec mv  $arg_values(-file).zeroized $arg_values(-file)
}

proc remove_nets {args} {
  set options {{-input required}}
  set flags {}
  parse_key_args "remove_nets" args arg_values $options flags_map $flags
  try_catch $::env(SCRIPTS_DIR)/remove_nets.sh $arg_values(-input)
}

proc remove_components {args} {
  set options {{-input required}}
  set flags {}
  parse_key_args "remove_components" args arg_values $options flags_map $flags
  try_catch $::env(SCRIPTS_DIR)/remove_components.sh $arg_values(-input)
}

proc remove_component {args} {
  set options {
      {-input required}
      {-instance_name required}
  }
  set flags {}
  parse_key_args "remove_component" args arg_values $options flags_map $flags
  try_catch $::env(SCRIPTS_DIR)/remove_def_component.sh $arg_values(-instance_name) $arg_values(-input)
}

package provide openlane_utils 0.9

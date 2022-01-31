# Power nets

if { ! [info exists ::env(VDD_NET)] } {
	set ::env(VDD_NET) $::env(VDD_PIN)
}

if { ! [info exists ::env(GND_NET)] } {
	set ::env(GND_NET) $::env(GND_PIN)
}

set ::power_nets $::env(VDD_NET)
set ::ground_nets $::env(GND_NET)

if { [info exists ::env(FP_PDN_ENABLE_GLOBAL_CONNECTIONS)] } {
    if { $::env(FP_PDN_ENABLE_GLOBAL_CONNECTIONS) == 1 } {
        foreach power_pin $::env(STD_CELL_POWER_PINS) {
            add_global_connection -net $::env(VDD_NET) -inst_pattern .* -pin_pattern $power_pin -power
        }
        foreach ground_pin $::env(STD_CELL_GROUND_PINS) {
            add_global_connection -net $::env(GND_NET) -inst_pattern .* -pin_pattern $ground_pin -ground
        }
    }
}

set_voltage_domain -name CORE -power $::env(VDD_NET) -ground $::env(GND_NET)

# Assesses whether the deisgn is the core of the chip or not based on the 
# value of $::env(DESIGN_IS_CORE) and uses the appropriate stdcell section
if { $::env(DESIGN_IS_CORE) == 1 } {
    # Used if the design is the core of the chip
    define_pdn_grid -name stdcell_grid -starts_with POWER -voltage_domain CORE -pins [subst {$::env(FP_PDN_LOWER_LAYER) $::env(FP_PDN_UPPER_LAYER)}]
    add_pdn_stripe -grid stdcell_grid -layer $::env(FP_PDN_LOWER_LAYER) -width $::env(FP_PDN_VWIDTH) -pitch $::env(FP_PDN_VPITCH) -offset $::env(FP_PDN_VOFFSET) -starts_with POWER
    add_pdn_stripe -grid stdcell_grid -layer $::env(FP_PDN_UPPER_LAYER) -width $::env(FP_PDN_HWIDTH) -pitch $::env(FP_PDN_HPITCH) -offset $::env(FP_PDN_HOFFSET) -starts_with POWER
    add_pdn_connect -grid stdcell_grid -layers [subst {$::env(FP_PDN_LOWER_LAYER) $::env(FP_PDN_UPPER_LAYER)}]
} else {
    # Used if the design is a macro in the core
    define_pdn_grid -name stdcell_grid -starts_with POWER -voltage_domain CORE -pins $::env(FP_PDN_LOWER_LAYER)
    add_pdn_stripe -grid stdcell_grid -layer $::env(FP_PDN_LOWER_LAYER) -width $::env(FP_PDN_VWIDTH) -pitch $::env(FP_PDN_VPITCH) -offset $::env(FP_PDN_VOFFSET) -starts_with POWER
}

# Adds the standard cell rails if enabled.
if { $::env(FP_PDN_ENABLE_RAILS) == 1 } {
    add_pdn_stripe -grid stdcell_grid -layer $::env(FP_PDN_RAILS_LAYER) -width $::env(FP_PDN_RAIL_WIDTH) -followpins -starts_with POWER
    add_pdn_connect -grid stdcell_grid -layers [subst {$::env(FP_PDN_RAILS_LAYER) $::env(FP_PDN_LOWER_LAYER)}]
} 


# Adds the core ring if enabled.
if { $::env(FP_PDN_CORE_RING) == 1 } {
    add_pdn_ring -grid stdcell_grid -layer [subst {$::env(FP_PDN_LOWER_LAYER) $::env(FP_PDN_UPPER_LAYER)}] \
                 -widths [subst {$::env(FP_PDN_CORE_RING_VWIDTH) $::env(FP_PDN_CORE_RING_HWIDTH)}] \
                 -spacings [subst {$::env(FP_PDN_CORE_RING_VSPACING) $::env(FP_PDN_CORE_RING_HSPACING)}] \
                 -core_offset [subst {$::env(FP_PDN_CORE_RING_VOFFSET) $::env(FP_PDN_CORE_RING_HOFFSET)}]
}

# A general macro that follows the premise of the set heirarchy. You may want to modify this or add other macro configs
# The macro power pin names are assumed to match the VDD and GND net names 
# TODO: parameterize the power pin names 
set macro {
    orient {R0 R180 MX MY R90 R270 MXR90 MYR90}
    power_pins $::env(VDD_NET)
    ground_pins $::env(GND_NET)
    blockages {$::env(MACRO_BLOCKAGES_LAYER)}
    straps {
    }
    connect {{$::env(FP_PDN_LOWER_LAYER)_PIN_ver $::env(FP_PDN_UPPER_LAYER)}}
}

if { $::env(FP_PDN_ENABLE_MACROS_GRID) == 1} {
    if { [llength $::env(FP_PDN_MACROS)] > 0 } {
        # generate automatically per instance:
        foreach macro_instance $::env(FP_PDN_MACROS) {
            set macro_instance_grid [subst $macro] 
            dict append $macro_instance_grid instance $macro_instance
            set ::halo [list $::env(FP_PDN_HORIZONTAL_HALO) $::env(FP_PDN_VERTICAL_HALO)]
            pdngen::specify_grid macro [subst $macro_instance_grid]
        }
    } else {
        set ::halo [list $::env(FP_PDN_HORIZONTAL_HALO) $::env(FP_PDN_VERTICAL_HALO)]
        pdngen::specify_grid macro [subst $macro]
    }
    # CAN NOT ENABLE THE TCL COMMAND BECAUSE THERE IS NO ARGUMENT FOR SPECIFYING THE POWER AND GROUND PIN NAMES ON THE MACRO
    # define_pdn_grid -macro -orient {R0 R180 MX MY R90 R270 MXR90 MYR90} -grid_over_pg_pins -starts_with POWER -pin_direction vertical -halo [subst {$::env(FP_PDN_HORIZONTAL_HALO) $::env(FP_PDN_VERTICAL_HALO)}]
    # add_pdn_connect -layers [subst {$::env(FP_PDN_LOWER_LAYER) $::env(FP_PDN_UPPER_LAYER)}]
} else {
    define_pdn_grid -macro -orient {R0 R180 MX MY R90 R270 MXR90 MYR90} -grid_over_pg_pins -starts_with POWER -halo [subst {$::env(FP_PDN_HORIZONTAL_HALO) $::env(FP_PDN_VERTICAL_HALO)}]
}

# POWER or GROUND #Std. cell rails starting with power or ground rails at the bottom of the core area
set ::rails_start_with "POWER" ;

# POWER or GROUND #Upper metal stripes starting with power or ground rails at the left/bottom of the core area
set ::stripes_start_with "POWER" ;

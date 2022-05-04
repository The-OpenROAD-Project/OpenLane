# Power nets

if { ! [info exists ::env(VDD_NET)] } {
	set ::env(VDD_NET) $::env(VDD_PIN)
}

if { ! [info exists ::env(GND_NET)] } {
	set ::env(GND_NET) $::env(GND_PIN)
}

if { [info exists ::env(FP_PDN_ENABLE_GLOBAL_CONNECTIONS)] } {
    if { $::env(FP_PDN_ENABLE_GLOBAL_CONNECTIONS) == 1 } {
        foreach power_pin $::env(STD_CELL_POWER_PINS) {
            add_global_connection \
                -net $::env(VDD_NET) \
                -inst_pattern .* \
                -pin_pattern $power_pin \
                -power
        }
        foreach ground_pin $::env(STD_CELL_GROUND_PINS) {
            add_global_connection \
                -net $::env(GND_NET) \
                -inst_pattern .* \
                -pin_pattern $ground_pin \
                -ground
        }
    }
}

if { $::env(FP_PDN_ENABLE_MACROS_GRID) == 1 &&
     [info exists ::env(FP_PDN_MACRO_HOOKS)]} {
    set pdn_hooks [split $::env(FP_PDN_MACRO_HOOKS) ","]
    foreach pdn_hook $pdn_hooks {
        set instance_name [lindex $pdn_hook 0]
        set power_net [lindex $pdn_hook 1]
        set ground_net [lindex $pdn_hook 2]
        # This assumes the power pin and the power net have the same name.
        # The macro hooks only give an instance name and not power pin names.

        add_global_connection \
            -net $power_net \
            -inst_pattern $instance_name \
            -pin_pattern $power_net \
            -power

        add_global_connection \
            -net $ground_net \
            -inst_pattern $instance_name \
            -pin_pattern $ground_net \
            -ground
    }
}

set secondary []

foreach net $::env(VDD_NETS) {
    if { $net != $::env(VDD_NET)} {
        lappend secondary $net

        set db_net [[ord::get_db_block] findNet $net]
        if {$db_net == "NULL"} {
            set net [odb::dbNet_create [ord::get_db_block] $net]
            $net setSpecial
            $net setSigType "POWER"
        }
    }
}

foreach net $::env(GND_NETS) {
    if { $net != $::env(GND_NET)} {
        lappend secondary $net

        set db_net [[ord::get_db_block] findNet $net]
        if {$db_net == "NULL"} {
            set net [odb::dbNet_create [ord::get_db_block] $net]
            $net setSpecial
            $net setSigType "GROUND"
        }
    }
}

set_voltage_domain -name CORE -power $::env(VDD_NET) -ground $::env(GND_NET) \
    -secondary_power $secondary

# Assesses whether the design is the core of the chip or not based on the
# value of $::env(DESIGN_IS_CORE) and uses the appropriate stdcell section
if { $::env(DESIGN_IS_CORE) == 1 } {
    # Used if the design is the core of the chip
    define_pdn_grid \
        -name stdcell_grid \
        -starts_with POWER \
        -voltage_domain CORE \
        -pins "$::env(FP_PDN_LOWER_LAYER) $::env(FP_PDN_UPPER_LAYER)"

    add_pdn_stripe \
        -grid stdcell_grid \
        -layer $::env(FP_PDN_LOWER_LAYER) \
        -width $::env(FP_PDN_VWIDTH) \
        -pitch $::env(FP_PDN_VPITCH) \
        -offset $::env(FP_PDN_VOFFSET) \
        -starts_with POWER -extend_to_core_ring

    add_pdn_stripe \
        -grid stdcell_grid \
        -layer $::env(FP_PDN_UPPER_LAYER) \
        -width $::env(FP_PDN_HWIDTH) \
        -pitch $::env(FP_PDN_HPITCH) \
        -offset $::env(FP_PDN_HOFFSET) \
        -starts_with POWER -extend_to_core_ring

    add_pdn_connect \
        -grid stdcell_grid \
        -layers "$::env(FP_PDN_LOWER_LAYER) $::env(FP_PDN_UPPER_LAYER)"
} else {
    # Used if the design is a macro in the core
    define_pdn_grid \
        -name stdcell_grid \
        -starts_with POWER \
        -voltage_domain CORE \
        -pins $::env(FP_PDN_LOWER_LAYER)

    add_pdn_stripe \
        -grid stdcell_grid \
        -layer $::env(FP_PDN_LOWER_LAYER) \
        -width $::env(FP_PDN_VWIDTH) \
        -pitch $::env(FP_PDN_VPITCH) \
        -offset $::env(FP_PDN_VOFFSET) \
        -starts_with POWER
}

# Adds the standard cell rails if enabled.
if { $::env(FP_PDN_ENABLE_RAILS) == 1 } {
    add_pdn_stripe \
        -grid stdcell_grid \
        -layer $::env(FP_PDN_RAILS_LAYER) \
        -width $::env(FP_PDN_RAIL_WIDTH) \
        -followpins \
        -starts_with POWER

    add_pdn_connect \
        -grid stdcell_grid \
        -layers "$::env(FP_PDN_RAILS_LAYER) $::env(FP_PDN_LOWER_LAYER)"
} 


# Adds the core ring if enabled.
if { $::env(FP_PDN_CORE_RING) == 1 } {
    add_pdn_ring \
        -grid stdcell_grid \
        -layers "$::env(FP_PDN_LOWER_LAYER) $::env(FP_PDN_UPPER_LAYER)" \
        -widths "$::env(FP_PDN_CORE_RING_VWIDTH) $::env(FP_PDN_CORE_RING_HWIDTH)" \
        -spacings "$::env(FP_PDN_CORE_RING_VSPACING) $::env(FP_PDN_CORE_RING_HSPACING)" \
        -core_offset "$::env(FP_PDN_CORE_RING_VOFFSET) $::env(FP_PDN_CORE_RING_HOFFSET)"
}

define_pdn_grid \
    -macro \
    -default \
    -name macro \
    -starts_with POWER \
    -halo "$::env(FP_PDN_HORIZONTAL_HALO) $::env(FP_PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid macro \
    -layers "$::env(FP_PDN_LOWER_LAYER) $::env(FP_PDN_UPPER_LAYER)"

# set resistance and capacitence
# Via resistance
puts "\[INFO\]: Setting RC values..."
if { [info exist ::env(VIAS_RC)] } {
    set vias_rc [split $::env(VIAS_RC) ","]
    foreach via_rc $vias_rc {
        set layer_name [lindex $via_rc 0]
        set resistance [lindex $via_rc 1]
        set_layer_rc -via $layer_name -resistance $resistance
    }
}

# Metal resistance and capacitence
if { [info exist ::env(LAYERS_RC)] } {
    set layers_rc [split $::env(LAYERS_RC) ","]
    foreach layer_rc $layers_rc {
        set layer_name [lindex $layer_rc 0]
        set capacitance [lindex $layer_rc 1]
        set resistance [lindex $layer_rc 2]
        set_layer_rc -layer $layer_name -capacitance $capacitance -resistance $resistance
    }
}

set_wire_rc -signal -layer $::env(WIRE_RC_LAYER)
set_wire_rc -clock -layer $::env(WIRE_RC_LAYER)
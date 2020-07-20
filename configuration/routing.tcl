# Routing defaults
set ::env(ROUTING_STRATEGY) 0
set ::env(GLB_RT_OLD_FR) 0
set ::env(GLB_RT_ADJUSTMENT) 0
set ::env(GLB_RT_L1_ADJUSTMENT) 0; # more like pdk-specific (e.g., when L1 = li)
set ::env(GLB_RT_L2_ADJUSTMENT) 0
set ::env(GLB_RT_UNIDIRECTIONAL) 1
set ::env(GLB_RT_ALLOW_CONGESTION) 0
set ::env(GLB_RT_OVERFLOW_ITERS) 50
set ::env(GLB_RT_MINLAYER) 1
set ::env(GLB_RT_MAXLAYER) 6
set ::env(GLB_RT_TILES) 15 ; # openroads fastroute default value
set ::env(GLB_RT_SCRIPT) $::env(SCRIPTS_DIR)/fastroute.tcl


set ::env(DIODE_PADDING) 2 ; # sites 

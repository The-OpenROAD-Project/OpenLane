# SCL Configs
set ::env(SYNTH_MAX_FANOUT) 6

set ::env(FP_CORE_UTIL) 35
set ::env(FP_PDN_VPITCH) 153.6
set ::env(FP_PDN_HPITCH) 153.18
set ::env(FP_ASPECT_RATIO) 1
set ::env(GLB_RT_ADJUSTMENT) 0.1
set ::env(CLOCK_PERIOD) "12.71"
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]


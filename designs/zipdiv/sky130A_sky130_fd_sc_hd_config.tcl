# SCL Configs
set ::env(CLOCK_PERIOD) "20.00"
set ::env(SYNTH_STRATEGY) "DELAY 2" 
set ::env(SYNTH_MAX_FANOUT) 6
set ::env(FP_CORE_UTIL) 40
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]


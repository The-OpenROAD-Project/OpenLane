# SCL Configs
set ::env(FP_CORE_UTIL) 45
set ::env(CELL_PAD) 4
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]
set ::env(CLOCK_PERIOD) "50.0"

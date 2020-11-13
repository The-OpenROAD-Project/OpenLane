# SCL Configs
set ::env(SYNTH_MAX_FANOUT) 6
set ::env(FP_CORE_UTIL) 65
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]
set ::env(CLOCK_PERIOD) "15.8"
# Regression
set ::env(FP_CORE_UTIL) 40
set ::env(CELL_PAD) 4

# Extra
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+1) / 100.0 ]

# Regression
set ::env(FP_CORE_UTIL) 35
set ::env(CELL_PAD) 4

# Extra
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]


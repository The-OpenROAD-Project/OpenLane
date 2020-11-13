# SCL Configs
set ::env(FP_CORE_UTIL) 30
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]
set ::env(CLOCK_PERIOD) "10.09"
# Regression
set ::env(FP_CORE_UTIL) 25
set ::env(CELL_PAD) 6

# Extra
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]


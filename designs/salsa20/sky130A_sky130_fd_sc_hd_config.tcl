# SCL Configs
set ::env(CLOCK_PERIOD) "38"
set ::env(FP_CORE_UTIL) 20
set ::env(SYNTH_MAX_FANOUT) 6
set ::env(PL_RESIZER_HOLD_SLACK_MARGIN) 0.25
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]

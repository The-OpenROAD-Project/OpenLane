# SCL Configs
set ::env(CLOCK_PERIOD) "18"
set ::env(FP_CORE_UTIL) 35
set ::env(SYNTH_MAX_FANOUT) 6
set ::env(SYNTH_STRATEGY) "DELAY 0"
set ::env(PL_RESIZER_HOLD_SLACK_MARGIN) 0.15
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]


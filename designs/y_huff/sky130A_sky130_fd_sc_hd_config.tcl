# SCL Configs
set ::env(CLOCK_PERIOD) "14"
set ::env(FP_CORE_UTIL) 40
set ::env(SYNTH_MAX_FANOUT) 6
set ::env(CTS_CLK_BUFFER_LIST) "sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_8"
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]

# default pdk
set ::env(PDK) "sky130A"
set ::env(PDK_VARIANT) "sky130_fd_sc_hd"
set ::env(PDK_ROOT) $::env(OPENLANE_ROOT)/pdks/
set ::env(USE_GPIO_PADS) 0

# Flow control defaults
set ::env(RUN_MAGIC) 1
set ::env(MAGIC_PAD) 0
set ::env(MAGIC_ZEROIZE_ORIGIN) 1
set ::env(MAGIC_GENERATE_GDS) 1
set ::env(MAGIC_GENERATE_LEF) 1
set ::env(RUN_ROUTING_DETAILED) 1
set ::env(RUN_SIMPLE_CTS) 0

set ::env(RUN_RESIZER_OVERBUFFER) 0

set ::env(FILL_INSERTION) 1

set ::env(WIDEN_SITE) 1
set ::env(WIDEN_SITE_IS_FACTOR) 1 

# 0: no diodes
# 1: spray inputs with diodes
# 2: spray inputs with fake diodes first then fix up the violators with real ones
set ::env(DIODE_INSERTION_STRATEGY) 1

# psn
if { [file exists /build/transforms/] } {
	set ::env(PSN_TRANSFORM_PATH) /build/transforms
} else {
	set ::env(PSN_TRANSFORM_PATH) $::env(HOME)/.local/transforms
}

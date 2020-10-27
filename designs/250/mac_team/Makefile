ifeq ($(shell which verilator),)
$(error Did not find Verilator in PATH. Make sure all requirements are installed)
endif

base_dir=$(abspath .)
src_dir=$(base_dir)/src
test_dir=$(base_dir)/test

sim_name = verilator
model_name = mac_test_harness

sim_prefix = simulator
sim = $(base_dir)/$(sim_prefix)-$(model_name)

# If verilator seed unspecified, verilator uses srand as random seed
ifdef RANDOM_SEED
SEED_FLAG=+verilator+seed+I$(RANDOM_SEED)
else
SEED_FLAG=
endif

.PHONY: default
default: test
sim: $(sim)

#########################################################################################
# Verilator/cxx binary and flags
#########################################################################################
#----------------------------------------------------------------------------------------
# User configs
#----------------------------------------------------------------------------------------
VERILATOR_FST_MODE ?= 0
TRACING_OPTS := \
    --trace

#----------------------------------------------------------------------------------------
# Verilation configuration/optimization
#----------------------------------------------------------------------------------------
VERILATOR_OPT_FLAGS := \
	-O3 \

VERILOG_VERILATOR_FLAGS := \
	-Wno-PINCONNECTEMPTY \
	-Wno-IMPLICIT \
	-Wno-ASSIGNDLY \
	-Wno-DECLFILENAME \
	-Wno-UNUSED \
	-Wno-UNOPTFLAT \
	-Wno-BLKANDNBLK \
	-Wno-WIDTH \
	-Wno-STMTDLY \
	-Wno-style

VERILATOR_INCLUDES := \
    -I$(src_dir)/  \
    -I$(test_dir)/ 

VERILATOR_NONCC_OPTS = \
	$(VERILATOR_INCLUDES) \
	$(VERILOG_VERILATOR_FLAGS) \
	$(VERILATOR_OPT_FLAGS) \
	$(PLATFORM_OPTS) \
	-Wno-fatal \
	+define+CLOCK_PERIOD=2.00 \
    #--prof-cfuncs \

#----------------------------------------------------------------------------------------
# gcc configuration/optimization
#----------------------------------------------------------------------------------------
VERILATOR_CXXFLAGS = \
	-DVL_DEBUG

#VERILATOR_LDFLAGS = $(SIM_LDFLAGS)

VERILATOR_CC_OPTS = \
	-CFLAGS "$(VERILATOR_CXXFLAGS)" #\
	#-LDFLAGS "$(VERILATOR_LDFLAGS)"

#----------------------------------------------------------------------------------------
# Full verilator+gcc opts
#----------------------------------------------------------------------------------------
VERILATOR_OPTS = $(VERILATOR_CC_OPTS) $(VERILATOR_NONCC_OPTS)

#########################################################################################
# Verilator build paths and file names
#########################################################################################
model_dir = $(base_dir)/$(model_name)

model_header = $(model_dir)/V$(model_name).h

model_mk = $(model_dir)/V$(model_name).mk

#########################################################################################
# Build the verilator sim
#########################################################################################
$(model_mk):
	rm -rf $(model_dir)
	mkdir -p $(model_dir)
	$(sim_name) -cc $(test_dir)/$(model_name).v $(VERILATOR_OPTS) -o $(sim) $(TRACING_OPTS) \
	-Mdir $(model_dir) -CFLAGS "-include $(model_header)" \
	--exe $(test_dir)/$(model_name).cpp
	touch $@

$(sim): $(model_mk)
	make -C $(model_dir) -f V$(model_name).mk

#########################################################################################
# Test
#########################################################################################
.PHONY: test
test: $(sim)
	$(sim)

#########################################################################################
# General cleanup rules
#########################################################################################
.PHONY: clean 
clean:
	rm -rf $(model_dir) $(sim)
	rm -rf *.vcd
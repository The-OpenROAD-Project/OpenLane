# Copyright 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

OPENLANE_DIR ?= $(shell pwd)

PDK_ROOT ?= $(shell pwd)/pdks

ifeq (, $(strip $(NPROC)))
  # Linux (utility program)
  NPROC := $(shell nproc 2>/dev/null)

  ifeq (, $(strip $(NPROC)))
    # Linux (generic)
    NPROC := $(shell grep -c ^processor /proc/cpuinfo 2>/dev/null)
  endif
  ifeq (, $(strip $(NPROC)))
    # BSD (at least FreeBSD and Mac OSX)
    NPROC := $(shell sysctl -n hw.ncpu 2>/dev/null)
  endif
  ifeq (, $(strip $(NPROC)))
    # Fallback
    NPROC := 1
  endif

endif

DOCKER_MEMORY_OPTIONS :=
ifneq (,$(DOCKER_SWAP)) # Set to -1 for unlimited
DOCKER_MEMORY_OPTIONS +=  --memory-swap=$(DOCKER_SWAP)
endif
ifneq (,$(DOCKER_MEMORY))
DOCKER_MEMORY_OPTIONS += --memory=$(DOCKER_MEMORY)
# To verify: cat /sys/fs/cgroup/memory/memory.limit_in_bytes inside the container
endif

DOCKER_UID_OPTIONS = $(shell python3 ./get_docker_config.py)
DOCKER_OPTIONS = $(DOCKER_MEMORY_OPTIONS) $(DOCKER_UID_OPTIONS)

THREADS ?= $(NPROC)
STD_CELL_LIBRARY ?= sky130_fd_sc_hd
SPECIAL_VOLTAGE_LIBRARY ?= sky130_fd_sc_hvl
IO_LIBRARY ?= sky130_fd_io
INSTALL_SRAM ?= disabled

CURRENT_TAG ?= $(shell python3 ./get_tag.py)
IMAGE_NAME ?= efabless/openlane:$(CURRENT_TAG)
TEST_DESIGN ?= spm
DESIGN_LIST ?= spm
BENCHMARK ?= regression_results/benchmark_results/SW_HD.csv
REGRESSION_TAG ?= TEST_SW_HD
FASTEST_TEST_SET_TAG ?= FASTEST_TEST_SET
EXTENDED_TEST_SET_TAG ?= EXTENDED_TEST_SET
PRINT_REM_DESIGNS_TIME ?= 0

SKYWATER_COMMIT ?= $(shell python3 ./dependencies/tool.py sky130 -f commit)
OPEN_PDKS_COMMIT ?= $(shell python3 ./dependencies/tool.py open_pdks -f commit)

ENV_COMMAND ?= docker run --rm -v $(OPENLANE_DIR):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) $(DOCKER_OPTIONS) $(IMAGE_NAME)

ifndef PDK_ROOT
$(error PDK_ROOT is undefined, please export it before running make)
endif

.DEFAULT_GOAL := all

.PHONY: all
all: openlane pdk

.PHONY: pdk
pdk: skywater-pdk skywater-library open_pdks build-pdk gen-sources

.PHONY: native-pdk
native-pdk: skywater-pdk skywater-library open_pdks native-build-pdk gen-sources

.PHONY: full-pdk
full-pdk: skywater-pdk all-skywater-libraries open_pdks build-pdk gen-sources

.PHONY: native-full-pdk
native-full-pdk: skywater-pdk all-skywater-libraries open_pdks native-build-pdk gen-sources

$(PDK_ROOT)/:
	mkdir -p $(PDK_ROOT)

$(PDK_ROOT)/skywater-pdk:
	git clone $(shell python3 ./dependencies/tool.py sky130 -f repo) $(PDK_ROOT)/skywater-pdk

.PHONY: skywater-pdk
skywater-pdk: $(PDK_ROOT)/ $(PDK_ROOT)/skywater-pdk
	cd $(PDK_ROOT)/skywater-pdk && \
		git checkout main && git submodule init && git pull --no-recurse-submodules && \
		git checkout -qf $(SKYWATER_COMMIT)

.PHONY: skywater-library
skywater-library: $(PDK_ROOT)/skywater-pdk
	cd $(PDK_ROOT)/skywater-pdk && \
		git submodule update --init libraries/$(STD_CELL_LIBRARY)/latest && \
		git submodule update --init libraries/$(IO_LIBRARY)/latest && \
		git submodule update --init libraries/$(SPECIAL_VOLTAGE_LIBRARY)/latest && \
		$(MAKE) timing

.PHONY: all-skywater-libraries
all-skywater-libraries: skywater-pdk
	cd $(PDK_ROOT)/skywater-pdk && \
		git submodule update --init libraries/sky130_fd_sc_hd/latest && \
		git submodule update --init libraries/sky130_fd_sc_hs/latest && \
		git submodule update --init libraries/sky130_fd_sc_hdll/latest && \
		git submodule update --init libraries/sky130_fd_sc_ms/latest && \
		git submodule update --init libraries/sky130_fd_sc_ls/latest && \
		git submodule update --init libraries/sky130_fd_sc_hvl/latest && \
		git submodule update --init libraries/sky130_fd_io/latest && \
		$(MAKE) -j$(THREADS) timing

### OPEN_PDKS
$(PDK_ROOT)/open_pdks:
	git clone $(shell python3 ./dependencies/tool.py open_pdks -f repo) $(PDK_ROOT)/open_pdks

.PHONY: open_pdks
open_pdks: $(PDK_ROOT)/ $(PDK_ROOT)/open_pdks
	cd $(PDK_ROOT)/open_pdks && \
		git checkout master && git pull && \
		git checkout -qf $(OPEN_PDKS_COMMIT)

.PHONY: build-pdk
build-pdk: $(PDK_ROOT)/open_pdks $(PDK_ROOT)/skywater-pdk
	[ -d $(PDK_ROOT)/sky130A ] && \
		(echo "Warning: A sky130A build already exists under $(PDK_ROOT). It will be deleted first!" && \
		sleep 5 && \
		rm -rf $(PDK_ROOT)/sky130A) || \
		true
	$(ENV_COMMAND) sh -c " cd $(PDK_ROOT)/open_pdks && \
		./configure --enable-sky130-pdk=$(PDK_ROOT)/skywater-pdk/libraries --with-sky130-local-path=$(PDK_ROOT)"
	cd $(PDK_ROOT)/open_pdks/sky130 && \
		$(MAKE) veryclean && \
		$(MAKE) prerequisites
	$(ENV_COMMAND) sh -c " cd $(PDK_ROOT)/open_pdks/sky130 && \
		make && \
		make install-local && \
		make clean"

.PHONY: native-build-pdk
native-build-pdk: $(PDK_ROOT)/open_pdks $(PDK_ROOT)/skywater-pdk
	[ -d $(PDK_ROOT)/sky130A ] && \
		(echo "Warning: A sky130A build already exists under $(PDK_ROOT). It will be deleted first!" && \
		sleep 5 && \
		rm -rf $(PDK_ROOT)/sky130A) || \
		true
	cd $(PDK_ROOT)/open_pdks && \
		./configure --enable-sky130-pdk=$(PDK_ROOT)/skywater-pdk/libraries --with-sky130-local-path=$(PDK_ROOT) --enable-sram-sky130=$(INSTALL_SRAM) && \
		cd sky130 && \
		$(MAKE) veryclean && \
		$(MAKE) && \
		$(MAKE) install-local

gen-sources: $(PDK_ROOT)/sky130A
	touch $(PDK_ROOT)/sky130A/SOURCES
	OPENLANE_COMMIT=$(git rev-parse HEAD)
	echo -ne "openlane " > $(PDK_ROOT)/sky130A/SOURCES
	cd $(OPENLANE_DIR) && git rev-parse HEAD >> $(PDK_ROOT)/sky130A/SOURCES
	echo -ne "skywater-pdk " >> $(PDK_ROOT)/sky130A/SOURCES
	cd $(PDK_ROOT)/skywater-pdk && git rev-parse HEAD >> $(PDK_ROOT)/sky130A/SOURCES
	echo -ne "open_pdks " >> $(PDK_ROOT)/sky130A/SOURCES
	cd $(PDK_ROOT)/open_pdks && git rev-parse HEAD >> $(PDK_ROOT)/sky130A/SOURCES

### OPENLANE
.PHONY: openlane
openlane:
	docker pull $(IMAGE_NAME)

.PHONY: mount
mount:
	cd $(OPENLANE_DIR) && \
		docker run -it --rm -v $(OPENLANE_DIR):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) $(DOCKER_OPTIONS) $(IMAGE_NAME)

MISC_REGRESSION_ARGS=
.PHONY: regression regression_test
regression_test: MISC_REGRESSION_ARGS=--benchmark $(BENCHMARK)
regression_test: regression
regression:
	cd $(OPENLANE_DIR) && \
		$(ENV_COMMAND) sh -c "\
			python3 run_designs.py --delete\
			--defaultTestSet\
			--tarList logs reports\
			--htmlExtract\
			--tag $(REGRESSION_TAG)\
			--threads $(THREADS)\
			--print $(PRINT_REM_DESIGNS_TIME)\
			$(MISC_REGRESSION_ARGS)\
		"

DLTAG=custom_design_List
.PHONY: test_design_list fastest_test_set extended_test_set
fastest_test_set: DESIGN_LIST=$(shell python3 ./.github/test_sets/get_test_set.py fastestTestSet)
fastest_test_set: DLTAG=$(FASTEST_TEST_SET_TAG)
fastest_test_set: test_design_list
extended_test_set: DESIGN_LIST=$(shell python3 ./.github/test_sets/get_test_set.py extendedTestSet)
extended_test_set: DLTAG=$(EXTENDED_TEST_SET_TAG)
extended_test_set: test_design_list
test_design_list:
	cd $(OPENLANE_DIR) && \
		$(ENV_COMMAND) sh -c "\
			python3 run_designs.py --delete\
			--designs $(DESIGN_LIST)\
			--tag $(DLTAG)\
			--threads $(THREADS)\
			--print_rem $(PRINT_REM_DESIGNS_TIME)\
			--benchmark $(BENCHMARK)\
		"

.PHONY: test
test:
	cd $(OPENLANE_DIR) && \
		$(ENV_COMMAND) sh -c "./flow.tcl -design $(TEST_DESIGN) -tag openlane_test -disable_output -overwrite"
	@[ -f $(OPENLANE_DIR)/designs/$(TEST_DESIGN)/runs/openlane_test/results/magic/$(TEST_DESIGN).gds ] && \
		echo "Basic test passed" || \
		echo "Basic test failed"

.PHONY: clean_runs
clean_runs:
	cd $(OPENLANE_DIR) && \
		docker run --rm -v $(OPENLANE_DIR):/openLANE_flow $(IMAGE_NAME) sh -c "./clean_runs.tcl"

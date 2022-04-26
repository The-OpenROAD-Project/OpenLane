# Copyright 2020-2022 Efabless Corporation
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
PYTHON_BIN ?= python3

OPENLANE_DIR ?= $(shell pwd)

DOCKER_OPTIONS = $(shell $(PYTHON_BIN) ./env.py docker-config)

# Allow Configuring Memory Limits
ifneq (,$(DOCKER_SWAP)) # Set to -1 for unlimited
DOCKER_OPTIONS += --memory-swap=$(DOCKER_SWAP)
endif
ifneq (,$(DOCKER_MEMORY))
DOCKER_OPTIONS += --memory=$(DOCKER_MEMORY)
# To verify: cat /sys/fs/cgroup/memory/memory.limit_in_bytes inside the container
endif

# Allow using GUIs
UNAME_S = $(shell uname -s)
ifeq ($(UNAME_S),Linux)
DOCKER_OPTIONS += -e DISPLAY=$(DISPLAY) -v /tmp/.X11-unix:/tmp/.X11-unix -v $(HOME)/.Xauthority:/.Xauthority --network host
  ifneq ("$(wildcard $(HOME)/.openroad)","")
    DOCKER_OPTIONS += -v $(HOME)/.openroad:/.openroad
  endif
endif

THREADS ?= 1

ifneq (,$(ROUTING_CORES))
DOCKER_OPTIONS += -e ROUTING_CORES=$(ROUTING_CORES)
endif

ifeq ($(OPENLANE_IMAGE_NAME),)
OPENLANE_DOCKER_TAG ?= $(shell $(PYTHON_BIN) ./dependencies/get_tag.py)
ifneq ($(OPENLANE_DOCKER_TAG),)
export OPENLANE_IMAGE_NAME ?= efabless/openlane:$(OPENLANE_DOCKER_TAG)
endif
endif

TEST_DESIGN ?= spm
DESIGN_LIST ?= spm
QUICK_RUN_DESIGN ?= spm
BENCHMARK ?= regression_results/benchmark_results/SW_HD.csv
REGRESSION_TAG ?= TEST_SW_HD
FASTEST_TEST_SET_TAG ?= FASTEST_TEST_SET
EXTENDED_TEST_SET_TAG ?= EXTENDED_TEST_SET
PRINT_REM_DESIGNS_TIME ?= 0

SKYWATER_COMMIT ?= $(shell $(PYTHON_BIN) ./dependencies/tool.py sky130 -f commit)
OPEN_PDKS_COMMIT ?= $(shell $(PYTHON_BIN) ./dependencies/tool.py open_pdks -f commit)

PDK_OPTS = 
EXTERNAL_PDK_INSTALLATION ?= 1
ifeq ($(EXTERNAL_PDK_INSTALLATION), 1)
export PDK_ROOT ?= ./pdks
export PDK_ROOT := $(shell $(PYTHON_BIN) -c "import os; print(os.path.realpath('$(PDK_ROOT)'), end='')")
PDK_OPTS = -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT)
endif

export STD_CELL_LIBRARY ?= sky130_fd_sc_hd
STD_CELL_OPTS := -e STD_CELL_LIBRARY=$(STD_CELL_LIBRARY)

# ./designs is mounted over ./install so env.tcl is not found inside the Docker
# container if the user had previously installed it.
ENV_START = docker run --rm\
	-v $(OPENLANE_DIR):/openlane\
	-v $(OPENLANE_DIR)/designs:/openlane/install\
	$(PDK_OPTS)\
	$(STD_CELL_OPTS)\
	$(DOCKER_OPTIONS)

ENV_COMMAND = $(ENV_START) $(OPENLANE_IMAGE_NAME)

.DEFAULT_GOAL := all

.PHONY: all
all: get-openlane pdk

.PHONY: openlane
openlane: venv/created
	@PYTHON_BIN=$(PWD)/venv/bin/$(PYTHON_BIN) $(MAKE) -C docker openlane

pull-openlane:
	@docker pull $(OPENLANE_IMAGE_NAME)

get-openlane:
	@$(MAKE) pull-openlane || $(MAKE) openlane

.PHONY: mount
mount:
	cd $(OPENLANE_DIR) && \
		$(ENV_START) -ti $(OPENLANE_IMAGE_NAME)

.PHONY: pdk
pdk: venv/created
	./venv/bin/$(PYTHON_BIN) -m pip install --upgrade --no-cache-dir volare
	./venv/bin/volare enable

.PHONY: survey
survey:
	$(PYTHON_BIN) ./env.py issue-survey

venv/created: ./requirements.txt ./dependencies/python/precompile_time.txt ./dependencies/python/run_time.txt
	rm -rf ./venv
	$(PYTHON_BIN) -m venv ./venv
	./venv/bin/$(PYTHON_BIN) -m pip install --upgrade --no-cache-dir pip
	./venv/bin/$(PYTHON_BIN) -m pip install --upgrade --no-cache-dir -r ./requirements.txt
	touch $@

DLTAG=custom_design_List
.PHONY: test_design_list fastest_test_set extended_test_set
fastest_test_set: DESIGN_LIST=$(shell cat ./.github/test_sets/fastest_test_set)
fastest_test_set: DLTAG=$(FASTEST_TEST_SET_TAG)
fastest_test_set: test_design_list
extended_test_set: DESIGN_LIST=$(shell cat ./.github/test_sets/extended_test_set)
extended_test_set: DLTAG=$(EXTENDED_TEST_SET_TAG)
extended_test_set: test_design_list
test_design_list:
	cd $(OPENLANE_DIR) && \
		$(ENV_COMMAND) sh -c "\
			python3 run_designs.py\
			--tag $(DLTAG)\
			--threads $(THREADS)\
			--print_rem $(PRINT_REM_DESIGNS_TIME)\
			--benchmark $(BENCHMARK)\
			$(DESIGN_LIST)\
		"
# -u is needed, as the python buffers the stdout, so no output is generated
run_issue_regression:
	cd $(OPENLANE_DIR) && \
		$(ENV_COMMAND) sh -c "\
			python3 -u run_issue_regressions.py run $(ISSUE_REGRESSION_DESIGN)"

issue_regression_all:
	cd $(OPENLANE_DIR) && \
		$(ENV_COMMAND) sh -c "\
			python3 -u run_issue_regressions.py run_all"

.PHONY: test
test:
	cd $(OPENLANE_DIR) && \
		$(ENV_COMMAND) sh -c "./flow.tcl -design $(TEST_DESIGN) -tag openlane_test -overwrite"
	@[ -f $(OPENLANE_DIR)/designs/$(TEST_DESIGN)/runs/openlane_test/results/signoff/$(TEST_DESIGN).gds ] && \
		echo "Basic test passed" || \
		echo "Basic test failed"

.PHONY: quick_run
quick_run:
	cd $(OPENLANE_DIR) && \
		$(ENV_COMMAND) sh -c "./flow.tcl -design $(QUICK_RUN_DESIGN)"

.PHONY: veryclean clean_runs clean_results
veryclean:
	@git clean -fdX

clean_runs:
	@rm -rf ./designs/*/runs && rm -rf ./_build/it_tc_logs && echo "Runs cleaned successfully." || echo "Failed to delete runs."
	@rm -rf ./tests/*/runs && echo "Test runs cleaned successfully." || echo "Failed to delete test runs."

clean_results:
	@{ find regression_results -mindepth 1 -maxdepth 1 -type d | grep -v benchmark | xargs rm -rf ; } && echo "Results cleaned successfully." || echo "Failed to delete results."
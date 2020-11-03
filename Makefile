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

#The openlane directory root
OPENLANE_DIR ?= $(shell pwd)
#Number of threads to use
THREADS ?= $(shell nproc)
#location of the PDK inside the docker
PDK_ROOT ?= /pdks
#location of PDK outside the docker
PDK_BASE ?= $(shell pwd)/pdks
#Image name of the docker
IMAGE_NAME ?= openlane:rc4
#The benchmark result to compare against 
BENCHMARK ?= regression_results/benchmark_results/SW_HD.csv
#The regression result tag to use
REGRESSION_TAG ?= TEST_SW_HD
#Test design for the test target
TEST_DESIGN ?= spm
PRINT_REM_DESIGNS_TIME ?= 0

SKYWATER_COMMIT ?= 5cd70ed19fee8ea37c4e8dbd5c5c3eaa9886dd23
OPEN_PDKS_COMMIT ?= 48db3e1a428ae16f5d4c86e0b7679656cf8afe3d

ifndef PDK_ROOT
$(error PDK_ROOT is undefined, please export it before running make)
endif

.DEFAULT_GOAL := all

.PHONY: all

all: skywater-pdk openlane

skywater-pdk: 
	git submodule update --init pdks/


### OPENLANE
.PHONY: openlane
openlane:
	cd $(OPENLANE_DIR) && \
		cd docker_build && \
		$(MAKE) merge

.PHONY: regression
regression:
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(OPENLANE_DIR):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) $(IMAGE_NAME) sh -c "python3 run_designs.py -dts -dl -tar logs reports -html -t $(REGRESSION_TAG) -th $(THREADS) -p $(PRINT_REM_DESIGNS_TIME)"

.PHONY: regression_test
regression_test:
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(OPENLANE_DIR):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) $(IMAGE_NAME) sh -c "python3 run_designs.py -dts -dl -tar logs reports -html -t $(REGRESSION_TAG) -b $(BENCHMARK) -th $(THREADS) -p $(PRINT_REM_DESIGNS_TIME)"

.PHONY: test
test:
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(OPENLANE_DIR):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) $(IMAGE_NAME) sh -c "./flow.tcl -design $(TEST_DESIGN) -tag openlane_test -disable_output -overwrite"
	@[[ -f $(OPENLANE_DIR)/designs/$(TEST_DESIGN)/runs/openlane_test/results/magic/$(TEST_DESIGN).gds ]] && \
		echo "Basic test passed" || \
		echo "Basic test failed"

.PHONY: clean_runs
clean_runs:
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(OPENLANE_DIR):/openLANE_flow $(IMAGE_NAME) sh -c "./clean_runs.tcl"

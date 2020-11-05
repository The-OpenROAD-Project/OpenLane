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

# The openlane directory root
OPENLANE_DIR ?= $(shell pwd)
# Number of threads to use
THREADS ?= $(shell nproc)
# Location of the PDK inside the docker
PDK_ROOT ?= /tmp/pdks
# Location of PDK outside the docker
PDK_BASE ?= $(shell pwd)/pdks
# Image name of the docker
IMAGE_NAME ?= openlane:rc4
# The benchmark result to compare against 
BENCHMARK ?= regression_results/benchmark_results/SW_HD.csv
# The regression result tag to use
REGRESSION_TAG ?= TEST_SW_HD
# Test design for the test target
TEST_DESIGN ?= spm
# Print the remaining desings every $PRINT_REM_DESIGNS_TIME seconds
# During the regression run
PRINT_REM_DESIGNS_TIME ?= 0

.DEFAULT_GOAL := all

.PHONY: all

all: pdk openlane

### PDK
pdk: 
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
		docker run -it -v $(OPENLANE_DIR):/openLANE_flow -v $(PDK_BASE):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) $(IMAGE_NAME) sh -c "python3 run_designs.py -dts -dl -tar logs reports -html -t $(REGRESSION_TAG) -th $(THREADS) -p $(PRINT_REM_DESIGNS_TIME)"

.PHONY: regression_test
regression_test:
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(OPENLANE_DIR):/openLANE_flow -v $(PDK_BASE):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) $(IMAGE_NAME) sh -c "python3 run_designs.py -dts -dl -tar logs reports -html -t $(REGRESSION_TAG) -b $(BENCHMARK) -th $(THREADS) -p $(PRINT_REM_DESIGNS_TIME)"

.PHONY: test
test:
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(OPENLANE_DIR):/openLANE_flow -v $(PDK_BASE):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) $(IMAGE_NAME) sh -c "./flow.tcl -design $(TEST_DESIGN) -tag openlane_test -disable_output -overwrite"
	@[[ -f $(OPENLANE_DIR)/designs/$(TEST_DESIGN)/runs/openlane_test/results/magic/$(TEST_DESIGN).gds ]] && \
		echo "Basic test passed" || \
		echo "Basic test failed"

.PHONY: clean_runs
clean_runs:
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(OPENLANE_DIR):/openLANE_flow $(IMAGE_NAME) sh -c "./clean_runs.tcl"

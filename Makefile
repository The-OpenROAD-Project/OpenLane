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
THREADS ?= 8
#location of the PDK inside the docker
PDK_ROOT ?= /pdks
#location of PDK outside the docker
PDK_BASE ?= $(OPENLANE_DIR)/pdks 
#Image name of the docker
IMAGE_NAME ?= openlane:rc3
#The benchmark result to compare against 
BENCHMARK ?= regression_results/benchmark_results/SW_HD.csv
#The regression result tag to use
REGRESSION_TAG ?= TEST_SW_HD

.DEFAULT_GOAL := all

.PHONY: all

all: skywater-pdk openlane

skywater-pdk: 
	git submodule update --init pdks/


openlane:
	cd $(OPENLANE_DIR) && \
		cd docker_build && \
		make merge && \
		cd ..

regression:
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(OPENLANE_DIR):/openLANE_flow -v $(PDK_BASE):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) $(IMAGE_NAME) bash -c "python3 run_designs.py -dts -dl -tar logs reports -html -t $(REGRESSION_TAG) -th $(THREADS)"

regression_test:
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(OPENLANE_DIR):/openLANE_flow -v $(PDK_BASE):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) $(IMAGE_NAME) bash -c "python3 run_designs.py -dts -dl -tar logs reports -html -t $(REGRESSION_TAG) -b $(BENCHMARK) -th $(THREADS)"

test:
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(OPENLANE_DIR):/openLANE_flow -v $(PDK_BASE):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) $(IMAGE_NAME) bash -c "./flow.tcl -design spm -tag openlane_test -overwrite"

clean_runs:
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(OPENLANE_DIR):/openLANE_flow $(IMAGE_NAME) bash -c "./clean_runs.tcl"

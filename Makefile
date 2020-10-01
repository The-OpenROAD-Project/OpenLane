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
THREADS ?= $(shell nproc)
STD_CELL_LIBRARY ?= sky130_fd_sc_hd

IMAGE_NAME ?= openlane:rc4
TEST_DESIGN ?= spm
BENCHMARK ?= regression_results/benchmark_results/SW_HD.csv
REGRESSION_TAG ?= TEST_SW_HD
PRINT_REM_DESIGNS_TIME ?= 0

.DEFAULT_GOAL := all

.PHONY: all

all: pdk openlane

pdk: skywater-pdk open_pdks

skywater-pdk: clone-skywater-pdk skywater-library

clone-skywater-pdk: check-env
	cd  $(PDK_ROOT) && \
		rm -rf skywater-pdk && \
		git clone https://github.com/google/skywater-pdk.git skywater-pdk && \
		cd skywater-pdk && \
		git checkout -qf 5cd70ed19fee8ea37c4e8dbd5c5c3eaa9886dd23

skywater-library: check-env
	cd  $(PDK_ROOT)/skywater-pdk && \
		git submodule update --init libraries/$(STD_CELL_LIBRARY)/latest && \
		make -j$(THREADS) $(STD_CELL_LIBRARY)

all-skywater-libraries: check-env
	cd  $(PDK_ROOT)/skywater-pdk && \
		git submodule update --init libraries/sky130_fd_sc_hd/latest && \
		git submodule update --init libraries/sky130_fd_sc_hs/latest && \
		git submodule update --init libraries/sky130_fd_sc_hdll/latest && \
		git submodule update --init libraries/sky130_fd_sc_ms/latest && \
		git submodule update --init libraries/sky130_fd_sc_ls/latest && \
		make -j$(THREADS) timing

open_pdks: clone-open_pdks install-open_pdks

clone-open_pdks: check-env
	cd $(PDK_ROOT) && \
		rm -rf open_pdks && \
		git clone https://github.com/RTimothyEdwards/open_pdks.git open_pdks && \
		cd open_pdks && \
		git checkout -qf 48db3e1a428ae16f5d4c86e0b7679656cf8afe3d	

install-open_pdks: check-env
	cd $(PDK_ROOT)/open_pdks && \
		./configure --with-sky130-source=$(PDK_ROOT)/skywater-pdk/libraries --with-sky130-local-path=$(PDK_ROOT) && \
		cd sky130 && \
		make && \
		make install-local


openlane:
	cd $(OPENLANE_DIR) && \
		cd docker_build && \
		make merge && \
		cd ..

regression: check-env
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(OPENLANE_DIR):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) $(IMAGE_NAME) bash -c "python3 run_designs.py -dts -dl -tar logs reports -html -t $(REGRESSION_TAG) -th $(THREADS) -p $(PRINT_REM_DESIGNS_TIME)"

regression_test: check-env
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(OPENLANE_DIR):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) $(IMAGE_NAME) bash -c "python3 run_designs.py -dts -dl -tar logs reports -html -t $(REGRESSION_TAG) -b $(BENCHMARK) -th $(THREADS) -p $(PRINT_REM_DESIGNS_TIME)"

test: check-env
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(OPENLANE_DIR):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) $(IMAGE_NAME) bash -c "./flow.tcl -design $(TEST_DESIGN) -tag openlane_test -overwrite"

clean_runs:
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(OPENLANE_DIR):/openLANE_flow $(IMAGE_NAME) bash -c "./clean_runs.tcl"



check-env:
ifndef PDK_ROOT
	$(error PDK_ROOT is undefined, please export it before running make)
endif

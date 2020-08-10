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

OPENLANE_DIR=$(shell pwd)
THREADS=8
STD_CELL_LIBRARY=sky130_fd_sc_hd


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
		git checkout -qf 3f310bcc264df0194b9f7e65b83c59759bb27480

skywater-library: check-env
	cd  $(PDK_ROOT)/skywater-pdk && \
		git submodule update --init libraries/$(STD_CELL_LIBRARY)/latest && \
		make $(STD_CELL_LIBRARY)

open_pdks: clone-open_pdks install-open_pdks

clone-open_pdks: check-env
	cd $(PDK_ROOT) && \
		rm -rf open_pdks && \
		git clone https://github.com/RTimothyEdwards/open_pdks.git open_pdks && \
		cd open_pdks && \
		git checkout -qf 60b4f62aabff2e4fd9df194b6db59e61a2bd2472

install-open_pdks: check-env
	cd $(PDK_ROOT)/open_pdks && \
		./configure --with-sky130-source=$(PDK_ROOT)/skywater-pdk/libraries --with-local-path=$(PDK_ROOT) && \
		make && \
		make install-local


openlane:
	cd $(OPENLANE_DIR) && \
		cd docker_build && \
		make merge && \
		cd ..

regression: check-env
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(shell pwd):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) openlane:rc3 bash -c "python3 run_designs.py -dts -dl -tar logs reports -html -t TEST -th $(THREADS)"

regression_test: check-env
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(shell pwd):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) openlane:rc3 bash -c "python3 run_designs.py -dts -dl -tar logs reports -html -t TEST_SW_HD -b regression_results/benchmark_results/SW_HD.csv -th $(THREADS)"

test: check-env
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(shell pwd):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) openlane:rc3 bash -c "./flow.tcl -design spm -tag openlane_test -overwrite"

clean_runs:
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(shell pwd):/openLANE_flow openlane:rc3 bash -c "./clean_runs.tcl"



check-env:
ifndef PDK_ROOT
	$(error PDK_ROOT is undefined, please export it before running make)
endif

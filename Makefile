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
THREADS=5

.DEFAULT_GOAL := all

.PHONY: pdk openlane

all: pdk openlane

pdk: skywater-pdk open_pdks

skywater-pdk: check-env
	cd  $(PDK_ROOT) && \
		git clone https://github.com/google/skywater-pdk.git && \
		cd skywater-pdk && \
		git checkout 4e5e318e0cc578090e1ae7d6f2cb1ec99f363120 && \
		git submodule update --init libraries/sky130_fd_sc_hd/latest && \
		make sky130_fd_sc_hd 

open_pdks: check-env 
	cd $(PDK_ROOT) && \
		git clone https://github.com/efabless/open_pdks.git && \
		cd open_pdks && \
		make && \
		make install-local 


openlane: check-env
	cd $(OPENLANE_DIR) && \
		cd docker_build && \
		make merge && \
		cd ..

regression: check-env
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(shell pwd):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) openlane:rc2 bash -c "python3 run_designs.py -dts -dl -html -t TEST -th $(THREADS)"

regression_test: check-env
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(shell pwd):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) openlane:rc2 bash -c "python3 run_designs.py -dts -dl -html -t TEST -b regression_results/benchmarks/SW_HD.csv -th $(THREADS)"

test: check-env
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(shell pwd):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) openlane:rc2 bash -c "./flow.tcl -design spm -tag openlane_test -overwrite"

clean_runs: 
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(shell pwd):/openLANE_flow openlane:rc2 bash -c "./clean_runs.tcl"



check-env:
ifndef PDK_ROOT
	$(error PDK_ROOT is undefined, please export it before running make)
endif


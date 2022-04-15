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

# This file is intended to be included by the top-level Makefile.
# Please don't use it directly. Consider efabless/volare instead.

STD_CELL_LIBRARY ?= sky130_fd_sc_hd
SPECIAL_VOLTAGE_LIBRARY ?= sky130_fd_sc_hvl
IO_LIBRARY ?= sky130_fd_io

LIBRARY_LIST ?= $(STD_CELL_LIBRARY) $(IO_LIBRARY) $(SPECIAL_VOLTAGE_LIBRARY) sky130_fd_pr
ifeq ($(FULL_PDK),1)
LIBRARY_LIST = sky130_fd_sc_hd sky130_fd_sc_hs sky130_fd_sc_hdll sky130_fd_sc_ms sky130_fd_sc_ls sky130_fd_sc_hvl sky130_fd_io sky130_fd_pr
endif
ifeq ($(NATIVE_PDK),1)
ENV_COMMAND = env
endif

OPEN_PDK_ARGS ?= --enable-sram-sky130

.PHONY: build-pdk-conda
build-pdk-conda: skywater-pdk skywater-library open_pdks build-open_pdks gen-sources

$(PDK_ROOT):
	mkdir -p $(PDK_ROOT)

$(PDK_ROOT)/skywater-pdk/LICENSE: | $(PDK_ROOT)
	git clone $(shell $(PYTHON_BIN) ./dependencies/tool.py sky130 -f repo) $(PDK_ROOT)/skywater-pdk

.PHONY: skywater-pdk
skywater-pdk: $(PDK_ROOT)/skywater-pdk/LICENSE
	cd $(PDK_ROOT)/skywater-pdk && \
		git checkout main && \
		git submodule init && git pull --no-recurse-submodules && \
		git checkout -qf $(SKYWATER_COMMIT)

.PHONY: skywater-library
skywater-library: $(PDK_ROOT)/skywater-pdk
	cd $(PDK_ROOT)/skywater-pdk && \
		for library in $(LIBRARY_LIST); do \
			git submodule update --init libraries/$$library/latest ;\
		done; \
		$(MAKE) -j$(NPROC) timing

### OPEN_PDKS
$(PDK_ROOT)/open_pdks:
	git clone $(shell $(PYTHON_BIN) ./dependencies/tool.py open_pdks -f repo) $(PDK_ROOT)/open_pdks

.PHONY: open_pdks
open_pdks: $(PDK_ROOT)/ $(PDK_ROOT)/open_pdks
	cd $(PDK_ROOT)/open_pdks && \
		git checkout master && \
		git pull && \
		git checkout -qf $(OPEN_PDKS_COMMIT)

.PHONY: build-open_pdks
build-open_pdks: $(PDK_ROOT)/open_pdks $(PDK_ROOT)/skywater-pdk
	[ -d $(PDK_ROOT)/sky130A ] && rm -rf $(PDK_ROOT)/sky130A || true
	
	$(ENV_COMMAND) sh -c "\
		cd $(PDK_ROOT)/open_pdks && \
		./configure --enable-sky130-pdk=$(PDK_ROOT)/skywater-pdk/libraries $(OPEN_PDK_ARGS)\
	"

	cd $(PDK_ROOT)/open_pdks/sky130 && \
		$(MAKE) veryclean && \
		$(MAKE) prerequisites
	
	$(ENV_COMMAND) sh -c "\
		cd $(PDK_ROOT)/open_pdks/sky130 && \
		make && \
		make SHARED_PDKS_PATH=$(PDK_ROOT) install && \
		make clean \
	"

gen-sources: $(PDK_ROOT)/sky130A
	touch $(PDK_ROOT)/sky130A/SOURCES
	OPENLANE_COMMIT=$(git rev-parse HEAD)
	printf "openlane " > $(PDK_ROOT)/sky130A/SOURCES
	cd $(OPENLANE_DIR) && git rev-parse HEAD >> $(PDK_ROOT)/sky130A/SOURCES
	printf "magic " >> $(PDK_ROOT)/sky130A/SOURCES
	python3 ./dependencies/tool.py -f commit magic >> $(PDK_ROOT)/sky130A/SOURCES
	printf "\n" >> $(PDK_ROOT)/sky130A/SOURCES
	printf "skywater-pdk " >> $(PDK_ROOT)/sky130A/SOURCES
	cd $(PDK_ROOT)/skywater-pdk && git rev-parse HEAD >> $(PDK_ROOT)/sky130A/SOURCES
	printf "open_pdks " >> $(PDK_ROOT)/sky130A/SOURCES
	cd $(PDK_ROOT)/open_pdks && git rev-parse HEAD >> $(PDK_ROOT)/sky130A/SOURCES

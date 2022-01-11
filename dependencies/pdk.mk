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
# This file is intended to be included by the top-level Makefile. Please don't use it directly. :)

STD_CELL_LIBRARY ?= sky130_fd_sc_hd
SPECIAL_VOLTAGE_LIBRARY ?= sky130_fd_sc_hvl
IO_LIBRARY ?= sky130_fd_io
INSTALL_SRAM ?= disabled

OPEN_PDK_ARGS ?= ""
ifeq ($(INSTALL_SRAM), enabled)
OPEN_PDK_ARGS += --enable-sram-sky130
else ifneq ($(INSTALL_SRAM), disabled)
OPEN_PDK_ARGS += --enable-sram-sky130=$(INSTALL_SRAM)
endif 

.PHONY: pdk
pdk: skywater-pdk skywater-library open_pdks build-pdk gen-sources

.PHONY: native-pdk
native-pdk: skywater-pdk skywater-library open_pdks native-build-pdk gen-sources

.PHONY: full-pdk
full-pdk: skywater-pdk all-skywater-libraries open_pdks build-pdk gen-sources

.PHONY: native-full-pdk
native-full-pdk: skywater-pdk all-skywater-libraries open_pdks native-build-pdk gen-sources

$(PDK_ROOT):
	mkdir -p $(PDK_ROOT)

$(PDK_ROOT)/skywater-pdk/LICENSE: $(PDK_ROOT)
	git clone $(shell $(PYTHON_BIN) ./dependencies/tool.py sky130 -f repo) $(PDK_ROOT)/skywater-pdk

.PHONY: skywater-pdk
skywater-pdk: $(PDK_ROOT)/skywater-pdk/LICENSE
	cd $(PDK_ROOT)/skywater-pdk && \
		git checkout main && git submodule init && git pull --no-recurse-submodules && \
		git checkout -qf $(SKYWATER_COMMIT)

.PHONY: skywater-library
skywater-library: $(PDK_ROOT)/skywater-pdk
	cd $(PDK_ROOT)/skywater-pdk && \
		git submodule update --init libraries/$(STD_CELL_LIBRARY)/latest && \
		git submodule update --init libraries/$(IO_LIBRARY)/latest && \
		git submodule update --init libraries/$(SPECIAL_VOLTAGE_LIBRARY)/latest && \
		git submodule update --init libraries/sky130_fd_pr/latest && \
		$(MAKE) -j$(NPROC) timing

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
		git submodule update --init libraries/sky130_fd_pr/latest && \
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

.PHONY: build-pdk
native-build-pdk: ENV_COMMAND=env
native-build-pdk: build-pdk
build-pdk: $(PDK_ROOT)/open_pdks $(PDK_ROOT)/skywater-pdk
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

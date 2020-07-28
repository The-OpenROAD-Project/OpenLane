
OPENLANE_DIR=$(shell pwd)
THREADS=5

.DEFAULT_GOAL := all

all: pdk openlane

pdk: skywater-pdk open_pdks

skywater-pdk:
	cd  $(PDK_ROOT) && \
		git clone https://github.com/google/skywater-pdk.git && \
		cd skywater-pdk && \
		git checkout 4e5e318e0cc578090e1ae7d6f2cb1ec99f363120 && \
		git submodule update --init libraries/sky130_fd_sc_hd/latest && \
		make sky130_fd_sc_hd 

open_pdks: 
	cd $(PDK_ROOT) && \
		git clone https://github.com/efabless/open_pdks.git && \
		cd open_pdks && \
		make && \
		make install-local 


openlane:
	cd $(OPENLANE_DIR) && \
		cd docker_build && \
		make merge && \
		cd ..

regression:
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(shell pwd):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) openlane:rc2 bash -c "python3 run_designs.py -dts -dl -html -t TEST -th $(THREADS)"

test:
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(shell pwd):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(shell id -u $(USER)):$(shell id -g $(USER)) openlane:rc2 bash -c "./flow.tcl -design spm -tag openlane_test -overwrite"

clean_runs: 
	cd $(OPENLANE_DIR) && \
		docker run -it -v $(shell pwd):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) openlane:rc2 bash -c "./clean_runs.tcl"


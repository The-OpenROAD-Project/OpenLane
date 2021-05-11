#DOCKER_BUILD_OPTS ?= --rm --no-cache
DOCKER_BUILD_OPTS ?= --rm
DOCKERFILE_PATH ?= ./Dockerfile
IMAGE_NAME ?= efabless/openlane:current
#ROOT = sudo

TOOLS = klayout replace opendp route cugr drcu opensta yosys antmicro_yosys magic openroad_app padring netgen vlogtoverilog openphysyn cvc

TOOL_BUILD_TARGETS = $(foreach tool,$(TOOLS),build-$(tool))
TOOL_EXPORT_TARGETS_PHONY = $(foreach tool,$(TOOLS),export-$(tool))
TOOL_EXPORT_TARGETS_REAL = $(foreach tool,$(TOOLS),tar/$(tool).tar.gz)
# ==============================================================================
# Build Tools
# ==============================================================================
build-all: $(TOOL_BUILD_TARGETS) export-all

$(TOOL_BUILD_TARGETS): build-% : ./docker/%/Dockerfile
	mkdir -p logs/docker
	docker build $(DOCKER_BUILD_OPTS) -t $* docker/$* | tee logs/docker/$*.build.txt
	${MAKE} export-$*

# ==============================================================================
# Export Tools
# ==============================================================================
.PHONY: $(TOOL_EXPORT_TARGETS)
$(TOOL_EXPORT_TARGETS_PHONY): export-% :
	rm -f tar/$*.tar.gz && echo "Deleted existing tar/$*.tar.gz"
	mkdir -p tar
	id=$$(${ROOT} docker create $*) ; \
	  ${ROOT} docker cp $$id:\build.tar.gz tar/$*.tar.gz ; \
	  ${ROOT} docker rm -v $$id

.PHONY: export-all
export-all: tar/openroad_tools.tar.gz
tar/openroad_tools.tar.gz: $(TOOL_EXPORT_TARGETS_REAL)
	for tarFile in $(foreach tool,$(TOOLS),tar/$(tool).tar.gz); do \
	  tar -xzf $$tarFile ; \
	done
	chmod -R +x ./build/bin
	find ./build/ -name "*.tcl" -exec chmod +x {} \;
	cd tar && tar -czf openroad_tools.tar.gz ../build

tar/openLANE_flow.tar.gz: FORCE
	cd tar && tar --exclude='../../.git' --exclude='../../docker_build' --exclude="../../designs" --exclude="../../pdks/" --exclude="../../logs/*" -czf openLANE_flow.tar.gz ../../

FORCE:

.PHONY: merge
merge: tar/openroad_tools.tar.gz tar/openLANE_flow.tar.gz
	mkdir -p logs/docker/tar
	docker build --build-arg CACHE_INVALIDATOR=$(shell date +%s) $(DOCKER_BUILD_OPTS) -t $(IMAGE_NAME) -f $(DOCKERFILE_PATH) ./tar | tee logs/docker/$<.build.txt ; \

.PHONY: clean_merge
clean_merge:
ifneq (,$(wildcard ./tar/openroad_tools.tar.gz))
ifneq (,$(wildcard ./tar/openLANE_flow.tar.gz))
		rm ./tar/openLANE_flow.tar.gz
		rm ./tar/openroad_tools.tar.gz
endif
endif

clean_export: 
	rm -rf export/*.tar.gz


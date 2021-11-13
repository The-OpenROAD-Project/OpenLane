#DOCKER_BUILD_OPTS ?= --rm --no-cache
DOCKER_BUILD_OPTS ?= --rm
DOCKERFILE_PATH ?= ./openlane/Dockerfile
OPENLANE_IMAGE_NAME ?= efabless/openlane:current
#ROOT = sudo

TOOLS = klayout cugr drcu yosys magic openroad_app padring netgen vlogtoverilog cvc

TOOL_BUILD_TARGETS = $(foreach tool,$(TOOLS),build-$(tool))
TOOL_EXPORT_TARGETS_PHONY = $(foreach tool,$(TOOLS),export-$(tool))
TOOL_EXPORT_TARGETS_REAL = $(foreach tool,$(TOOLS),tar/$(tool).tar.gz)
# ==============================================================================
# Build Tools
# ==============================================================================
build-all: $(TOOL_BUILD_TARGETS) export-all

base_image: ./base/Dockerfile
	cat ../dependencies/centos-7/precompile_time.txt > ./base/yum_precompile_dependencies.txt
	cat ../dependencies/centos-7/compile_time.txt > ./base/yum_compile_dependencies.txt
	cat ../dependencies/centos-7/run_time.txt > ./base/yum_dependencies.txt
	cat ../dependencies/python/precompile_time.txt > ./base/pip_precompile_dependencies.txt
	cat ../dependencies/python/compile_time.txt > ./base/pip_compile_dependencies.txt
	cat ../dependencies/python/run_time.txt > ./base/pip_dependencies.txt
	mkdir -p logs
	docker build $(DOCKER_BUILD_OPTS) -t openlane-build-base base | tee logs/base.build.txt

$(TOOL_BUILD_TARGETS): build-% : ./%/Dockerfile base_image
	mkdir -p logs
	docker build $(DOCKER_BUILD_OPTS) $(shell python3 ../dependencies/tool.py --docker-args $*) -t $* $* | tee logs/$*.build.txt
	${MAKE} export-$*

# ==============================================================================
# Export Tools
# ==============================================================================
.PHONY: $(TOOL_EXPORT_TARGETS)
$(TOOL_EXPORT_TARGETS_PHONY): export-% :
	rm -f tar/$*.tar.gz && echo "Deleted existing tar/$*.tar.gz"
	mkdir -p tar
	id=$$(${ROOT} docker create $*) ; \
	  ${ROOT} docker cp $$id:/build.tar.gz tar/$*.tar.gz ; \
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

tar/openlane.tar.gz: FORCE
	cd tar && tar --exclude='../../.git' --exclude='../../docker' --exclude="../../designs" --exclude="../../pdks" --exclude="../../logs/*" -czf openlane.tar.gz ../../

FORCE:

.PHONY: merge openlane
openlane: merge
merge: tar/openroad_tools.tar.gz tar/openlane.tar.gz ../dependencies/tool_metadata.yml
	cat ../dependencies/tool_metadata.yml > ./tar/tool_metadata.yml
	cat ../dependencies/python/run_time.txt > ./tar/pip_dependencies.txt
	cat ../dependencies/centos-7/run_time.txt > ./tar/yum_dependencies.txt
	printf "$(shell git rev-parse --short=7 HEAD)" > ./tar/git_version
	mkdir -p logs/tar
	docker build --build-arg CACHE_INVALIDATOR=$(shell date +%s) $(DOCKER_BUILD_OPTS) -t $(OPENLANE_IMAGE_NAME) -f $(DOCKERFILE_PATH) ./tar | tee logs/$<.build.txt ; \

.PHONY: clean_merge
clean_merge:
ifneq (,$(wildcard ./tar/openroad_tools.tar.gz))
ifneq (,$(wildcard ./tar/openlane.tar.gz))
		rm ./tar/openlane.tar.gz
		rm ./tar/openroad_tools.tar.gz
endif
endif

clean_export: 
	rm -rf export/*.tar.gz


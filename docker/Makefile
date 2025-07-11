TOOL_REPOSITORY ?= ghcr.io/the-openroad-project/openlane-tools

include ../dependencies/image_name.mk

BASE_HASH = $(shell $(PYTHON_BIN) ../dependencies/hash_for.py $(OS_NAME))

PYTHON_BIN ?= python3

OS_NAME := centos-7
OS_IMAGE := centos:centos7
BASE_HASH := $(shell $(PYTHON_BIN) ../dependencies/hash_for.py $(OS_NAME))
BUILD_ARCH ?= $(shell $(PYTHON_BIN) ./current_platform.py)

export BUILD_BASE_TAG := build-base-$(BASE_HASH)-$(OS_NAME)-$(BUILD_ARCH)
export RUN_BASE_TAG := run-base-$(BASE_HASH)-$(OS_NAME)-$(BUILD_ARCH)
BUILD_BASE_IMAGE := $(TOOL_REPOSITORY):$(BUILD_BASE_TAG)
RUN_BASE_IMAGE := $(TOOL_REPOSITORY):$(RUN_BASE_TAG)

# To use buildx: docker buildx build --push
export BUILD_COMMAND ?= docker build --no-cache

TOOLS = $(shell $(PYTHON_BIN) ../dependencies/tool.py --containerized --no-pdks .)
OPENLANE_SKELETON=configuration dependencies designs regression_results scripts AUTHORS.md env.py flow.tcl LICENSE run_designs.py
TOOL_BUILD_TARGETS = $(foreach tool,$(TOOLS),build-$(tool))
TOOL_EXPORT_TARGETS = $(foreach tool,$(TOOLS),pull-$(tool))


all: openlane

# Build/Run Base Images
build-all: $(TOOL_BUILD_TARGETS)
build-build-base: ./build_base/Dockerfile
	cat ../dependencies/centos-7/precompile_time.txt > ./build_base/yum_precompile_dependencies.txt
	cat ../dependencies/centos-7/compile_time.txt > ./build_base/yum_compile_dependencies.txt
	cat ../dependencies/centos-7/run_time.txt > ./build_base/yum_dependencies.txt
	cat ../dependencies/python/precompile_time.txt > ./build_base/pip_precompile_dependencies.txt
	cat ../dependencies/python/compile_time.txt > ./build_base/pip_compile_dependencies.txt
	cat ../dependencies/python/run_time.txt > ./build_base/pip_dependencies.txt
	mkdir -p logs
	$(BUILD_COMMAND)\
		--build-arg OS_IMAGE=$(BUILD_ARCH)/$(OS_IMAGE)\
		-t $(BUILD_BASE_IMAGE)\
		build_base | tee logs/base.build.txt

pull-build-base:
	$(PYTHON_BIN) ./utils.py pull-if-doesnt-exist --repository $(TOOL_REPOSITORY) --os $(OS_NAME) --architecture $(BUILD_ARCH) build-base
	@echo "-----------"

build-run-base: ./run_base/Dockerfile
	cat ../dependencies/python/run_time.txt > ./run_base/pip_dependencies.txt
	cat ../dependencies/centos-7/precompile_time.txt > ./run_base/yum_repos.txt
	cat ../dependencies/centos-7/run_time.txt > ./run_base/yum_dependencies.txt
	mkdir -p logs
	$(BUILD_COMMAND)\
		--build-arg OS_IMAGE=$(BUILD_ARCH)/$(OS_IMAGE)\
		-t $(RUN_BASE_IMAGE)\
		run_base | tee logs/base.run.txt

pull-run-base:
	$(PYTHON_BIN) ./utils.py pull-if-doesnt-exist --repository $(TOOL_REPOSITORY) --os $(OS_NAME) --architecture $(BUILD_ARCH) run-base
	@echo "-----------"

# Tool Images
$(TOOL_BUILD_TARGETS): build-% : ./%/Dockerfile pull-build-base
	mkdir -p logs
	cp ./utils.py $*
	$(BUILD_COMMAND)\
		`$(PYTHON_BIN) ../dependencies/tool.py --docker-args $*`\
		--build-arg RUN_BASE_IMAGE=$(RUN_BASE_IMAGE)\
		--build-arg BUILD_BASE_IMAGE=$(BUILD_BASE_IMAGE)\
		--target runnable\
		-t $(TOOL_REPOSITORY):`$(PYTHON_BIN) ../dependencies/tool.py --docker-tag-for-os=$(OS_NAME) --docker-arch=$(BUILD_ARCH) $*`\
		$* |\
		tee logs/$*.build.txt

$(TOOL_EXPORT_TARGETS): pull-% : FORCE
	$(PYTHON_BIN) ./utils.py pull-if-doesnt-exist --repository $(TOOL_REPOSITORY) --os $(OS_NAME) --architecture $(BUILD_ARCH) $*
	@echo "-----------"

# OpenLane Image
./tar/openlane: FORCE
	rm -rf ./tar/openlane
	mkdir -p ./tar/openlane
	for file in $(OPENLANE_SKELETON); do\
		$(PYTHON_BIN) ./utils.py copy-tree -i '*/runs/*' ../$$file ./tar/openlane/$$file ;\
	done

.PHONY: merge openlane
openlane: merge
merge: pull-run-base $(TOOL_EXPORT_TARGETS) ./tar/openlane ../dependencies/tool_metadata.yml
	cat ../dependencies/tool_metadata.yml > ./tar/tool_metadata.yml
	printf "$(shell git rev-parse HEAD)" > ./tar/git_version
	printf "$(shell git rev-parse --short=7 HEAD)" > ./tar/git_version_short
	$(PYTHON_BIN) ./utils.py process-dockerfile-tpl --repository $(TOOL_REPOSITORY) --os $(OS_NAME) $(TOOLS) > ./openlane/Dockerfile
	mkdir -p logs/tar
	$(BUILD_COMMAND)\
		--build-arg ARCH=$(BUILD_ARCH)\
		--build-arg RUN_BASE_IMAGE=$(RUN_BASE_IMAGE)\
		-t $(OPENLANE_IMAGE_NAME)-$(BUILD_ARCH)\
		-f ./openlane/Dockerfile ./tar\
		| tee logs/$<.build.txt
	rm -rf ./tar/openlane

# Cleanup
.PHONY: clean
clean: clean_export clean_merge

.PHONY: clean_merge
clean_merge:
	rm -rf ./tar/openlane

.PHONY: clean_export
clean_export: 
	rm -rf export/*.tar.gz

FORCE:

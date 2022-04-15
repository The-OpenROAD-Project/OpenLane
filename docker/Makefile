#DOCKER_BUILD_OPTS ?= --rm --no-cache
OPENLANE_IMAGE_NAME ?= efabless/openlane:current
TOOL_REPOSITORY ?= efabless/openlane-tools

OS_NAME ?= centos-7
OS_IMAGE ?= centos:centos7

DOCKER_BUILD_OPTS ?= --rm
DOCKER_BUILD_INVOCATION ?= docker build # docker buildx build --platform linux/amd64 --load
BUILD_COMMAND = $(DOCKER_BUILD_INVOCATION) $(DOCKER_BUILD_OPTS)

NO_PDKS_ARGS =
NO_PDKS ?= 1
ifeq ($(NO_PDKS), 1)
NO_PDKS_ARGS = --no-pdks
endif

PYTHON_BIN ?= python3
TOOLS = $(shell $(PYTHON_BIN) ../dependencies/tool.py --containerized $(NO_PDKS_ARGS) .)
OPENLANE_SKELETON=configuration dependencies designs regression_results scripts AUTHORS.md env.py flow.tcl LICENSE run_designs.py
TOOL_BUILD_TARGETS = $(foreach tool,$(TOOLS),build-$(tool))
TOOL_EXPORT_TARGETS = $(foreach tool,$(TOOLS),pull-$(tool))


# ==============================================================================
# Build Tools
# ==============================================================================
all: openlane

build-all: $(TOOL_BUILD_TARGETS)
build_base_image: ./build_base/Dockerfile
	cat ../dependencies/centos-7/precompile_time.txt > ./build_base/yum_precompile_dependencies.txt
	cat ../dependencies/centos-7/compile_time.txt > ./build_base/yum_compile_dependencies.txt
	cat ../dependencies/centos-7/run_time.txt > ./build_base/yum_dependencies.txt
	cat ../dependencies/python/precompile_time.txt > ./build_base/pip_precompile_dependencies.txt
	cat ../dependencies/python/compile_time.txt > ./build_base/pip_compile_dependencies.txt
	cat ../dependencies/python/run_time.txt > ./build_base/pip_dependencies.txt
	mkdir -p logs
	$(BUILD_COMMAND) -t openlane-build-base --build-arg OS_IMAGE=$(OS_IMAGE) build_base | tee logs/base.build.txt

run_base_image: ./run_base/Dockerfile
	cat ../dependencies/python/run_time.txt > ./run_base/pip_dependencies.txt
	cat ../dependencies/centos-7/precompile_time.txt > ./run_base/yum_repos.txt
	cat ../dependencies/centos-7/run_time.txt > ./run_base/yum_dependencies.txt
	mkdir -p logs
	$(BUILD_COMMAND) -t openlane-run-base --build-arg OS_IMAGE=$(OS_IMAGE) run_base | tee logs/base.run.txt


$(TOOL_BUILD_TARGETS): build-% : ./%/Dockerfile build_base_image run_base_image
	mkdir -p logs
	cp ./utils.py $*
	$(BUILD_COMMAND)\
		$(shell $(PYTHON_BIN) ../dependencies/tool.py --docker-args $*)\
		--target runnable\
		-t $(TOOL_REPOSITORY):$(shell $(PYTHON_BIN) ../dependencies/tool.py --docker-tag-for-os=$(OS_NAME) $*)\
		$* |\
		tee logs/$*.build.txt

# ==============================================================================
# Export Tools
# ==============================================================================
$(TOOL_EXPORT_TARGETS): pull-% : FORCE
	$(PYTHON_BIN) ./utils.py pull-if-doesnt-exist --repository $(TOOL_REPOSITORY) --os $(OS_NAME) $*

./tar/openlane: FORCE
	rm -rf ./tar/openlane
	mkdir -p ./tar/openlane
	for file in $(OPENLANE_SKELETON); do \
		cp -r ../$$file ./tar/openlane/$$file ; \
	done

.PHONY: merge openlane
openlane: merge
merge: run_base_image $(TOOL_EXPORT_TARGETS) ./tar/openlane ../dependencies/tool_metadata.yml
	cat ../dependencies/tool_metadata.yml > ./tar/tool_metadata.yml
	printf "$(shell git rev-parse HEAD)" > ./tar/git_version
	printf "$(shell git rev-parse --short=7 HEAD)" > ./tar/git_version_short
	$(PYTHON_BIN) ./utils.py process-dockerfile-tpl --repository $(TOOL_REPOSITORY) --os $(OS_NAME) $(TOOLS) > ./openlane/Dockerfile
	mkdir -p logs/tar
	$(BUILD_COMMAND)\
		-t $(OPENLANE_IMAGE_NAME)\
		-f ./openlane/Dockerfile ./tar\
		| tee logs/$<.build.txt
	rm -rf ./tar/openlane

.PHONY: clean
clean: clean_export clean_merge

.PHONY: clean_merge
clean_merge:
	rm -rf ./tar/openlane

.PHONY: clean_export
clean_export: 
	rm -rf export/*.tar.gz

FORCE:
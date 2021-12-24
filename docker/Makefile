#DOCKER_BUILD_OPTS ?= --rm --no-cache
DOCKERFILE_PATH ?= ./openlane/Dockerfile
OPENLANE_IMAGE_NAME ?= efabless/openlane:current
TOOL_REPOSITORY ?= efabless/openlane-tools

OS_NAME ?= centos-7
OS_IMAGE ?= centos:centos7

DOCKER_BUILD_OPTS ?= --rm
DOCKER_BUILD_INVOCATION ?= docker build # docker buildx build --platform linux/amd64 --load
BUILD_COMMAND = $(DOCKER_BUILD_INVOCATION) $(DOCKER_BUILD_OPTS)

TOOLS = cugr drcu yosys magic openroad_app padring netgen vlogtoverilog cvc git

TOOL_BUILD_TARGETS = $(foreach tool,$(TOOLS),build-$(tool))
TOOL_EXPORT_TARGETS = $(foreach tool,$(TOOLS),tar/$(tool).tar.gz)
# ==============================================================================
# Build Tools
# ==============================================================================
all: openlane

build-all: $(TOOL_BUILD_TARGETS)
base_image: ./base/Dockerfile
	cat ../dependencies/centos-7/precompile_time.txt > ./base/yum_precompile_dependencies.txt
	cat ../dependencies/centos-7/compile_time.txt > ./base/yum_compile_dependencies.txt
	cat ../dependencies/centos-7/run_time.txt > ./base/yum_dependencies.txt
	cat ../dependencies/python/precompile_time.txt > ./base/pip_precompile_dependencies.txt
	cat ../dependencies/python/compile_time.txt > ./base/pip_compile_dependencies.txt
	cat ../dependencies/python/run_time.txt > ./base/pip_dependencies.txt
	mkdir -p logs
	$(BUILD_COMMAND) -t openlane-build-base --build-arg OS_IMAGE=$(OS_IMAGE) base | tee logs/base.build.txt

$(TOOL_BUILD_TARGETS): build-% : ./%/Dockerfile base_image
	mkdir -p logs
	cp ./utils.py $*
	$(BUILD_COMMAND)\
		$(shell python3 ../dependencies/tool.py --docker-args $*)\
		-t $(TOOL_REPOSITORY):$(shell python3 ../dependencies/tool.py --docker-tag-for-os=$(OS_NAME) $*)\
		$* |\
		tee logs/$*.build.txt

# ==============================================================================
# Export Tools
# ==============================================================================
$(TOOL_EXPORT_TARGETS): tar/%.tar.gz : FORCE
	rm -f tar/$*.tar.gz && echo "Deleted existing tar/$*.tar.gz"
	mkdir -p tar
	python3 ./utils.py pull-if-doesnt-exist $(TOOL_REPOSITORY):$(shell python3 ../dependencies/tool.py --docker-tag-for-os=$(OS_NAME) $*)
	id=$$(${ROOT} docker create $(TOOL_REPOSITORY):$(shell python3 ../dependencies/tool.py --docker-tag-for-os=$(OS_NAME) $*)) ; \
	  ${ROOT} docker cp $$id:/build.tar.gz tar/$*.tar.gz ; \
	  ${ROOT} docker rm -v $$id

tar/openroad_tools.tar.gz: $(TOOL_EXPORT_TARGETS)
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
	cat ../dependencies/centos-7/precompile_time.txt > ./tar/yum_repos.txt
	cat ../dependencies/centos-7/run_time.txt > ./tar/yum_dependencies.txt
	printf "$(shell git rev-parse --short=7 HEAD)" > ./tar/git_version
	mkdir -p logs/tar
	$(BUILD_COMMAND)\
		--build-arg CACHE_INVALIDATOR=$(shell date +%s)\
		--build-arg OS_IMAGE=$(OS_IMAGE)\
		-t $(OPENLANE_IMAGE_NAME)\
		-f $(DOCKERFILE_PATH) ./tar\
		| tee logs/$<.build.txt

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


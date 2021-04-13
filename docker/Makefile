
# Copyright 2021 Rob Taylor
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
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

CACHE_ID ?= efabless
DOCKER_ID ?= $(CACHE_ID)
IMAGE_NAME ?= $(shell make -s -C ../ PDK_ROOT=DUMMY image_name)
TARGET_ARCHS ?= amd64 arm64 #ppc64le
BUILDX_OPTIONS ?=
CROSS_BUILD ?=
HOST_ARCH ?= $(shell uname -m)
CACHE_DIR = $(ROOT_DIR)/docker-cache

ifeq ($(HOST_ARCH),x86_64)
  HOST_ARCH = amd64
endif

include comma-seperate.mk
BASES = base boost_base
TOOLS = replace opendp route opensta yosys antmicro_yosys magic openroad_app padring netgen vlog2verilog openphysyn cvc cugr klayout drcu
STAGES = $(BASES) $(TOOLS)

default: openlane

.PHONY: print-bases print-tools
print-bases:
	@echo $(BASES)
print-tools:
	@echo $(TOOLS)

.PHONY: build-all-message push-all-message

ifdef CROSS_BUILD
STAGE_BUILD_TARGETS := $(foreach arch,$(TARGET_ARCHS),$(foreach comp,$(STAGES),build-$(comp)-$(arch)))
STAGE_PUSH_TARGETS := $(foreach arch,$(TARGET_ARCHS),$(foreach comp,$(STAGES),push-$(comp)-$(arch)))
MULTIARCH = $(call comma-separate,$(foreach arch,$(TARGET_ARCHS),linux/$(arch)))
STAGE_TAGS := $(foreach comp,$(STAGES),$(foreach arch,$(TARGET_ARCHS),$(CACHE_ID)/openlane-$(comp)-$(arch)))
BASE_TAGS := $(foreach base,$(BASES),$(foreach arch,$(TARGET_ARCHS),$(CACHE_ID)/openlane-$(base)-$(arch)))
build-all-message:
	@echo "Building tools for $(TARGET_ARCHS)"

push-all-message:
	@echo "Pushing tools for $(TARGET_ARCHS)"
else

STAGE_BUILD_TARGETS := $(foreach comp,$(STAGES),build-$(comp)-$(HOST_ARCH))
STAGE_PUSH_TARGETS := $(foreach comp,$(STAGES),push-$(comp)-$(HOST_ARCH))
MULTIARCH = linux/$(HOST_ARCH)
STAGE_TAGS := $(foreach comp,$(STAGES),$(CACHE_ID)/openlane-$(comp)-$(HOST_ARCH))
BASE_TAGS := $(foreach comp,$(BASES),$(CACHE_ID)/openlane-$(comp)-$(HOST_ARCH))

build-all-message:
	@echo "Building tools for $(HOST_ARCH)"

push-all-message:
	@echo "Pushing tools for $(HOST_ARCH)"
endif

SHELL=/bin/bash -o pipefail

build-all: build-all-message $(STAGE_BUILD_TARGETS)
push-all: push-all-message $(STAGE_PUSH_TARGETS)

.PHONY: cache build-all
cache: build-all push-all


STAGE_CACHE := $(foreach tag,$(STAGE_TAGS),--cache-from=$(tag))
BASE_CACHE := $(foreach tag,$(BASE_TAGS),--cache-from=$(tag))


.PHONY: openlane
openlane: Dockerfile docker-builder
	@echo "Building $(IMAGE_NAME) for $(MULTIARCH)"
	@mkdir -p ../logs/docker
	docker buildx build --push --platform $(MULTIARCH) -t $(IMAGE_NAME) --cache-from=$(CACHE_ID)/tools --build-arg BUILDKIT_INLINE_CACHE=1 $(BUILDX_OPTIONS) -f Dockerfile --progress plain .. 2>&1 | tee ../logs/docker/openlane.build.txt

.PHONY: tools
tools: Dockerfile docker-builder
	@echo "Building tools for $(MULTIARCH)"
	@mkdir -p ../logs/docker
	docker buildx build --push --platform $(MULTIARCH) -t $(CACHE_ID)/tools $(STAGE_CACHE) --build-arg BUILDKIT_INLINE_CACHE=1 $(BUILDX_OPTIONS) -f Dockerfile --progress plain .. 2>&1 | tee ../logs/docker/openlane.build.txt


.PHONY:
docker-builder:
	@echo "Checking buildx builder"
	docker buildx inspect openlane-multiarch >/dev/null 2>&1 > /dev/null || \
		docker buildx create --name openlane-multiarch --buildkitd-flags "--oci-worker-gc-keepstorage=9000 --debug" --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=8388608 --driver-opt image=tonistiigi/buildkit:tcp-concurrency-fix
	docker buildx use openlane-multiarch

$(STAGE_BUILD_TARGETS): build-% : Dockerfile docker-builder
	@mkdir -p ../logs/docker
	@rm -rf ../logs/docker/$*.build.txt
	build="$*" ; \
	target="$${build%-*}" ; \
	arch="$${build#*-}" ; \
	docker buildx build --platform linux/$$arch --cache-from "type=local,src=$(CACHE_DIR)" $(BASE_CACHE) --cache-to "type=local,dest=$(CACHE_DIR),mode=max" --target $$target -t $(CACHE_ID)/openlane-$$build -f Dockerfile --progress plain  .. 2>&1 | tee ../logs/docker/$*.build.txt


$(STAGE_PUSH_TARGETS): push-% : Dockerfile docker-builder
	@mkdir -p ../logs/docker
	@rm -rf ../logs/docker/$*.build.txt
	build="$*" ; \
	target="$${build%-*}" ; \
	arch="$${build#*-}" ; \
	docker buildx build --platform linux/$$arch --cache-from "type=registry,ref=$(CACHE_ID)/openlane-$$build" $(BASE_CACHE)  --cache-from "type=local,src=$(CACHE_DIR)" --build-arg  BUILDKIT_INLINE_CACHE=1 --target=$$target -t $(CACHE_ID)/openlane-$$build -f Dockerfile --progress plain --push ..  2>&1 | tee ../logs/docker/$*.build.txt

clean-cache:
	@rm -rf $(CACHE_DIR)

image_name:
	@echo $(IMAGE_NAME)

stages:
	@echo $(STAGES)

__DIRNAME__ := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))


ifeq ($(OPENLANE_IMAGE_NAME),)
OPENLANE_DOCKER_TAG ?= $(shell $(PYTHON_BIN) $(__DIRNAME__)/get_tag.py)
ifneq ($(OPENLANE_DOCKER_TAG),)
export OPENLANE_IMAGE_NAME ?= ghcr.io/the-openroad-project/openlane:$(OPENLANE_DOCKER_TAG)
endif
endif

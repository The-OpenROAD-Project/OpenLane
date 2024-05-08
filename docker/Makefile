PYTHON_BIN ?= python3
BUILD_ARCH ?= $(shell $(PYTHON_BIN) ./current_platform.py)
NIX_SYSTEM := $(shell $(PYTHON_BIN) ./current_system.py $(BUILD_ARCH))

HASH = $(shell git rev-parse HEAD)
HASH_SHORT = $(shell git rev-parse --short=7 HEAD)

all: openlane
merge: openlane

.PHONY: openlane
openlane:
	NIX_SYSTEM=$(NIX_SYSTEM) BUILD_ARCH=$(BUILD_ARCH) bash build.sh

PYTHON_BIN ?= python3
BUILD_ARCH ?= $(shell $(PYTHON_BIN) ./current_platform.py)
NIX_SYSTEM := $(shell $(PYTHON_BIN) ./current_system.py $(BUILD_ARCH))

HASH = $(shell git rev-parse HEAD)
HASH_SHORT = $(shell git rev-parse --short=7 HEAD)
define BUILD_CMD
nix build\
	--print-out-paths\
	--accept-flake-config\
	--accept-flake-config\
	--option system $(NIX_SYSTEM)\
	--extra-platforms $(NIX_SYSTEM)\
	..#packages.$(NIX_SYSTEM).openlane1-docker
endef

all: openlane
merge: openlane

.PHONY: openlane
openlane:
	$(BUILD_CMD)
	cat ./result | docker load

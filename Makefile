# Dockerized build helper for STM32 firmware

# Image name to use/build
IMAGE ?= stm32build:latest

# Build configuration (matches CMakePresets in firmware/)
CONFIG ?= Debug

# Build output directory derived from presets (relative to firmware/)
BUILD_DIR ?= build/$(CONFIG)

# Generator used by CMake (presets default to Ninja)
GENERATOR ?= Ninja

# CMake commands (use presets defined in firmware/CMakePresets.json)
# Working directory is set to firmware/ in DOCKER_RUN
CMAKE_CONFIG = cmake --preset $(CONFIG)
CMAKE_BUILD  = cmake --build --preset $(CONFIG) --parallel

# Docker run helper (mount current workspace and map user/group)
DOCKER_RUN = docker run --rm -t \
  -u $(shell id -u):$(shell id -g) \
  -v $(CURDIR):/workspace \
  -w /workspace/firmware

.PHONY: all help docker-build build clean rebuild shell

all: build

help:
	@echo "Targets:"
	@echo "  docker-build  - Build docker image $(IMAGE) in current directory"
	@echo "  build         - Configure and build ($(CONFIG)) inside container"
	@echo "  clean         - Remove $(BUILD_DIR) inside container"
	@echo "  rebuild       - Clean then build"
	@echo "  shell         - Open interactive shell in the container"
	@echo ""
	@echo "Variables:"
	@echo "  IMAGE=<name:tag>     (default: $(IMAGE))"
	@echo "  CONFIG=Debug|Release (default: $(CONFIG))"
	@echo "  GENERATOR=Ninja|...  (default: $(GENERATOR))"
	@echo "  BUILD_DIR=<path>     (default: $(BUILD_DIR))"

docker-build:
	docker build -t $(IMAGE) .

build:
	$(DOCKER_RUN) $(IMAGE) bash -lc '$(CMAKE_CONFIG) && $(CMAKE_BUILD)'

clean:
	$(DOCKER_RUN) $(IMAGE) bash -lc 'rm -rf $(BUILD_DIR)'

flash:
	sudo dfu-util -a 0 -s 0x08000000:leave -D firmware/build/Debug/slot_hat_firmware.bin

flash-stlink:
	st-flash --reset write firmware/$(BUILD_DIR)/slot_hat_firmware.bin 0x08000000

rebuild: clean build

shell:
	$(DOCKER_RUN) -it $(IMAGE) bash

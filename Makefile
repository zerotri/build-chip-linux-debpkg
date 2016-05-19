CONTAINER=ntc/chip-linux-debpkg:v1
ENVIRONMENTFILE=$(shell pwd)/sources/environment
BUILD_DIR=$(shell pwd)/build
SOURCES_DIR=$(shell pwd)/sources
VOLUME=$(BUILD_DIR):/opt/build
JOBS=-j16

define docker_run
	@docker run -i -t \
	--env-file=$(ENVIRONMENTFILE) \
	--volume=$(VOLUME) \
	$(CONTAINER) \
	make -C /opt/chip-linux O=/opt/build/linux $(JOBS) $(2)
endef

all: prebuild
	$(call docker_run,-j16)

container:
	@docker build -t \
	$(CONTAINER) \
	$(SOURCES_DIR)

defconfig:
	$(call docker_run,multi_v7_defconfig)

%_defconfig:
	@echo "Switching to kernel config: $@"
	$(call docker_run,$@)

debpkg:
	$(call docker_run,prepare)
	$(call docker_run,modules_prepare)
	$(call docker_run,scripts)
	$(call docker_run,bindeb-pkg)

nconfig:
	$(call docker_run,nconfig)

clean:
	$(call docker_run,clean)

mrproper:
	$(call docker_run,mrproper)

prebuild:
	@mkdir -p $(BUILD_DIR)/linux
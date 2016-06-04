CONTAINER=ntc/chip-linux-debpkg:v1
ENVIRONMENTFILE=$(shell pwd)/sources/environment
BUILD_DIR=$(shell pwd)/build
SOURCES_DIR=$(shell pwd)/sources
VOLUME=kernel-build:/opt/build
OUTPUT_VOLUME=${BUILD_DIR}:/opt/outputs
JOBS="-j16"

define docker_make
	@docker run -i -t \
	--env-file=$(ENVIRONMENTFILE) \
	--volume=$(VOLUME) \
	--workdir=/opt/build/linux \
	$(CONTAINER) \
	make -C /opt/chip-linux O=/opt/build/linux $(JOBS) $(1)
endef

define docker_run
	@docker run -i -t \
	--env-file=$(ENVIRONMENTFILE) \
	--volume=$(VOLUME) \
	--volume=$(OUTPUT_VOLUME) \
	$(CONTAINER) \
	$(1)
endef

all: prebuild
	$(call docker_make)

container:
	@docker volume create --name kernel-dl
	@docker volume create --name kernel-build
	@docker build -t \
	$(CONTAINER) \
	$(SOURCES_DIR)

output:
	$(call docker_run, ls /opt/build )
	$(call docker_run, cp /opt/build/linux-image-4.4.11-dev_4.4.6-osxbuild_armhf.deb /opt/outputs)

#checkconfig:
#	$(call docker_run, bash /opt/build/check-config.sh /opt/build/linux/.config )
defconfig:
	$(call docker_make,multi_v7_defconfig)
	$(call docker_run, /opt/chip-linux/scripts/config --file /opt/build/linux/.config \
		-e CONFIG_NAMESPACES \
		-e CONFIG_NET_NS \
		-e CONFIG_PID_NS \
		-e CONFIG_IPC_NS \
		-e CONFIG_UTS_NS \
		-e CONFIG_DEVPTS_MULTIPLE_INSTANCES \
		-e CONFIG_CGROUPS \
		-e CONFIG_CGROUP_CPUACCT \
		-e CONFIG_CGROUP_DEVICE \
		-e CONFIG_CGROUP_FREEZER \
		-e CONFIG_CGROUP_SCHED \
		-e CONFIG_CPUSETS \
		-e CONFIG_MEMCG \
		-e CONFIG_KEYS \
		-e CONFIG_MACVLAN \
		-e CONFIG_VETH \
		-e CONFIG_BRIDGE \
		-e CONFIG_BRIDGE_NETFILTER \
		-e CONFIG_NET_SCHED \
		-e CONFIG_NET_CLS_CGROUP \
		-e CONFIG_CGROUP_NET_PRIO \
		-e CONFIG_NF_CONNTRACK \
		-e CONFIG_NF_CONNTRACK_IPV4 \
		-e CONFIG_NF_NAT \
		-e CONFIG_NF_NAT_NEEDED \
		-e CONFIG_NF_NAT_IPV4 \
		-e CONFIG_IP_NF_NAT \
		-e CONFIG_IP_NF_FILTER \
		-e CONFIG_IP_NF_TARGET_MASQUERADE \
		-e CONFIG_NETFILTER_XT_MATCH_ADDRTYPE \
		-e CONFIG_NETFILTER_XT_MATCH_CONNTRACK \
		-e CONFIG_POSIX_MQUEUE \
		-e CONFIG_USER_NS \
		-e CONFIG_SECCOMP \
		-e CONFIG_CGROUP_PIDS \
		-e CONFIG_MEMCG_SWAP \
		-e CONFIG_MEMCG_SWAP_ENABLED \
		-e CONFIG_MEMCG_KMEM \
		-e CONFIG_RESOURCE_COUNTERS \
		-e CONFIG_BLK_CGROUP \
		-e CONFIG_BLK_DEV_THROTTLING \
		-e CONFIG_IOSCHED_CFQ \
		-e CONFIG_CFQ_GROUP_IOSCHED \
		-e CONFIG_CGROUP_PERF \
		-e CONFIG_NETPRIO_CGROUP \
		-e CONFIG_CFS_BANDWIDTH \
		-e CONFIG_FAIR_GROUP_SCHED \
		-e CONFIG_RT_GROUP_SCHED \
		-e CONFIG_RT_GROUP_SCHED \
		-e CONFIG_EXT3_FS \
		-e CONFIG_EXT3_FS_XATTR \
		-e CONFIG_EXT3_FS_POSIX_ACL \
		-e CONFIG_EXT3_FS_SECURITY \
		-e CONFIG_EXT4_FS \
		-e CONFIG_EXT4_FS_POSIX_ACL \
		-e CONFIG_EXT4_FS_SECURITY \
		-e CONFIG_VXLAN \
		-e CONFIG_MD \
		-e CONFIG_BLK_DEV_DM \
		-e CONFIG_DM_THIN_PROVISIONING \
		-e CONFIG_OVERLAY_FS)

%_defconfig:
	@echo "Switching to kernel config: $@"
	$(call docker_make,$@)

debpkg:
	$(call docker_make,prepare)
	$(call docker_make,modules_prepare)
	$(call docker_make,scripts)
	$(call docker_make,bindeb-pkg)

nconfig:
	$(call docker_make,nconfig)

clean:
	$(call docker_make,clean)

mrproper:
	$(call docker_make,mrproper)

prebuild:
	@mkdir -p $(BUILD_DIR)/linux

%:
	$(call docker_make, $@)
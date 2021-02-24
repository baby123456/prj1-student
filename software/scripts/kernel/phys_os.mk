# TODO: set your repo PATH for Linux kernel and release version to checkout
KERN_REPO_PATH := /home/changyisong/zcu102_linux_boot_up/software/mpsoc_linux_kernel
KERN_VERSION := xilinx-v2016.4-ZYPI

# TODO: set your Linux kernel compilation flags and targets
KERN_PLAT := arm64
KERN_CROSS_COMPILE_FLAGS := ARCH=$(KERN_PLAT) \
	CROSS_COMPILE=aarch64-linux-gnu-
KERN_TARGET := all

# TODO: Change to your own Linux kernel configuration file name
KERN_CONFIG := xilinx_zynqmp_defconfig
KERN_CONFIG_FILE := $(KERN_REPO_PATH)/arch/$(KERN_PLAT)/configs/$(KERN_CONFIG)

# TODO: Change to your own Linux kernel device tree file name
KERN_DT := zynqmp-zcu102-revB

# TODO: set your repo PATH for U-Boot and release version to checkout
UBOOT_REPO_PATH := /home/changyisong/zcu102_linux_boot_up/bootstrap/mpsoc_uboot
UBOOT_VERSION := xilinx-v2017.4

# TODO: set your U-Boot compilation flags and targets
UBOOT_CROSS_COMPILE_FLAGS := ARCH=arm \
	CROSS_COMPILE=aarch64-linux-gnu-
UBOOT_TARGET := all

# TODO: Change to your own U-Boot configuration file name
UBOOT_CONFIG := xilinx_zynqmp_zcu102_revB_defconfig
UBOOT_CONFIG_FILE := $(UBOOT_REPO_PATH)/configs/$(UBOOT_CONFIG)

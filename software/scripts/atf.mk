# TODO: set your repo PATH for ARM Trusted Firmware (ATF) and release version to checkout
ATF_REPO_PATH := /home/changyisong/zcu102_linux_boot_up/bootstrap/mpsoc_atf
ATF_VERSION := xilinx-v2017.4

# TODO: set your ATF compilation flags and targets
ATF_PLAT := zynqmp
ATF_CROSS_COMPILE_FLAGS := PLAT=$(ATF_PLAT) \
	RESET_TO_BL31=1 \
	CROSS_COMPILE=aarch64-linux-gnu- \
	LOG_LEVEL=40
ATF_TARGET := bl31

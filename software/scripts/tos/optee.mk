# TODO: set your repo PATH for OP-TEE OS and release version to checkout
OPTEE_OS_REPO_PATH := /home/changyisong/zcu102_linux_boot_up/bootstrap/optee
OPTEE_OS_VERSION := 2.4.0

# TODO: set your ATF compilation flags and targets
OPTEE_OS_PLAT := zynqmp
OPTEE_OS_CROSS_COMPILE_FLAGS := PLATFORM=$(OPTEE_OS_PLAT) \
	CFG_TEE_CORE_LOG_LEVEL=4 \
	CFG_TEE_TA_LOG_LEVEL=4 \
	CFG_ARM64_core=y
OPTEE_OS_TARGET := all 

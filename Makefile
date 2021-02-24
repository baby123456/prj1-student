# TODO: Change to your Vivado IDE version and installed location
VIVADO_VERSION ?= 2019.1
VIVADO_TOOL_BASE ?= /opt/Xilinx_$(VIVADO_VERSION)

# TODO: Change to your own Device Tree Compiler (DTC) location
DTC_LOC ?= /opt/dtc

# Vivado and SDK tool executable binary location
VIVADO_TOOL_PATH := $(VIVADO_TOOL_BASE)/Vivado/$(VIVADO_VERSION)/bin
SDK_TOOL_PATH := $(VIVADO_TOOL_BASE)/SDK/$(VIVADO_VERSION)/bin

# Cross-compiler location
#=================================================
# aarch-linux-gnu- : used for compilation of uboot, Linux kernel, ATF and other drivers
# aarch-none-gnu- : used for compilation of FSBL
# mb- (microblaze-xilinx-elf-) : used for compilation of PMU Firmware
#=================================================
LINUX_GCC_PATH := $(VIVADO_TOOL_BASE)/SDK/$(VIVADO_VERSION)/gnu/aarch64/lin/aarch64-linux/bin
ELF_GCC_PATH := $(VIVADO_TOOL_BASE)/SDK/$(VIVADO_VERSION)/gnu/aarch64/lin/aarch64-none/bin
MB_GCC_PATH := $(VIVADO_TOOL_BASE)/SDK/$(VIVADO_VERSION)/gnu/microblaze/lin/bin

# Leveraged Vivado tools
VIVADO_BIN := $(VIVADO_TOOL_PATH)/vivado
HSI_BIN := $(SDK_TOOL_PATH)/hsi
BOOT_GEN_BIN := $(SDK_TOOL_PATH)/bootgen

# Optional Trusted OS
TOS ?= none
BL32 := $(TOS)

# Linux kernel (i.e., Physical machine, Dom0, DomU)
# Default value is phys_os if not specified in command line
KERN_NAME ?= phys_os

# User-level Application target
APP ?= all

# Temporal directory to hold hardware design output files 
# (i.e., bitstream, hardware definition file (HDF))
HW_PLATFORM := $(shell pwd)/hw_plat
BITSTREAM := $(HW_PLATFORM)/system.bit
HW_DESIGN_HDF := $(HW_PLATFORM)/system.hdf

HW_PLAT_TEMP := $(shell pwd)/bootstrap/hw_plat

# Object files to generate BOOT.bin
BL2_BIN := ./bootstrap/fsbl/bl2.elf
PMU_FW := ./bootstrap/pmufw/pmufw.elf
BL31_BIN := ./software/atf/bl31.elf
BL33_BIN := ./software/uboot/u-boot.elf

BOOT_BIN_OBJS := $(BL31_BIN) $(BL33_BIN) $(BL2_BIN) $(PMU_FW)

ifneq (${TOS}, none)
BOOTBIN_WITH_TOS := y
endif
BOOTBIN_WITH_TOS ?= n

BOOTBIN_WITH_BIT ?= n
ifeq (${BOOTBIN_WITH_BIT}, y)
BOOT_BIN_OBJS += $(BITSTREAM)
endif

# Temporal directory to save all image files for porting
INSTALL_LOC := $(shell pwd)/ready_for_download

# FLAGS for sub-directory Makefile
ATF_COMPILE_FLAGS := COMPILER_PATH=$(LINUX_GCC_PATH) TOS=$(TOS)
OPTEE_COMPILE_FLAGS := COMPILER_PATH=$(LINUX_GCC_PATH) TOS=optee
UBOOT_COMPILE_FLAGS := COMPILER_PATH=$(LINUX_GCC_PATH) DTC_LOC=$(DTC_LOC)
KERNEL_COMPILE_FLAGS := COMPILER_PATH=$(LINUX_GCC_PATH) KERN_NAME=$(KERN_NAME) INSTALL_LOC=$(INSTALL_LOC)
APP_COMPILE_FLAGS := COMPILER_PATH=$(LINUX_GCC_PATH)

# HW_ACT list
#==========================================
# prj_gen: 		Creating Vivado project and generating hardware 
# 				definiation file (HDF)
# rtl_chk: 		Checking RTL syntax and synthesizability in this project
# sch_gen:		Generating gate-level schematic of a RTL module
# bhv_sim:		Launching behavioral simulation and 
# 				dumping the waveform file (.wdb)
# pst_sim:		Launching post-synthesis timing simulation and 
# 				dumping the waveform file (.wdb)
# wav_chk:		Opening waveform file of behavior or timing simulation
# dbg_set:		Setting up hardware debug cores according to configuration files
# 				located in directory of hardware/scripts/dbg
# dbg_rmv:		Removing hardware debug cores setup previously	 
# bit_gen:		Generating the bitstream file (.bit) via automatically 
# 				launching synthesis and implementation
# dcp_chk:		Opening a .dcp file generated in one of synth, placement 
# 				and routing 
#==========================================
# Default Vivado GUI launching flags if not specified in command line
HW_ACT ?= none

ifneq ($(findstring $(HW_ACT), "prj_gen bit_gen"), )
HW_VAL ?= all
else
HW_VAL ?= none
endif

# FPGA Evaluation
FPGA_RUN := $(shell pwd)/run/fpga_run.sh 

USER ?= none

BOARD_IP ?= none

.PHONY: FORCE

#==========================================
# Generation of BL31 (i.e., ARM Trusted Firmware (ATF)) 
# and optional BL32 Trusted OS (e.g., OP-TEE) 
#==========================================
atf $(BL31_BIN): $(BL32) FORCE
	@echo "Compiling ARM Trusted Firmware..."
	$(MAKE) -C ./software $(ATF_COMPILE_FLAGS) atf

atf_clean: $(BL32)_clean
	$(MAKE) -C ./software $(ATF_COMPILE_FLAGS) $@

atf_distclean: $(BL32)_distclean
	$(MAKE) -C ./software $(ATF_COMPILE_FLAGS) $@
	
none:
	@echo "No specified Trusted OS"

none_clean:
	@echo "No specified Trusted OS"

none_distclean:
	@echo "No specified Trusted OS"

optee: FORCE
	@echo "Compiling OP-TEE Trusted OS..."
	$(MAKE) -C ./software $(OPTEE_COMPILE_FLAGS) $@

optee_clean:
	$(MAKE) -C ./software $(OPTEE_COMPILE_FLAGS) $@

optee_distclean:
	$(MAKE) -C ./software $(OPTEE_COMPILE_FLAGS) $@

#==========================================
# Generation of BL33 image, including U-Boot,
# Linux kernel for virtual and non-virtual 
# environment, and optional Xen hypervisor
#==========================================
uboot $(BL33_BIN): FORCE
	@echo "Compiling U-Boot..."
	$(MAKE) -C ./software $(UBOOT_COMPILE_FLAGS) uboot

uboot_clean:
	$(MAKE) -C ./software $(UBOOT_COMPILE_FLAGS) $@

uboot_distclean:
	$(MAKE) -C ./software $(UBOOT_COMPILE_FLAGS) $@

kernel_image: FORCE
	@echo "Compiling Linux kernel..."
	@mkdir -p $(INSTALL_LOC)
	$(MAKE) -C ./software $(KERNEL_COMPILE_FLAGS) $@

kernel_config: FORCE
	@echo "Configuring Linux kernel..."
	$(MAKE) -C ./software $(KERNEL_COMPILE_FLAGS) $@

kernel_clean:
	$(MAKE) -C ./software $(KERNEL_COMPILE_FLAGS) $@

kernel_distclean:
	$(MAKE) -C ./software $(KERNEL_COMPILE_FLAGS) $@

#==========================================
# User application compilation
#==========================================
apps: FORCE
	@echo "Compiling user-level application: $(APP)..."
	$(MAKE) -C ./software APP="$(APP)" $(APP_COMPILE_FLAGS) $@

apps_clean: FORCE
	$(MAKE) -C ./software APP="$(APP)" $(APP_COMPILE_FLAGS) $@

apps_distclean: FORCE
	$(MAKE) -C ./software APP="$(APP)" $(APP_COMPILE_FLAGS) $@

#==========================================
# Clean for software directory
# Note that $(TOS) and $(KERN_NAME) should be specified
#==========================================
sw_clean: atf_distclean uboot_distclean kernel_distclean apps_distclean
	@echo "software directory is cleaned"

#==========================================
# Generation of Xilinx FSBL (BL2)
#==========================================
fsbl $(BL2_BIN): $(HW_DESIGN_HDF) FORCE
	@echo "Compiling FSBL..."
	$(MAKE) -C ./bootstrap COMPILER_PATH=$(ELF_GCC_PATH) HSI=$(HSI_BIN) fsbl

fsbl_clean:
	$(MAKE) -C ./bootstrap COMPILER_PATH=$(ELF_GCC_PATH) $@

fsbl_distclean:
	$(MAKE) -C ./bootstrap $@

#==========================================
# Generation of PMU Firmware (PMUFW)
#==========================================
pmufw $(PMU_FW): $(HW_DESIGN_HDF) FORCE
	@echo "Compiling PMU Firmware..."
	$(MAKE) -C ./bootstrap COMPILER_PATH=$(MB_GCC_PATH) HSI=$(HSI_BIN) pmufw

pmufw_clean:
	$(MAKE) -C ./bootstrap COMPILER_PATH=$(MB_GCC_PATH) $@ 

pmufw_distclean:
	$(MAKE) -C ./bootstrap $@

#==========================================
# Generation of BOOT.bin
#==========================================
boot_bin: $(BOOT_BIN_OBJS) 
	@echo "Generating BOOT.bin image..."
	@mkdir -p $(INSTALL_LOC)
	$(MAKE) -C ./bootstrap BOOT_GEN=$(BOOT_GEN_BIN) WITH_TOS=$(BOOTBIN_WITH_TOS) TOS=$(TOS) WITH_BIT=$(BOOTBIN_WITH_BIT) O=$(INSTALL_LOC) $@

boot_bin_clean:
	$(MAKE) -C ./bootstrap O=$(INSTALL_LOC) $@

#==========================================
# Clean for bootstrap directory
#==========================================
bootstrap_clean: FORCE
	$(MAKE) -C ./bootstrap $@

#==========================================
# Intermediate files between HW and SW design
#==========================================
ifneq ($(wildcard $(HW_DESIGN_HDF)), )
$(HW_DESIGN_HDF): FORCE 
	@echo "Hardware definition file is ready"
	@mkdir -p $(HW_PLAT_TEMP)
	@cp $(HW_DESIGN_HDF) $(HW_PLAT_TEMP)
else
$(HW_DESIGN_HDF): FORCE
	$(error No hardware definition file, please inform your hardware design team to upload it)
endif

ifneq ($(wildcard $(BITSTREAM)), )
$(BITSTREAM): FORCE
	@echo "Hardware bitstream file is ready"
else
$(BITSTREAM): FORCE
	$(error No bitstream file, please inform your hardware design team to upload it)
endif

#==========================================
# Hardware Design
#==========================================
vivado_prj: FORCE
	@echo "Executing $(HW_ACT) for Vivado project..."
	@mkdir -p $(HW_PLATFORM)
	$(MAKE) -C ./hardware VIVADO=$(VIVADO_BIN) HW_ACT=$(HW_ACT) HW_VAL="$(HW_VAL)" O=$(HW_PLATFORM) $@

bit_bin:
	@echo "Generating .bit.bin file for system.bit..."
	$(MAKE) -C ./hardware BOOT_GEN=$(BOOT_GEN_BIN) O=$(HW_PLATFORM) $@

vivado_prj_clean:
	$(MAKE) -C ./hardware $@ 

hw_gen_clean:
	$(MAKE) -C ./hardware O=$(HW_PLATFORM) $@

#==========================================
# Generated image clean
#==========================================
image_clean:
	@rm -rf $(HW_PLATFORM) $(INSTALL_LOC)

#==========================================
# Cloud environment usage
#==========================================
cloud_run:
ifneq (${USER},none)
	@mkdir -p ./run/log
	@cd ./run && bash $(FPGA_RUN) $(VIVADO_BIN) n cloud $(USER) | tee ./log/cloud_run.log
else
	$(error Please correctly set your user name for cloud environment)
endif

#==========================================
# Local environment usage
#==========================================
local_run:
ifneq (${BOARD_IP},none)
	@mkdir -p ./run/log
	@cd ./run && bash $(FPGA_RUN) $(VIVADO_BIN) n local $(BOARD_IP) | tee ./log/local_run.log
else
	$(error Please correctly set IP address of the FPGA board)
endif

help: FORCE
	@cat help


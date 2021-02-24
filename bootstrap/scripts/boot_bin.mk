# TODO: change to your own ZynqMP chip number
ZYNQMP_CHIP := xczu2eg

BOOT_GEN_FLAGS := -arch zynqmp -packagename $(ZYNQMP_CHIP) -w on

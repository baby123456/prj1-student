#!/bin/bash

mkdir -p boot_bin

BIF_FILE=boot_bin/boot_gen.bif

touch $BIF_FILE

echo "the_ROM_image:
{
	[fsbl_config] a53_x64
	[pmufw_image] ../pmufw/pmufw.elf
	[bootloader] ../fsbl/bl2.elf" > $BIF_FILE 
if [ "$1" = "y" ]; 
then
	echo -e "	[destination_device = pl] ../../hw_plat/system.bit" >> $BIF_FILE 
fi
	echo -e "	[destination_cpu = a53-0, exception_level = el-3, trustzone] ../../software/atf/bl31.elf\n	[destination_cpu = a53-0, exception_level = el-2] ../../software/uboot/u-boot.elf" >> $BIF_FILE
if [ "$2" = "y" ]; 
then
	echo -e "	[destination_cpu = a53-0, exception_level = el-1, trustzone] ../../software/"$3"_os/bl32.elf" >> $BIF_FILE
fi
echo "}" >> $BIF_FILE

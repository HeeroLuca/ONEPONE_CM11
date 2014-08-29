#!/bin/bash

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="zImage"
DTB="zImage-dtb"
DTBIMAGE="boot.img-dtb"
DEFCONFIG="luca_defconfig"

# Kernel Details
BASE_HL_VER="heeroluca"
VER="build_CM11"
HL_VER="$BASE_HL_VER$VER"

# Paths
KERNEL_DIR="${HOME}/SOURCE/cm11"
REPACK_DIR="${HOME}/AnyKernel_cm11"
PATCH_DIR="${HOME}/AnyKernel_cm11/patch"
MODULES_DIR="${HOME}/AnyKernel_cm11/patch/modules"
ZIP_MOVE="${HOME}/Release"
ZIMAGE_DIR="${HOME}/SOURCE/cm11/arch/arm/boot"

# Functions

		
function CROSSCOMPILER {

export CC=${HOME}/SOURCE/arm-eabi-4.7/bin/arm-eabi-
export CROSS_COMPILE=${HOME}/SOURCE/arm-eabi-4.7/bin/arm-eabi-

export ARCH=arm
export SUBARCH=arm

export PATH=$PATH:${HOME}/SOURCE/andorid_boot_tools_bin


}

function clean_all {
		rm -rf $MODULES_DIR/*
		rm -rf $REPACK_DIR/$KERNEL
		rm -rf $PATCH_DIR/$DTBIMAGE
		make clean
}

function make_kernel {
		make $DEFCONFIG
		make $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR
}

function make_modules {
		rm `echo $MODULES_DIR"/*"`
		find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
}

function make_dtb {
		 $REPACK_DIR/tools/dtbToolCM -2 -o $PATCH_DIR/$DTBIMAGE -s 2048 -p scripts/dtc/ arch/arm/boot/
}

function make_zip {
		cd $REPACK_DIR
		zip -r9 `echo $HL_VER`.zip * -x "README"
		mv  `echo $HL_VER`.zip $ZIP_MOVE
		cd $KERNEL_DIR
}


DATE_START=$(date +"%s")

echo -e "${green}"
echo "AUTOMATIZE ALL:                   "
echo "  I       I   I ICCCC      A      "
echo "  I       I   I I         A A     "
echo "  I       I   I I        A   A    "
echo "  I       I   I I       A A A A   "
echo "  IUUUUU  IUUUU ICCCC  A       A  "
echo "                                  "
echo

echo "---------------"
echo "Kernel Version:"
echo "---------------"

echo -e "${red}"; echo -e "${blink_red}"; echo "$HL_VER"; echo -e "${restore}";

echo -e "${green}"
echo "-----------------"
echo "Making HL Kernel:"
echo "-----------------"
echo -e "${restore}"

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		CROSSCOMPILER
		make_kernel
		make_dtb
		make_modules
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo


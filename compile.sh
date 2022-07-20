#!/bin/bash
#
# Compile script for QuicksilveR kernel
# Copyright (C) 2020-2021 Adithya R.

SECONDS=0 # builtin bash timer
ZIPNAME="/tmp/output/DoraKernel-v3.1-certus_$(date +%Y%m%d-%H%M).zip"
GCC_DIR="$HOME/tc/linaro"
DEFCONFIG="certus_defconfig"
AK3_DIR="$HOME/dora/android/AnyKernel3"
export CROSS_COMPILE="$GCC_DIR/bin/arm-linux-gnueabihf-"

if ! [ -d "$GCC_DIR" ]; then
echo "LinaroGCC not found! Cloning to $GCC_DIR..."
if ! git clone -q --depth=1 https://github.com/wulan17/linaro_arm-linux-gnueabihf-7.5.git $GCC_DIR; then
echo "Cloning failed! Aborting..."
exit 1
fi
fi

mkdir -p out
make O=out ARCH=arm $DEFCONFIG

export TELEGRAM_BOT_TOKEN=""
export TELEGRAM_CHAT_ID=""

echo -e "\nStarting compilation...\n"
make -j$(nproc --all) O=out ARCH=arm
cp out/arch/arm/boot/zImage-dtb AnyKernel3/

cd AnyKernel3
7z a -mm=Deflate -mfb=258 -mpass=15 -r $ZIPNAME *
curl -F document=@"${ZIPNAME}" -F "caption=${FILE_CAPTION}" "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendDocument?chat_id=${TELEGRAM_CHAT_ID}&parse_mode=Markdown"

echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"

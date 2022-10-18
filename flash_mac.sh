#!/bin/sh
exec >> >(tee -i log.txt) 
exec 2>&1

printf "\nThis is a recovery rom installation script for Redmi Note 10 (Mac)\n"
printf "Make sure you have python & pip specific to your mac...\n"
printf "Please allow img2simg from Privacy & Security & execute script again to work.\nOr disable the GateKeeper temperorily\n"
tools/fastboot_darwin $* --version
printf "\nFastboot OTA v20.10.31\n"
tools/simg_tools_darwin/img2simg --version
unzip *.zip

sparseSizeCheck() {
    printf "\nChecking partitions size...\n"
    inc=$(find system.img -printf "%s")
    size=$inc
    inc=$(find system_ext.img -printf "%s")
    size=$(($size+$inc))
    inc=$(find product.img -printf "%s")
    size=$(($size+$inc))
    inc=$(find vendor.img -printf "%s")
    size=$(($size+$inc))
    printf $size
    if [ $size -gt 4561305600 ]; then
        printf "\n!! Warning. ROM size exceeded 4.5 gB. You might get 'not enough space' issue !!"
    fi
    printf "\n\nConverting RAW images into sparse...\n"
    printf "Sparsing system...\n"
    tools/simg_tools_darwin/img2simg system.img temp.img
    rm system.img
    mv temp.img system.img
    printf "Sparsing system_ext...\n"
    tools/simg_tools_darwin/img2simg system_ext.img temp.img
    rm system_ext.img
    mv temp.img system_ext.img
    printf "Sparsing product...\n"
    tools/simg_tools_darwin/img2simg product.img temp.img
    rm product.img
    mv temp.img product.img
    printf "Sparsing vendor...\n"
    tools/simg_tools_darwin/img2simg vendor.img temp.img
    rm vendor.img
    mv temp.img vendor.img
}

if [ -f payload.bin ]; then
    printf "\nInstalling payload dependencies...\n"
    python -m pip install protobuf
    printf "\nExtracting images from the payload...\n"
    python tools/payload_dumper.py payload.bin
    sparseSizeCheck
elif [ -f dynamic_partitions_op_list ]; then
    printf "\nInstalling payload dependencies...\n"
    python -m pip install Brotli
    printf "\nUncompressing the data...\n"
    brotli -d system.new.dat.br system_ext.new.dat.br product.new.dat.br vendor.new.dat.br
    printf "\nExtracting all the images...\n"
    python tools/sdat2img.py system.transfer.list system.new.dat system.img
    python tools/sdat2img.py system_ext.transfer.list system_ext.new.dat system_ext.img
    python tools/sdat2img.py product.transfer.list product.new.dat product.img
    python tools/sdat2img.py vendor.transfer.list vendor.new.dat vendor.img
    rm system.new.dat system_ext.new.dat product.new.dat vendor.new.dat
    sparseSizeCheck
else
    read -p "Please have a ROM zip in the script folder..."
    exit 0
fi

if [ -f vendor.img ]; then
    printf "\nNow you can boot the device in fastboot mode & connect to PC\n"
    tools/fastboot_darwin $* snapshot-update cancel
    tools/fastboot_darwin $* flash boot tools/fastbootd_mojito.img
    printf "\nBooting to fastbootD\n"
    tools/fastboot_darwin $* reboot fastboot
    printf "\nWiping logical partitions...\n"
    tools/fastboot_darwin $* delete-logical-partition system_a
    tools/fastboot_darwin $* create-logical-partition system_a 4096
    tools/fastboot_darwin $* delete-logical-partition system_b
    tools/fastboot_darwin $* create-logical-partition system_b 4096
    tools/fastboot_darwin $* delete-logical-partition system_ext_a
    tools/fastboot_darwin $* create-logical-partition system_ext_a 4096
    tools/fastboot_darwin $* delete-logical-partition system_ext_b
    tools/fastboot_darwin $* create-logical-partition system_ext_b 4096
    tools/fastboot_darwin $* delete-logical-partition product_a
    tools/fastboot_darwin $* create-logical-partition product_a 4096
    tools/fastboot_darwin $* delete-logical-partition product_b
    tools/fastboot_darwin $* create-logical-partition product_b 4096
    tools/fastboot_darwin $* delete-logical-partition vendor_a
    tools/fastboot_darwin $* create-logical-partition vendor_a 4096
    tools/fastboot_darwin $* delete-logical-partition vendor_b
    tools/fastboot_darwin $* create-logical-partition vendor_b 4096
    printf "\nFlashing the ROM into the active slot...\n"
    tools/fastboot_darwin $* flash system system.img
    tools/fastboot_darwin $* flash system_ext system_ext.img
    tools/fastboot_darwin $* flash product product.img
    tools/fastboot_darwin $* flash vendor vendor.img
    if [ -f odm.img ]; then
        tools/fastboot_linux $* delete-logical-partition odm_a
        tools/fastboot_linux $* delete-logical-partition odm_b
        tools/fastboot_linux $* create-logical-partition odm_a 4096
        tools/fastboot_linux $* create-logical-partition odm_b 4096
        tools/fastboot_darwin $* flash odm odm.img
    fi
    if [ -f vbmeta.img ]; then
        tools/fastboot_darwin $* flash vbmeta vbmeta.img
        tools/fastboot_darwin $* flash vbmeta_system vbmeta_system.img
    fi
    printf "\nFlashing boot partitions...\n"
    tools/fastboot_darwin $* reboot bootloader
    tools/fastboot_darwin $* flash boot_a boot.img
    tools/fastboot_darwin $* flash boot_b boot.img
    tools/fastboot_darwin $* flash vendor_boot_a vendor_boot.img
    tools/fastboot_darwin $* flash vendor_boot_b vendor_boot.img
    if [ -f dtbo.img ]; then
        tools/fastboot_darwin $* flash dtbo dtbo.img
    fi
    tools/fastboot_darwin $* reboot recovery
    printf "\nRebooting to recovery in...\n"
    sleep 1
    printf "..........11...........\n"
    sleep 1
    printf " .........10..........\n"
    sleep 1
    printf "  .........9.........\n"
    sleep 1
    printf "   ........8........\n"
    sleep 1
    printf "    .......7.......\n"
    sleep 1
    printf "     ......6......\n"
    sleep 1
    printf "      .....5.....\n"
    sleep 1
    printf "       ....4....\n"
    sleep 1
    printf "        ...3...\n"
    sleep 1
    printf "         ..2..\n"
    sleep 1
    printf "          .1.\n"
    sleep 1
fi

read -p "Done. Reboot from recovery if you're updating the same rom.\nOr format if you're trying something new..."
exit 0
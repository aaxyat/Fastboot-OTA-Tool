@echo off
cd "%~dp0"

echo This is a recovery rom installation script for Redmi Note 10 (Windows)
echo Make sure you installed USB drivers related to your device...
echo.
echo Checking fastboot version...
tools\fastboot %* --version
echo Checking simg tool
tools\img2simg.exe --version
tools\7za.exe x *.zip -aos

if exist payload.bin (
	echo.
	echo Extracting images from the payload...
	tools\payload_dumper.exe payload.bin --out .
    echo.
    echo Converting RAW images into sparse...
    echo.
    echo sparsing system image...
    tools\img2simg.exe system.img temp.img
    del /f system.img
    move temp.img system.img
    echo sparsing system_ext image...
    tools\img2simg.exe system_ext.img temp.img
    del /f system_ext.img
    move temp.img system_ext.img
    echo sparsing product image...
    tools\img2simg.exe product.img temp.img
    del /f product.img
    move temp.img product.img
    echo sparsing vendor image...
    tools\img2simg.exe vendor.img temp.img
    del /f vendor.img
    move temp.img vendor.img
)
if exist dynamic_partitions_op_list (
	echo.
	echo Uncompressing the data...
	tools\bin\brotli.exe -d system.new.dat.br system_ext.new.dat.br product.new.dat.br vendor.new.dat.br
	echo Extracting all the images...
	tools\bin\sdat2img.exe system.transfer.list system.new.dat system.img
	echo Done extracting system...
	tools\bin\sdat2img.exe system_ext.transfer.list system_ext.new.dat system_ext.img
	echo Done extracting system_ext...
	tools\bin\sdat2img.exe product.transfer.list product.new.dat product.img
	echo Done extracting product...
	tools\bin\sdat2img.exe vendor.transfer.list vendor.new.dat vendor.img
	echo Done extracting vendor...
	del /f system.new.dat system_ext.new.dat product.new.dat vendor.new.dat
    echo.
    echo Converting RAW images into sparse...
    echo.
    echo sparsing system image...
    tools\img2simg.exe system.img temp.img
    del /f system.img
    move temp.img system.img
    echo sparsing system_ext image...
    tools\img2simg.exe system_ext.img temp.img
    del /f system_ext.img
    move temp.img system_ext.img
    echo sparsing product image...
    tools\img2simg.exe product.img temp.img
    del /f product.img
    move temp.img product.img
    echo sparsing vendor image...
    tools\img2simg.exe vendor.img temp.img
    del /f vendor.img
    move temp.img vendor.img
)

if exist vendor.img (
    echo.
    echo Now you can boot the device in fastboot mode and connect to PC
    tools\fastboot %* snapshot-update cancel
    tools\fastboot %* flash boot tools\fastbootd_mojito.img
    echo.
    echo Booting to fastbootD...
    tools\fastboot %* reboot fastboot
    echo.
    echo Wiping logical partitions...
    tools\fastboot %* delete-logical-partition system_a
    tools\fastboot %* create-logical-partition system_a 4096
    tools\fastboot %* delete-logical-partition system_b
    tools\fastboot %* create-logical-partition system_b 4096
    tools\fastboot %* delete-logical-partition system_ext_a
    tools\fastboot %* create-logical-partition system_ext_a 4096
    tools\fastboot %* delete-logical-partition system_ext_b
    tools\fastboot %* create-logical-partition system_ext_b 4096
    tools\fastboot %* delete-logical-partition product_a
    tools\fastboot %* create-logical-partition product_a 4096
    tools\fastboot %* delete-logical-partition product_b
    tools\fastboot %* create-logical-partition product_b 4096
    tools\fastboot %* delete-logical-partition vendor_a
    tools\fastboot %* create-logical-partition vendor_a 4096
    tools\fastboot %* delete-logical-partition vendor_b
    tools\fastboot %* create-logical-partition vendor_b 4096
    echo.
    echo Flashing the ROM into the active slot...
    tools\fastboot %* flash system system.img
    tools\fastboot %* flash system_ext system_ext.img
    tools\fastboot %* flash product product.img
    tools\fastboot %* flash vendor vendor.img
    if exist odm.img (
        tools\fastboot %* delete-logical-partition odm_a
        tools\fastboot %* delete-logical-partition odm_b
        tools\fastboot %* create-logical-partition odm_a 4096
        tools\fastboot %* create-logical-partition odm_b 4096
        tools\fastboot %* flash odm odm.img
    )
    if exist vbmeta.img (
        tools\fastboot %* flash vbmeta vbmeta.img
        tools\fastboot %* flash vbmeta_system vbmeta_system.img
    )
    echo.
    echo Flashing boot partitions...
    tools\fastboot %* reboot bootloader
    tools\fastboot %* flash boot_a boot.img
    tools\fastboot %* flash boot_b boot.img
    tools\fastboot %* flash vendor_boot_a vendor_boot.img
    tools\fastboot %* flash vendor_boot_b vendor_boot.img
    if exist dtbo.img (
        tools\fastboot %* flash dtbo dtbo.img
    )
    tools\fastboot %* reboot recovery
    echo.
    echo Rebooting to recovery in...
    timeout 1 > nul
    echo ..........11...........
    timeout 1 > nul
    echo  .........10..........
    timeout 1 > nul
    echo   .........9.........
    timeout 1 > nul
    echo    ........8........
    timeout 1 > nul
    echo     .......7.......
    timeout 1 > nul
    echo      ......6......
    timeout 1 > nul
    echo       .....5.....
    timeout 1 > nul
    echo        ....4....
    timeout 1 > nul
    echo         ...3...
    timeout 1 > nul
    echo          ..2..
    timeout 1 > nul
    echo           .1.
    timeout 1 > nul
    echo Done. Now you can format from recovery to clean start, or just simply reboot to retain your previous configuration...
)

pause

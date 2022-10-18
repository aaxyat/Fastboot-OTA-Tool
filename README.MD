# Fastboot OTA Tool

* Put the ROM zip here (in the root)
* Run the script. (bat for windows, sh for linux/mac)
* Wait till you get "waiting for any device"
* Boot device to fastboot
* Connect to PC & installation continues
* Done. Device reboots to recovery...
* Format if you wish for clean start, or don't if you want to retain previous data
* Install gapps or magisk if you need.

----------------------------------------------------

Note: For windows users, make sure you have usb drivers installed. This is done only once.
Refer to https://www.thecustomdroid.com/download-xiaomi-usb-drivers on how to install them...
Download USB Drivers from https://dl-ssl.google.com/android/repository/latest_usb_driver_windows.zip

----------------------------------------------------

Note: Make sure Linux users pre-install python & pip from their respective package managers.

For Ubuntu based distros:
sudo apt install python python-pip

For Arch based distros:
sudo pacman -S python python-pip

For Fedora:
sudo dnf install snapd python3.9 python3-pip

Also make sure you have aliased python3 as python, bcaz some distros work with python3 only
You can have an alias into ~/.bashrc or ~/.bash_aliases file:
alias python=python3

----------------------------------------------------

For Mac, make sure you allow img2simg tool from Privacy & Security to work. Or Disable Gatekeeper temperorily.

* Tool By Subham Ahmed

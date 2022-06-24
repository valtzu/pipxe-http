iPXE over HTTP boot for Raspberry Pi 4
--------------------------------------

## Requirements:
* 1 x SD card
* 1 x Raspberry Pi 4 (only tested with 8GB model) with power & ethernet


## The flow

> ***PLEASE NOTE, THIS IS FOR PROOF OF CONCEPT ONLY AND WE WILL SETUP AN UNSAFE USER ACCOUNT HERE***

1. Download [flash-eeprom-ubuntu-focal.img.xz](https://github.com/valtzu/pipxe-http/releases/latest/download/flash-eeprom-ubuntu-focal.img.xz)
2. Flash the image to the SD card, f.e. with the [official rpi-imager](https://github.com/raspberrypi/rpi-imager) that auto-handles xz decompression.
3. Put the card in the Pi
4. Power it on
5. Wait until the green led is blinking in a consistent pattern – it should only take a few seconds to reach that
6. Power off, remove SD card & power back on
7. Use your imagination or luck to figure out the IP address of the Pi
8. (you may need to wait a minute here, depending on your internet speed)
9. `ssh unsafe@x.x.x.x` where `x.x.x.x` is the IP from step 7 and password is `unsafe`



## How it works

Eeprom flasher images contain http boot configuration that point to specific asset in the latest release of this repo – f.e. `flash-eeprom-ubuntu-focal.img.xz` -> `boot-ubuntu-focal.img`. After flashing the image to rpi eeprom, the Pi will look up for a boot image that was defined in the [Makefile](Makefile#L4-L6).

The boot image contains UEFI stack and an embedded iPXE driver with [embedded iPXE boot script](embedded). At boot time it [chainloads another iPXE script](chained) from this repository – it contains the actual boot information, which kernel to use etc. Finally, it uses cloud-init to set up [an unsafe user account](cloud-init/unsafe).

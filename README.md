iPXE over HTTP boot for Raspberry Pi 4
--------------------------------------

### Quick start

#### 1. Edit autoexec.ipxe
Refer to [iPXE docs](https://ipxe.org/docs)

#### 2. Build
```
make HTTP_HOST=your-server.com HTTP_PORT=80
```

#### 3. Serve `dist/$HTTP_HOST` at `http://$HTTP_HOST:$HTTP_PORT`

Use nginx or some other HTTP (not HTTPS) server to serve the boot files.

#### 4. Flash EEPROM
Burn `dist/$HTTP_HOST/flash-eeprom.img` to an SD card.
Put the card in the Pi and boot it up.
Wait until the green LED is flashing in a consistent pattern, it should take only a few seconds to reach that.
Power off & remove SD card.

#### 5. Boot from internet
Attach ethernet cable and power up the Pi.
It will now load & boot UEFI+iPXE stack from `http://your-server.com/net_install/boot.img`.

### Tips

To avoid rebuilding the `boot.img` every time you want to make changes to the iPXE script,
it is suggested to use chainloading. This way you can just edit the file and then reboot the Pi.

For example:
``` 
#!ipxe
dhcp
chain http://your-server.com/net_install/boot.ipxe
```

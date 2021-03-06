IMAGE_NAME := ubuntu-jammy

# Translates to https://github.com/valtzu/pipxe-http/releases/latest/download/boot-$(IMAGE_NAME).img
HTTP_HOST := valtzu.kapsi.fi
HTTP_PORT := 80
HTTP_PATH := pipxe-http/$(IMAGE_NAME)

RPI_EEPROM_URL := https://raw.githubusercontent.com/raspberrypi/rpi-eeprom/master
DIST := dist
KEYS := keys
PRIVATE_KEY := $(KEYS)/private.pem
PUBLIC_KEY := $(KEYS)/public.pem
FIRMWARE := firmware/$(IMAGE_NAME)
BOOT_CONFIG := $(FIRMWARE)/boot-config.txt
EMBED := $$PWD/embedded/$(IMAGE_NAME).ipxe

$(shell mkdir -p $(DIST) $(KEYS) $(FIRMWARE) firmware tools)

all: $(DIST)/boot-$(IMAGE_NAME).img $(DIST)/boot-$(IMAGE_NAME).sig $(DIST)/flash-eeprom-$(IMAGE_NAME).img.xz

$(DIST)/boot-$(IMAGE_NAME).img:
	$(MAKE) -C pipxe IPXE_TGT=bin-arm64-efi/ipxe.efidrv EMBED=$(EMBED) boot.img
	mv pipxe/boot.img $@

$(DIST)/boot-$(IMAGE_NAME).sig: tools/rpi-eeprom-digest $(DIST)/boot-$(IMAGE_NAME).img $(PRIVATE_KEY)
	tools/rpi-eeprom-digest -i $(DIST)/boot-$(IMAGE_NAME).img -o $@ -k $(PRIVATE_KEY)

$(DIST)/flash-eeprom-$(IMAGE_NAME).img: $(FIRMWARE)/pieeprom.bin $(FIRMWARE)/vl805.bin $(FIRMWARE)/recovery.bin $(FIRMWARE)/pieeprom.sig $(FIRMWARE)/vl805.sig
	truncate -s 256M $@
	mformat -i $@ -F ::
	mcopy -i $@ $(FIRMWARE)/pieeprom.bin $(FIRMWARE)/vl805.bin firmware/recovery.bin $(FIRMWARE)/pieeprom.sig $(FIRMWARE)/vl805.sig ::

$(DIST)/flash-eeprom-$(IMAGE_NAME).img.xz: $(DIST)/flash-eeprom-$(IMAGE_NAME).img
	xz -kc0 $< > $@

$(PRIVATE_KEY):
	[[ -f $@ ]] || openssl genrsa -out $@ 2048

$(PUBLIC_KEY): $(PRIVATE_KEY)
	[[ -f $@ ]] || openssl rsa -in $< -outform PEM -pubout -out $@

tools/rpi-eeprom-config:
	[[ -f $@ ]] || wget -O $@ -q $(RPI_EEPROM_URL)/rpi-eeprom-config
	[[ -x $@ ]] || chmod u+x $@

tools/rpi-eeprom-digest:
	[[ -f $@ ]] || wget -O $@ -q $(RPI_EEPROM_URL)/rpi-eeprom-digest
	[[ -x $@ ]] || chmod u+x $@

firmware/pieeprom-2022-07-22.bin:
	[[ -f $@ ]] || wget -q -O $@ $(RPI_EEPROM_URL)/firmware/stable/pieeprom-2022-07-22.bin

firmware/recovery.bin:
	[[ -f $@ ]] || wget -q -O $@ $(RPI_EEPROM_URL)/firmware/stable/recovery.bin

firmware/vl805-000138a1.bin:
	[[ -f $@ ]] || wget -q -O $@ $(RPI_EEPROM_URL)/firmware/stable/vl805-000138a1.bin

$(FIRMWARE)/recovery.bin: firmware/recovery.bin
	ln $< $@

$(FIRMWARE)/pieeprom.bin: firmware/pieeprom-2022-07-22.bin tools/rpi-eeprom-config $(PUBLIC_KEY) $(BOOT_CONFIG) $(FIRMWARE)/boot-config.sig
	tools/rpi-eeprom-config -c $(BOOT_CONFIG) --digest $(FIRMWARE)/boot-config.sig -p $(PUBLIC_KEY) -o $@ $<

$(FIRMWARE)/vl805.bin: firmware/vl805-000138a1.bin
	cp -f $< $@

$(FIRMWARE)/boot-config.sig: tools/rpi-eeprom-digest $(BOOT_CONFIG) $(PRIVATE_KEY)
	tools/rpi-eeprom-digest -i $(BOOT_CONFIG) -o $@ -k $(PRIVATE_KEY)

$(FIRMWARE)/%.sig: $(FIRMWARE)/%.bin tools/rpi-eeprom-digest
	tools/rpi-eeprom-digest -i $< -o $@

$(BOOT_CONFIG):
	cp -f ./boot-config.txt $@
	echo "HTTP_HOST=$(HTTP_HOST)" >> $@
	echo "HTTP_PORT=$(HTTP_PORT)" >> $@
	echo "HTTP_PATH=$(HTTP_PATH)" >> $@

clean:
	rm -rf $(DIST) $(FIRMWARE) && make -C pipxe clean

.PRECIOUS: $(PRIVATE_KEY) $(PUBLIC_KEY) firmware/pieeprom-2022-07-22.bin firmware/vl805-000138a1.bin firmware/recovery.bin
.PHONY: clean

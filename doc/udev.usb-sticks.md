# Static device file links for USB sticks

I have both a Zigbee (ConBee II) and a Z-wave (Z-Wave.Me) USB stick
in use on my hassbian system. In order to have a predictable path
for the device files, I create the following udev rules in the file
`/etc/udev/rules.d/50-usb-stick.rules`:

```
# Future Technology Devices International, Ltd FT232 Serial (UART) IC
# My P1 <--> USB serial connector, to read the smart meter.
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", SYMLINK+="smartmeter"

# Sigma Designs, Inc. Aeotec Z-Stick Gen5 (ZW090) - UZB
# My Z-Wave.Me stick for Z-wave support in Home Assistant.
SUBSYSTEM=="tty", ATTRS{idVendor}=="0658", ATTRS{idProduct}=="0200", SYMLINK+="zwaveme"

# Dresden Elektronik, ConBee II
# My Zigbee stick for Zigbee support in Home Assistant.
SUBSYSTEM=="tty", ATTRS{idVendor}=="1cf1", ATTRS{idProduct}=="0030", SYMLINK+="conbee2"
```

Reloading the rules without rebooting can be done using:

```bash
$ sudo udevadm control --reload-rules && sudo udevadm trigger 
```

Checking if this worked, can be done using:

```bash
$ ls -la /dev/conbee2 /dev/zwaveme /dev/smartmeter
lrwxrwxrwx 1 root root 7 Dec 11 19:05 /dev/conbee2 -> ttyACM0
lrwxrwxrwx 1 root root 7 Dec 11 19:02 /dev/smartmeter -> ttyUSB0
lrwxrwxrwx 1 root root 7 Dec 11 19:03 /dev/zwaveme -> ttyACM1
```

## Update deCONZ to use the device link

To start deCONZ with the new device link `/dev/conbee2`, create an
override configuration for systemd using:

```bash
$ sudo systemctl edit deconz.service
```

The contents of this file:
```ini
[Service]
ExecStart=
ExecStart=/usr/bin/deCONZ -platform minimal --http-port=80 --dev=/dev/conbee2
```

After doing so, reload the systemd configuration and restart deconz using:

```
$ sudo systemctl daemon-reload
$ sudo systemctl restart deconz.service
```

Now the process should be started with the extra `--dev` argument.
This can be checked using:

```bash
$ ps -ef | grep deCONZ
```

## Update smart meter config to use the device link

Use the `/dev/smartmeter` device in the dsmr configuration, for example: 

```yaml
platform: dsmr
port: /dev/smartmeter
dsmr_version: 4
```

## Z-wave configuration

Within home-assistant Z-wave configuration, use the device `/dev/zwaveme` as the USB device.

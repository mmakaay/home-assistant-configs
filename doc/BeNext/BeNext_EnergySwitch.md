# Adding a BeNext Energy Switch plus

## Preparation of Home Assistant

Unfortunately, the BeNExt Energy Switch profile that is shipped with
OpenZwave is incorrect. There was a pull request at some point to have
the config file updated, but that one somehow didn't make it. See:
https://github.com/OpenZWave/open-zwave/pull/1501

To fix things locally, copy the openzwave-EnergySwitch.xml from this directory
to the ozw_config directory. I do this using the following shell commands:

  DST=$(find /srv/homeassistant/lib | grep BeNext/EnergySwitch.xml$)
  cp openzwave-EnergySwitch.xml $DST

I restart Home Assistant after this. Now, new Energy Switch devices will
be created using all available config options. Existing devices have to be
removed and added back to have the extra options included.

When adding new devices after a Home Assistant upgrade, beware to reinstall
the fixed xml file before doing so.

## Pair the device

Since the device is a switchable power plug, I will simply name it
"plug" from here on in this document.

First, pair the plug with the controller:

  * In Home Assistant, go to Configuration -> Z-Wave.
  * Click "ADD NODE".
  * Right after that, press and hold the button on the plug (there's a small
    button, right above the two LEDs), until you see the red LED on the
    plug light up. Let go of the button.
    When the power is switched on, lighting up the LED, it's quite unclear
    what is going on, since the LED then has a double function now.
    I recommend to first turn off the power by pressing the button,
    allowing you to see the LED blink.
  * The plug will try to pair with your Z-Wave network. The LED will
    double-blink a few times, with a little pause in between.
    When pairing is successful, the LED will light up for a second.
  * Click "HEAL NETWORK".

After these steps, the plug should be visible on the Z-Wave control
panel under "Z-Wave Node Management" -> "Nodes". The name is something
like "BeNext Energy Switch plus (Node:XXX Complete)", where
"XXX" is the Z-Wave node ID.

## Configure Entities

After pairing the plug, configure the entities for it. To do so, select
the new switch under "Nodes". Then select the entities below it one at
a time and update their settings.

I use the following settings in case I want to be able to switch the device
on and off through Home Assistant:

  * __sensor.benext_energy_switch_plus_energy: exclude
  * __sensor.benext_energy_switch_plus_previous_reading: exclude
  * __sensor.benext_energy_switch_plus_power: include with polling intensity = 1
  * __switch.benext_energy_switch_plus_switch: include with polling intensity = 1

The switch only needs to be polled when you do use the switch on the device to
turn it on and off. Without polling, the state would not synchronize with the
switch state as known in Home Assistant.

Obviously, include the energy readings with polling enabled if you want to make
use of those. I'm only interested in the power readings in my setup.

When I only want use the plug as a power meter, I use:

  * __sensor.benext_energy_switch_plus_energy: exclude
  * __sensor.benext_energy_switch_plus_previous_reading: exclude
  * __sensor.benext_energy_switch_plus_power: include with polling intensity = 1
  * __switch.benext_energy_switch_plus_switch: exclude

_Note: the previous reading entity might not yet be available. When
this happens, start using the plug and come back later to update the
configuration.

The polling intensities for the sensors are required to have the sensor values
updated. These sensors do not actively report their values. The polling
intensity setting relates to the polling_interval setting that can be setup
in Home Assistant's `configuration.yaml` file. Here's my configuration:

```yaml
zwave:
  # Run a polling cycle every minute. Z-Wave node entities can configure
  # a polling intensity, which relates to this option. A polling intensity
  # of 1 means "poll every minute", 60 means "poll every hour", etc.
  polling_interval: 60000
```

Based on this configuration, I poll the power usage and the power switch state
every minute.

## Configure settings

Under "Node Config Options" configure the following settings:

  * __2. Measure Decimals__: 1
  * __4. Startup with last known socket status__: Last state
  * __10. Light indicator__: do what pleases you, by default is use 'Off'

There are some other settings available, but I haven't seen my plugs behave
differently after changing their values.

## Give the plug and its entities a better name.

After all these steps, the plug is ready for use. I recommend highly to go
Configuration -> Devices, and click on the new BeNext Energy Switch plus
device that you have just added.

First, click the settings icon in the top right corner of the screen.
In the popup window, you can assign a good name to the sensor and link
it to an area if you like. There's no harm in not linking it to an area.

Secondly, click on the settings icon for every available entity and update
the description and the entity ID.

If you want to use the sensor as a power meter only, do yourself a favor and
disable the switch.benext_energy_switch_plus_switch entity completely. This
prevents you from accidentally switching off the power through Home Assistant.
Switching the power on the plug can now only be done using the button on
the plug itself.

As a form of good house keeping, I also disable the sensor entities that
I don't use (energy and previous_reading).

## When the power readings are only 0W

When the power readings remain 0W after switching on the power and powering
a device through the plug, go to the Z-Wave control panel page and click
on the "HEAL NETWORK" button. I have seen power readings come to life after
doing this.


# Adding a BeNext MoLite Z-wave motion sensor

## Pair the sensor

First, pair the motion sensor with the controller:

  * Remove the back panel of the motion sensor. This will expose the
    tamper switch, a small metal lid that presses a button when
    the back panel is closed.
  * In Home Assistant, go to Configuration -> Z-Wave.
  * Click "ADD NODE".
  * Right after that, press on the tamper switch, until you see the
    red LED on the sensor light up. Let go of the tamper switch.
  * The sensor will try to pair with your Z-Wave network. The LED will
    double-blink a few times, with a little pause in between.
    When pairing is successful, the LED will light up for a second.
  * Now put the back panel back on the motion sensor. It will
    single-blink a few times, after which the LED will light up for a
    second to confirm that it can communicate to the Z-Wave network.
    When the LED blinks quickly a few times at the end, then communication
    failed. Remove the back panel and add it back when this happens,
    to retry the connection.
  * Click "HEAL NETWORK".

After these steps, the sensor should be visible on the Z-Wave control
panel under "Z-Wave Node Management" -> "Nodes". The name is something
like "BeNext DHS-ZW-SNMT-01 Multi Sensor (Node:XXX Complete)", where
"XXX" is the Z-Wave node ID.

## Configure Entities

After pairing the sensor, configure the entities that must be exposed
to Home Assistant. To do so, select the new sensor under "Nodes".
Then select the entities below it one at a time and update their
settings.

_Note: Some of the above entities might not be available in the list. I regularly
have to restart the Z-Wave network to let the discovery process do its job.
I do so by restarting Home Assistant._

I use the following settings:

  * __sensor.benext_dhs_zw_snmt_01_multi_sensor_alarm_level__: exclude
  * __sensor.benext_dhs_zw_snmt_01_multi_sensor_alarm_type__: exclude
  * __sensor.benext_dhs_zw_snmt_01_multi_sensor_battery_level__: include with polling intensity = 255
  * __sensor.benext_dhs_zw_snmt_01_multi_sensor_luminance__: exclude
  * __binary_sensor.benext_dhs_zw_snmt_01_multi_sensor_sensor__: include with polling intensity = 0
  * __sensor.benext_dhs_zw_snmt_01_multi_sensor_temperature__: include with polling intensity = 30

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

Based on this configuration, I poll the temperature every half hour and the
battery level about 6 times per day (255 is the maximum allowed value for
polling_intensity).

One thing that I noticed, is that more sensors updates are logged during times when
motion is being detected. So if you see more updates than expected based on the
polling intensities, check if this was at times that motion was detected.

## Configure settings

Under "Node Config Options" configure the following settings:

  * __2. Mode timeout__: 1
  * __3. Switch off time__: 1
  * __4. Sensitivity__: 127
  * __5. The mode__: Normal operation mode

The default mode timeout and switch off time are set way too high to be useful
for integration in Home Assistant. With the configuration values from above, the
sensor reports motion while there's motion and stops reporting quickly after the
motion ends. In my option, that is the most useful setup for integrating with
Home Assistant automation rules.

Note: When briefly triggering the motion sensor with these configuration values, 
the sensor will report motion for about 10 seconds, before turning off. One
would expect a lower time, based on the documentation of the configuration
parameters, but 10 seconds is useful enough to not bother about it.

There is also a setting __6. The temperature offset__. This one does not seem to
change anythings actively. Maybe the BeNext bridge reads this value from the sensor,
in order to apply the offset to the read temperature value? I tried setting the
value to both -3 and +3. The configuration value was updated successfully in both
cases, but the reported temperature remained the same. Therefore, I just leave that
settings to zero now and take care of correcting temperature values using a
template sensor in Home Assistant.

## Configure wakeup time 

Under "Node Config Options" set the wakeup interval to 300 (seconds). This is quite low
when compared to the default of 7200 seconds (used for saving batteries), but I have
good reasons to do so:

  1. __Configuration changes can only be transferred to the sensor at times
     when the sensor is reporting itself as awake.__ When configuration changes are made
     while the sensor is sleeping, these changes are queued by the controller. As soon
     as the sensor reports as awake, the queued changes are pushed to the sensor.
     Therefore, with 7200 seconds as the wakeup time, it might take up to two hours
     for changes to propagate.

  2. When restarting Home Assistant, openzwave (the underlying Z-Wave support library)
     is restarted as well. After this restart, __the sensor will not work, until the
     sensor has reported itself awake__. The reason seems to be that the sensor only sends
     a Basic SET to its associated device(s) (in this case the Z-Wave controller)
     and not a Report. Openzwave needs to learn how to interpret the Basic SET message,
     and for this the sensor must be awake, so openzwave can retrieve the sensor's
     meta-data.

Note: I have no insights yet on how this affects the battery usage. When it turns out
that the batteries are drained too quickly using this setting, I might start using a
higher value.

__About the second point__

Below you find log lines that you will find in your OZW_Log.txt log file when the
sensor has not yet fully been activated (timestamps omitted for readability) and
motion is detected:

```
Detail, Node015,   Received: 0x01, 0x0b, 0x00, 0x04, 0x00, 0x0f, 0x03, 0x20, 0x01, 0xff, 0xc1, 0x00, 0xe3
Info, Node015, Received Basic set from node 15: level=255. Treating it as a Basic report.
```

So a Based SET is received and logged by the Z-Wave controller. However, nothing
is done with this signal. After full activation (at which point the sensor will show
up with status "Active" in the Z-Wave control panel), the log looks like this:

```
Detail, Node015,   Received: 0x01, 0x0b, 0x00, 0x04, 0x00, 0x0f, 0x03, 0x20, 0x01, 0xff, 0xc3, 0x00, 0xe1
Info, Node015, Received Basic set from node 15: level=255. Treating it as a Basic report.
Detail, Node015, Queuing (WakeUp) SensorBinaryCmd_Get (Node=15): 0x01, 0x09, 0x00, 0x13, 0x0f, 0x02, 0x30, 0x02, 0x25, 0x56, 0xa9
Detail, Node015, Refreshed Value: old value=false, new value=true, type=bool
Detail, Node015, Changes to this value are not verified
Detail, Node015, Notification: ValueChanged
```

The Basic SET is now picked up and handled in such way that the binary_sensor
entity is switched from "off" (false) to "on" (true). Additionally, an atttempt is
made to refresh the data using the SensorBinaryCmd_Get command, however that one
is not executed but queued, since the sensor is not awake at this moment.
This is not a problem for the operaiton of the sensor, although the logging seems
to indicate a problem.

For information on this behavior, see:
https://github.com/OpenZWave/open-zwave/wiki/Basic-Command-Class
An alternative could be to make use of zwave.node_event events, but
I can't get them to work currently.

## Force a configuration update of the sensor

At this point, the configuration is ready. However, this configuration might not
have been sent to the motion sensor, since the sensor needs to be awake for this
to work. 

To force a configuration update, remove the back panel and put it back. This triggers
the sensor to report itself as awake. After this, the configuration on the sensor
should be updated.

If you want to verify if this is the case, reload the Z-wave control panel page,
select the new sensor and go over the entities and sensors to see if all settings
have been applied as expected.

## Test the sensor

In Home Assistant, go to Developer Tools -> States. On that page, find the newly
added binary_sensor.benext_dhs_zw_snmt_01_multi_sensor_sensor. The second column
will show "on" when motion is detected, "off" otherwise. Check if you can make
this state switch from "off" to "on" (wave) and from "on" to "off" (do nothing).

## Sensor customization

The binary_sensor does not use the default motion sensor icon (mdi:walk).
To make the sensor look the same as other sensors in my hour, I use the
customization feature of Home Assistant.

  * Go to Configuration -> Customizations.
  * Select the new sensor from the drop down list.
  * From "Pick an attribute to override", select "icon".
  * Update the icon to "mdi:walk".

## Give the sensor and its entities a better name.

After all these steps, the sensor is ready for use. I recommend highly to go
Configuration -> Devices, and click on the new BeNext MoLite device that you
have just added.

First, click the settings icon in the top right corner of the screen.
In the popup window, you can assign a good name to the sensor and link
it to an area if you like. There's no harm in not linking it to an area.

Secondly, click on the settings icon for every available entity and update
the description and the entity ID.

You can disable entities that you do not use here, so you won't find them
in the rest of the Home Assistant interface.

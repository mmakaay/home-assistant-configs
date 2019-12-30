# Node management 

## Add a node

* Go to Configuration -> Z-Wave
* Click on "ADD NODE"
* On the device to be added to the magic button press or
  whatever is needed to initiate the removal process
* After the device has been recognized, click on "HEAL NETWORK"

## Remove a node

* Go to Configuration -> Z-Wave
* Click on "REMOVE NODE"
* On the device to be removed to the magic button press or
  whatever is needed to initiate the removal process
* If all went well, the device will now be marked as an unknown device
  in the Z-Wave control panel
* Restart Home Assistant to get this unknown device out of the list

# Node configuration

Below, I have documented the settings that I apply to my devices.

## BeNext Energy Switch Plus

* Entities
  * sensor.*_energy -> exclude
  * sensor.*_power -> include, polling intensity = 2
  * sensor.*_previous_reading -> exclude
  * switch.*_switch -> include, polling intensity = 0 
* Node Config Options
  * 2. Measure decimals = 2
  * 4. Startup with last known socket status = Last state
  * 9. Relay delay time = 1
  * 10. Light indicator = Led off

## BeNext MoLite motion sensor

* Entities
  * sensor.*_alarm_level -> exclude
  * sensor.*_alarm_type -> exclude
  * binary_sensor.*_presence -> include, polling intensity = 0
  * sensor.*_battery_level -> include, polling intensity = 0
  * sensor.*_light_level -> include, polling intensity = 0
  * sensor.*_temperature -> include, polling intensity = 0
* Node Config Options
  * Wakeup interval = 60
  * 2. Mode timeout = 1
  * 3. Switch off time = 1
  * 4. Sensitivity = 127
  * 5. The mode = normal operation mode
  * 6. The temperature offset = 0

The default wakeup interval is 7200, but that doesn't work too well.
Openzwave doesn't process the motion sensor "Basic SET" signals as
long as the sensor has not been seen in an awake state.
For information on this, see:
https://github.com/OpenZWave/open-zwave/wiki/Basic-Command-Class
An alternative could be to make use of zwave.node_event events, but
I can't get them to work currently.

## FIBARO switch 2 (single)

* Entities
  * sensor.*_alarm_level -> exclude
  * sensor.*_alarm_type -> exclude
  * sensor.*_energy -> exclude
  * sensor.*_exporting -> exclude
  * sensor.*_heat -> exclude
  * sensor.*_power -> include, polling intensity = 0
  * sensor.*_power_management -> exclude
  * sensor.*_sourcenodeid -> exclude
  * switch.* -> include when in use (there are 2 switch ports available)
* Node Config Options
  * 4. Saving state before power failure = State saved at power failure
  * 10. First channel - operating mode = Standard operation
  * 15. Second channel - operating mode = Standard operation
  * 20. Switch type = Momentary or Toggle switch, depending on hardware
  * 50. First channel - power reports = 10
  * 51. First channel - min. time between power reports = 10

## FIBARO switch 2 (dual)

* Entities
  * sensor.*_alarm_level -> exclude
  * sensor.*_alarm_type -> exclude
  * sensor.*_energy -> exclude
  * sensor.*_energy_2 -> exclude
  * sensor.*_exporting -> exclude
  * sensor.*_exporting_2 -> exclude
  * sensor.*_heat -> exclude
  * sensor.*_power -> include, polling intensity = 0
  * sensor.*_power_2 -> include, polling intensity = 0
  * sensor.*_power_management -> exclude
  * sensor.*_sourcenodeid -> exclude
  * switch.* -> include when in use (there are 2 switch ports available)
* Node Config Options
  * 4. Saving state before power failure = State saved at power failure
  * 10. First channel - operating mode = Standard operation
  * 15. Second channel - operating mode = Standard operation
  * 20. Switch type = Momentary or Toggle switch, depending on hardware
  * 50. First channel - power reports = 10
  * 51. First channel - min. time between power reports = 10
  * 54. Second channel - power reports = 10
  * 55. Second channel - min. time between power reports = 10

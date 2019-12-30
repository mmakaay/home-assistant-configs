## Configure devices connected to ConBeeII / Deconz

Configuration can be retrieved using the ConBeeII REST interface:

  * http://<ConBeeII host>/api/<bridge ID>/sensors
  * http://<ConBeeII host>/api/<bridge ID>/lights

Easiest way to make things readable is formatting the JSON output.
What I normally do is:

  wget -q -O- <URL> | json_pp | less

Setting configuration parameters can be done using a deconz Home Assistant
service call. Go to Developer Tools -> Services and use the deconz.configure
service.

Here's an example device as returned by the sensors output, a Philip HUE
outdoor motion sensor, known by the id binary_sensor.voordeur_beweging
in Home Assistant:

```json
{
   "etag" : "0df6940afdf2d3abb06223aa5fd5a6b4",
   "uniqueid" : "00:17:88:01:06:46:e9:0d-02-0406",
   "name" : "Bewegingssensor Voordeur",
   "modelid" : "SML002",
   "config" : {
      "reachable" : true,
      "sensitivitymax" : 2,
      "pending" : [],
      "battery" : 100,
      "ledindication" : false,
      "alert" : "none",
      "delay" : 0,
      "usertest" : false,
      "sensitivity" : 1,
      "on" : true
   },
   "state" : {
      "lastupdated" : "2019-12-29T19:48:19",
      "presence" : false
   },
   "type" : "ZHAPresence",
   "ep" : 2,
   "swversion" : "6.1.0.25261",
   "manufacturername" : "Philips"
}
```

To change the sensitivity to 0 for this device, the following service call
can be made:

```yaml
entity: binary_sensor.voordeur_beweging
field: /config
data:
  sensitivity: 0
```

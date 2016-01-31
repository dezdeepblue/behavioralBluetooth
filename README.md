# behavioralBluetooth
Behaviorally based redefinition of CoreBluetooth.

[Documentation](http://ladvien.github.io/jazzy/behavioralBluetooth/index.html)

```swift
// Create an object acting as an iOS central BLE device.
var myLocalBLE = LocalBluetoothLECentral()

// Tells the iOS BLE to attempt to retry connecting 3 times, with 1.5
// seconds inbetween attempts.
myLocalBLE.reconnectOnDisconnect(tries: 3, timeBetweenTries: 1.5)
// Instructs the iOS BLE to gather advertizing data on search
myLocalBLE.discoverAdvertizingDataOnSearch = false
// Tells the iOS BLE to search for peripherals for two seconds.
myLocalBLE.search(2)
```

If a remote device is discovered, let's connect,
```swift
// Create an object representing a remote peripheral of interest.
var myRemote = RemoteBluetoothLEPeripheral()

func searchTimerExpired() {
  // Look up a discovered remote device by its advertized name.
  if let deviceID = myLocal.discoveredDeviceIdByName["HMSoft"]{
      if let foundRemote = myLocal.discoveredPeripherals[deviceID] {
          myRemote = foundRemote
      }
      // Connect to the device, returning true if successful.
      let didConnect = myLocal.connectToDevice(deviceID)
  }
```



<a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/">Creative Commons Attribution-NonCommercial 4.0 International License</a>.

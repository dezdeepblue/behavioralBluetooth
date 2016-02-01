# behavioralBluetooth
Behaviorally based redefinition of CoreBluetooth.

CoreBluetooth is amazing! It's good times, for real.  Sadly, it is lacks a few features I find very useful when dealing with lesser devices such as the HM-10.  For example, a search which is based on a timer.  Of course, it's fairly easy to implement these features, but I got tired of rewriting the same helpers over-and-over.

I am pushing the design of the module to be behavior based.  I'm not sure this is the correct term, but it does describe what I am trying to accomplish.  Often, I want to switch how the iOS BLE device acts, these "behaviors" are really all I care about.  Well, that and actually getting data from the iOS to a nearby microcontroller.  Anyway, I decided to try and focus on getting these desired behaviors out the iOS device, rather than conforming to sound OO code.

It's an expirement!

The full code to get connected to a remote device would be,
```swift
import UIKit

class ViewController: UIViewController, LocalBehavioralSerialDeviceDelegate {
  var myLocal = LocalBluetoothLECentral()
  var myRemote = RemoteBluetoothLEPeripheral()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Attach the delegate to ViewController.
    myLocal.delegate = self

    // Tells the iOS BLE to attempt to retry connecting 3 times, with 1.5
    // seconds inbetween attempts.
    myLocalBLE.reconnectOnDisconnect(tries: 3, timeBetweenTries: 1.5)
    // Instructs the iOS BLE to gather advertizing data on search
    myLocalBLE.discoverAdvertizingDataOnSearch = false
    // Tells the iOS BLE to search for peripherals for two seconds.
    myLocalBLE.search(2)
  }
  
  func searchTimerExpired() {
    // Look up a discovered remote device by its advertized name.
    if let foundRemote = myLocal.getDiscoveredRemoteDeviceByName("HMSoft"){
        myRemote = foundRemote
        // Connect to the device, returning true if successful.
        let didConnect = myLocal.connectToDevice(myRemote)
    }
  }
}
```

Fun features!

Provide a list of devices sorted by RSSI,

```swift
let sortedDeviceArrayByRSSI = myLocal.getAscendingSortedArraysBasedOnRSSI()

for(var i = 0; i < sortedDeviceArrayByRSSI.nsuuids.count; i++){
    if let name = myLocal.getDeviceName(sortedDeviceArrayByRSSI.nsuuids[i]){
        print(name)
    }
    print("NSUUID: " + String(sortedDeviceArrayByRSSI.nsuuids[i].UUIDString) 
    + "\n\tRSSI: " + String(sortedDeviceArrayByRSSI.rssies[i]))
}

```

[Documentation](http://ladvien.github.io/jazzy/behavioralBluetooth/index.html)
[Waka Report](https://wakatime.com/@ladvien/projects/ysdncpuqyt?start=2016-01-25&end=2016-01-31)

<a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/">Creative Commons Attribution-NonCommercial 4.0 International License</a>.

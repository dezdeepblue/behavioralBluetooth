//
//  ViewController.swift
//  behavioralBluetooth
//
//  Created by Casey Brittain on 1/18/16.
//  Copyright © 2016 Honeysuckle Hardware. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LocalBehavioralSerialDeviceDelegate {
    var myLocal = LocalBluetoothLECentral()
    var myRemote = RemoteBluetoothLEPeripheral()

    override func viewDidLoad() {
        super.viewDidLoad()
        myLocal.delegate = self

        myLocal.reconnectOnDisconnect(tries: 3, timeBetweenTries: 1.5)
        myLocal.reconnectOnFail(tries: 3, timeBetweenTries: 2)
        myLocal.discoverAdvertizingDataOnSearch = false
        print(myLocal.getNumberOfDiscoveredDevices())
        myLocal.search(2)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.


    }
    
    func searchTimerExpired() {
        
        if let deviceID = myLocal.discoveredDeviceIdByName["HMSoft"]{
            if let foundRemote = myLocal.discoveredPeripherals[deviceID] {
                myRemote = foundRemote
            }
            let didConnect = myLocal.connectToDevice(deviceID)
            print(didConnect)
        }
        
       for name in myLocal.discoveredPeripheralNames {
            print("Found device named: " + name)
        }
        
        if let connectable = myRemote.connectable {
            print("Is connectable" + String(connectable))
        }
        print(myLocal.getNumberOfDiscoveredDevices())
    }
    
    func connectedToDevice() {

    }

    override func viewDidDisappear(animated: Bool) {
myLocal.disconnectFromPeripheral(myLocal.discoveredDeviceIdByName["HMSoft"]!)
    }
}


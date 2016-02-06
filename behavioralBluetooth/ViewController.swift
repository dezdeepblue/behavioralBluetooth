//
//  ViewController.swift
//  behavioralBluetooth
//
//  Created by Casey Brittain on 1/18/16.
//  Copyright © 2016 Honeysuckle Hardware. All rights reserved.
//

import UIKit
var myLocal = LocalBluetoothLECentral()
var myRemote = RemoteBluetoothLEPeripheral()

class ViewController: UIViewController, LocalBehavioralSerialDeviceDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myLocal.delegate = self

        myLocal.reconnectOnDisconnect(tries: 3, timeBetweenTries: 1.5)
        myLocal.reconnectOnFail(tries: 3, timeBetweenTries: 2)
        myLocal.discoverAdvertizingDataOnSearch = false
        myLocal.verboseOutput = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchTimerExpired() {
        
        // Get a list of devices sorted by RSSI.
        let sortedDeviceArrayByRSSI = myLocal.getAscendingSortedArraysBasedOnRSSI()
        // Print the list.
        for(var i = 0; i < sortedDeviceArrayByRSSI.nsuuids.count; i++){
            if let name = myLocal.getDeviceName(sortedDeviceArrayByRSSI.nsuuids[i]){
                print(name)
            }
            print("NSUUID: " + String(sortedDeviceArrayByRSSI.nsuuids[i].UUIDString) + "\n\tRSSI: " + String(sortedDeviceArrayByRSSI.rssies[i]))
        }
        
        if let foundRemote = myLocal.getDiscoveredRemoteDeviceByName("HMSoft"){
            myRemote = foundRemote
            myLocal.connectToDevice(myRemote)
        }
        
        if let connectable = myRemote.connectable {
            print("Is connectable" + String(connectable))
        }
    }
    
    func localDeviceStateChange() {
        if(myLocal.deviceState == DeviceState.idle){
            myLocal.search(8.0)
        }
    }
}


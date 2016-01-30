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
        myLocal.verboseOutput = true
        myLocal.search(6)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.


    }
    
    func searchTimerExpired() {
        print(myLocal.discoveredDeviceIdByName)
        if let deviceID = myLocal.discoveredDeviceIdByName["HMSoft"]{
            print(deviceID)
            myLocal.connectToDevice(deviceID)
        }
    }

    override func viewDidDisappear(animated: Bool) {
myLocal.disconnectFromPeriphera(myLocal.discoveredDeviceIdByName["HMSoft"]!)
    }
}


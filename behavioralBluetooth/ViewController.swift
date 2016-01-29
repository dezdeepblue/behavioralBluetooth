//
//  ViewController.swift
//  behavioralBluetooth
//
//  Created by Casey Brittain on 1/18/16.
//  Copyright © 2016 Honeysuckle Hardware. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var myLocal = LocalBluetoothLECentral()
        var myRemote = RemoteBluetoothLEPeripheral()
        myLocal.verboseOutput = true;
        myLocal.search(1)
        if let deviceIdNameDict = myLocal.discoveredDeviceIdByName {
            print(deviceIdNameDict)
            if let deviceID = deviceIdNameDict["HMSoft"]{
                print(deviceID)
                myLocal.connectToDevice(deviceID)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.


    }


}


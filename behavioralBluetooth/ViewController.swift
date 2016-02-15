//
//  ViewController.swift
//  behavioralBluetooth
//
//  Created by Casey Brittain on 1/18/16.
//  Copyright © 2016 Honeysuckle Hardware. All rights reserved.
//

import UIKit
import bluetoothBehave

var myRemote = bluetoothBehaveRemote()
var myLocal = bluetootBehaveLocal()

class ViewController: UIViewController, bluetoothBehaveLocalDelegate {

    
    @IBOutlet weak var sysLogTextBox: UITextView!
    
    @IBOutlet weak var rxedDataTextBox: UITextView!
    
    @IBOutlet weak var txDataTextBox: UITextView!
    
    @IBAction func sendButton(sender: AnyObject) {
        // Make sure we are connected to something.
        if(myLocal.getConnectionState() == DeviceState.connectionStates.connected){
            // Get the device ID.
            if let deviceID = myLocal.getConnectedDeviceIdByName("ALABTU"){
                // Write a string to the device
                myLocal.writeToDevice(deviceID, string: txDataTextBox.text)
            } else {
                print("Device was not in connected device list.")
            }
        } else {
            print("Oh my! Your iOS device isn't connected to anything.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myLocal.addDesiredService("FFE0")
        
        // Consider all characteristics, of all connected devices, to be devices
        myLocal.characteristicsAreAlwaysInteresting(true)
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        myLocal.delegate = self
        
        myLocal.allDeviceUpdatesAreInteresting(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func debug(message: String) {
        sysLogTextBox.text.appendContentsOf(message)
    }
    
    func receivedNotificationAsString(deviceID: NSUUID, string: String) {
        print("")
    }

}


//
//  ViewController.swift
//  behavioralBluetooth
//
//  Created by Casey Brittain on 1/18/16.
//  Copyright © 2016 Honeysuckle Hardware. All rights reserved.
//

import Foundation
import CoreBluetooth

/// This hopefully provides some info
public class RemoteBehavioralSerialDevice {
    
    var state = DeviceState()
    private var hardwareID: NSUUID?
    private var uuidString: String?
    private var nameString: String?
    private var connectable: Bool?
    private var txPowerLevel: Int?
    private var rssi: Int?
    
    init(){
        
    }
    
    internal func serialDataAvailable(deviceOfInterest: NSUUID, data: String){
    }
    
    internal func setBackgroundConnection(allow: Bool){
        
    }
    
    internal func getRxBufferChar(deviceOfInterest: NSUUID){
    
    }
    
    internal func clearRxBuffer(deviceOfInterest: NSUUID){
    
    }
}

public class RemoteCentral: RemoteBehavioralSerialDevice {
    
}

public class RemotePeripheral: RemoteBehavioralSerialDevice {
    
}

class RemoteBluetoothCentral: RemotePeripheral {
    
}

class RemoteBluetoothLECentral: RemotePeripheral {

}

class RemoteBluetoothPeripheral: RemotePeripheral {
    
}

class RemoteBluetoothLEPeripheral: RemotePeripheral {
    
    private var manufacturerData: String?
    private var serviceUUID: String?
    private var serviceData: String?
    private var solicitedServiceUUID: String?
    private var dataLocalName: String?
    private var services: CBService?
    private var characteristics: CBCharacteristic?
    private var descriptors: CBDescriptor?
    
    
}







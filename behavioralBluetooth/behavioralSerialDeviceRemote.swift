//
//  ViewController.swift
//  behavioralBluetooth
//
//  Created by Casey Brittain on 1/18/16.
//  Copyright © 2016 Honeysuckle Hardware. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol RemoteBehavioralSerialDeviceDelegate {
    func update()
}

/// This hopefully provides some info
public class RemoteBehavioralSerialDevice: NSObject, CBPeripheralDelegate {
    
    var state = DeviceState()
    private var hardwareID: NSUUID?
    private var uuidString: String?
    private var nameString: String?
    private var connectable: Bool?
    private var txPowerLevel: Int?
    private var rssi: Int?
    
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

    public var ID: NSUUID?
    public var dataLocalNameString: String?

    // Each device may have multiple services.
    public var services: Array<CBService>?
    public var serviceUUIDString: Array<String>?
    
    // May have several characteristics
    public var characteristics: CBCharacteristic?
    public var characteristicsString: String?
    
    // May have sever descriptors.
    public var descriptors: CBDescriptor?
    
    
    
    // Discovered device advertisement data.
    public var discoveredDevicekCBAdvDataManufacturerData: String?
    public var discoveredDevicekCBAdvDataIsConnectable: String?
    public var discoveredDevicekCBAdvDataServiceUUIDs: String?
    public var discoveredDevicekCBAdvDataTxPowerLevel: String?
    public var discoveredDevicekCBAdvDataServiceData: String?
    public var discoveredDevicekCBAdvSolicitedServiceUUID: String?
    public var discoveredDevicekCBAdvDataLocalName: String?
    

    override init(){
        
    }
    
}







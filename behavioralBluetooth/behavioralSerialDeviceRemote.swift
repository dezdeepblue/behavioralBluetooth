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
public class RemoteBehavioralSerialDevice: NSObject {
    
    public var bbState = DeviceState()
    
    internal(set) var ID: NSUUID {
        get{ return self.ID}
        set(newID){ self.ID = newID }
    }
    func idAsString()->String{
        return String(ID)
    }
    internal(set) var nameString: String {
        get{ return self.nameString}
        set(newName){ self.nameString = newName }
    }
    internal(set) var connectable: Bool {
        get{ return self.connectable}
        set(enabled){ self.connectable = enabled}
    }
    internal(set) var rssi: Int {
        get{ return self.rssi}
        set(newRssi) {self.rssi = newRssi}
    }
    
    public func serialDataAvailable(deviceOfInterest: NSUUID, data: String){
    }
    
    public func setBackgroundConnection(allow: Bool){
        
    }
    
    public func getRxBufferChar(deviceOfInterest: NSUUID){
    
    }
    
    public func clearRxBuffer(deviceOfInterest: NSUUID){
    
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

public class RemoteBluetoothLEPeripheral: RemotePeripheral, CBPeripheralDelegate {

    public var dataLocalNameString: String?

    // Peripheral
    public var bbPeripheral: CBPeripheral?
    
    // Each device may have multiple services.
    public var bbServices: Array<CBService>?
    public var serviceUUIDString: Array<String>?
    
    // May have several characteristics
    public var bbCharacteristics: Array<CBCharacteristic>?
    public var characteristicsString: String?
    
    // May have sever descriptors.
    public var bbDescriptors: Array<CBDescriptor>?

    // Discovered device advertisement data.
    public var advDataLocalName: String?
    public var advDataManufacturerData: String?
    public var advDataServiceData: String?
    public var advDataServiceUUIDs: Dictionary<CBUUID, String>?
    public var advDataOverflowServiceUUIDsKey: Array<String>?
    public var advDataTxPowerLevel: Int?
    public var advDataIsConnectable: String?
    public var advSolicitedServiceUUID: Array<String>?
    
}







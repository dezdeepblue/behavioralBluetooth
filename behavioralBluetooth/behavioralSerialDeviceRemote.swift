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
    public var ID: NSUUID?
    private var nameString: String?
    private var connectable: Bool?
    private var rssi: Int?
    
    internal func serialDataAvailable(deviceOfInterest: NSUUID, data: String){
    }
    
    internal func setBackgroundConnection(allow: Bool){
        
    }
    
    internal func getRxBufferChar(deviceOfInterest: NSUUID){
    
    }
    
    internal func clearRxBuffer(deviceOfInterest: NSUUID){
    
    }
    
    func setHardwareID(nsuuid: NSUUID){
        ID = nsuuid
    }
    
    func getHardwareID()->String{
        if let ID = ID{
            return ID.UUIDString
        }
    }
    
    func setName(name: String){
        nameString = name
    }
    
    func getName()->String{
        if let nameString = nameString {
            return nameString
        }
    }
    
    func setConnectable(enable: Bool){
        connectable = enable
    }
    
    func setRSSI(newRssi: Int){
        rssi = newRssi
    }
    
    func getRSSI()->Int{
        if let rssi = rssi {
            return rssi
        }
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
    public var discoveredDevicekCBAdvDataLocalName: String?
    public var discoveredDevicekCBAdvDataManufacturerData: String?
    public var discoveredDevicekCBAdvDataServiceData: String?
    public var discoveredDevicekCBAdvDataServiceUUIDs: Dictionary<CBUUID, String>?
    public var discoveredDevicekOverflowServiceUUIDsKey: Array<String>?
    public var discoveredDevicekCBAdvDataTxPowerLevel: Int?
    public var discoveredDevicekCBAdvDataIsConnectable: String?
    public var discoveredDevicekCBAdvSolicitedServiceUUID: Array<String>?


    override init(){
        
    }
    
}







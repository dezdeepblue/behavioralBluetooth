//
//  ViewController.swift
//  behavioralBluetooth
//
//  Created by Casey Brittain on 1/18/16.
//  Copyright © 2016 Honeysuckle Hardware. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol bluetoothBehaveRemoteDelegate {
    func update()
}

/// This hopefully provides some info
public class bluetoothBehaveRemote: NSObject, CBPeripheralDelegate {
    
    internal var deviceState = DeviceState()
    
    internal(set) var ID: NSUUID?
    func idAsString()->String{
        return String(ID)
    }
    private var nameString: String?
    internal(set) var connectable: Bool?
    internal(set) var rssi: Int?
    
    public func serialDataAvailable(deviceOfInterest: NSUUID, data: String){
    }
    
    public func setBackgroundConnection(allow: Bool){
        
    }
    
    public func getRxBufferChar(deviceOfInterest: NSUUID){
    
    }
    
    public func clearRxBuffer(deviceOfInterest: NSUUID){
    
    }
    
    public func getDeviceName()->String?{
        return nameString
    }
    
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







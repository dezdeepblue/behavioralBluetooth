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
internal class LocalSerialDevice {
    
    var connectedRemote: RemoteSerialDevice?
    var state = DeviceState()
    private var hardwareID: NSUUID?
    private var discoveredDevices: Dictionary<NSUUID, RemotePeripheral>?
    private var connectionLimit: Int?
    private var reconnectOnLostConnection: Int?
    private var retriesOnFailedConnect: Int?
    private var retriesOnDisconnect: Int?
    private var searchTimeout: Double?
    private var reconnectTimer: Double?
    private var lastConnectedDevice: NSUUID?
    private var allowConnectionInBackgroun: Bool?
    private var rxSerialBuffer: String?

    init(){
        
    }
    
    /** 
    ###Set the ID for the desired connected device. The device passed to this function will become the local device's new sought device.  If this will affect autoreconnect scenarios.
    - parameter device: The behavioralBluetooth RemoteSerialDevice desired.
    */
    func setConnectedDevice(device: RemoteSerialDevice){
        connectedRemote = device
    }
    
    /**
    ###Check to see if any serial data has arrived from device of interest.
    - parameter deviceOfInterest: The NSUUID of the device which you would like to obtain serial data.
     */
    func serialDataAvailable(deviceOfInterest: NSUUID){
        
    }
    
    /**
     ###Sets whether the connected serial device should be dismissed when the app enters the background.
     - parameter allow: Bool
     */
    func setBackgroundConnection(allow: Bool){
        
    }
    
    /**
     ###Returns the first Character (as Swift object) from the rxBuffer.  It then removes the character from the buffer.
     - parameter deviceOfInterest: NSUUID of the device which you would like to get a Character from its sent data.
     */
    func getRxBufferChar(deviceOfInterest: NSUUID)->Character{
        var returnCharacter: Character?
        
        return returnCharacter!
    }
    
    /**
     ###Limits the local device as to how many remote devices can be connected at one time.
     - parameter connectionLimit: Integer representining the device connection limit.
     */
    func setNumberOfConnectionsAllowed(connectionLimit: Int){
        
    }
    
    /**
     ###Clears all received data for a particular device from its respective local buffer.  Each remote device has its own received buffer contained within the LocalDevice object.
     - parameter deviceOfInterest: NSUUID of device buffer which should be flushed.
     */
    func clearRxBuffer(deviceOfInterest: NSUUID){
    
    }
    
    /**
    ###
    - parameter connectionLimit: Integer representining the device connection limit.
    */
    func setAutomaticReconnectOnDisconnect(flah: Bool, tries: Int, timeBetweenTries: Double){
        
    }
}

internal class LocalCentral: LocalSerialDevice {
    
}

internal class LocalPeripheral: LocalSerialDevice {
    
}

class LocalBluetoothCentral: LocalPeripheral {
    
}

class LocalBluetoothLECentral: LocalPeripheral {
    var conectedPeripherals: RemoteBluetoothLEPeripheral?
    
    public func connectToDevice(serviceOfInterest: CBService, characteristicOfInterest: CBCharacteristic){
        
    }
    
    public func connectToLastConnected(){
        
    }
    
    public func writeToDevice(deviceOfInterest: NSUUID, data: String){
        
    }
    
}

class LocalBluetoothPeripheral: LocalPeripheral {
    
}

class LocalBluetoothLEPeripheral: LocalPeripheral {
    
}




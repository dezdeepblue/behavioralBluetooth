//
//  ViewController.swift
//  behavioralBluetooth
//
//  Created by Casey Brittain on 1/18/16.
//  Copyright © 2016 Honeysuckle Hardware. All rights reserved.
//

import Foundation
import CoreBluetooth

// #MARK: Optional protocol for LocalBehavioralSerialDevice
@objc protocol LocalBehavioralSerialDeviceDelegate {
    optional func searchTimerExpired()
    optional func deviceStatusChanged(nsuuidOfDevice: NSUUID, deviceState: Int)
    optional func connectedToDevice()
}

/// This hopefully provides some info
public class LocalBehavioralSerialDevice: NSObject, RemoteBehavioralSerialDeviceDelegate {
    
    // Device lists
    private var discoveredDeviceList: Dictionary<NSUUID, RemoteBehavioralSerialDevice> = [:]
    internal var connectedRemotes: Dictionary<NSUUID, RemoteBehavioralSerialDevice> = [:]
    
    // Discovered Device handles
    private var discoveredDeviceIdByName: Dictionary<String, NSUUID> = [:]
    private var discoveredDeviceNameById: Dictionary<NSUUID, String> = [:]
    internal var discoveredDeviceIdArray: Array<NSUUID> = []
    internal var discoveredDeviceRSSIArray: Array<Int> = []
    
    // Device information
    internal var deviceState = DeviceState.unknown
    public var hardwareID: NSUUID?
    public var lastConnectedDevice: NSUUID?
    public var allowConnectionInBackground: Bool = false
    public var rxSerialBuffer: String?
    public var purposefulDisconnect = false
    
    // Behavioral
    internal var connectionsLimit: Int = 1
    internal var retriesAfterConnectionFail: Int = 1
    internal var retriesOnDisconnect: Int = 1
    internal var verboseOutput = false
    // Behavioral: Durations.
    internal var searchTimeout: Double = 1.0
    internal var reconnectTimerDuration: Double = 1.0
    public var timeBeforeAttemptingReconnectOnConnectionFail: Double = 0.5
    public var timeBeforeAttemptingReconnectOnDisconnect: Double = 0.5
    // Behavioral: Indexes
    public var retryIndexOnFail: Int = 0
    public var retryIndexOnDisconnect: Int = 0

    
    // Delegate for search updates.
    var delegate:LocalBehavioralSerialDeviceDelegate? = nil
    internal var lastConnectedPeripheralNSUUID: NSUUID?
    
    // Search properities.
    internal var searchComplete: Bool = false
    internal var searchTimeoutTimer: NSTimer = NSTimer()
    internal var reconnectTimer: NSTimer = NSTimer()

    
    override init(){
        
    }
    
    func update() {
        
    }
    
    internal func debugOutput(output: String){
        if(verboseOutput){
            print(output)
        }
    }
    
    // #MARK: public
    /** 
    ###Set the ID for the desired connected device. The device passed to this function will become the local device's new sought device.  If this will affect autoreconnect scenarios.
    - parameter device: The behavioralBluetooth RemoteSerialDevice desired.
    */
    internal func setConnectedDevice(nsuuidAsKey: NSUUID, device: RemoteBehavioralSerialDevice){
        
        connectedRemotes.updateValue(device, forKey: nsuuidAsKey)
        debugOutput("setConnectedDevice")
    }
    
    // #MARK: Get Device Handles
    /**
    ### Get the a discovered device's NSUUID using its name.
    - parameter name: A string object which should be the name of device.
    */
    public func getDeviceIdByName(name: String)->NSUUID?{
        return discoveredDeviceIdByName[name]
    }
    
    /**
     ### Return a RemoteBehavioralSerialDevice object by passing the method the device of interest's NSUUID.  This object is optional and must be unwrapped upon receiving.
     - parameter NSUUID: The NSUUID object used to identify the RemoteBehavioralSerialDevice object.
     */
    public func getDiscoveredRemoteDeviceByID(deviceNSUUID: NSUUID)->RemoteBehavioralSerialDevice?{
        return discoveredDeviceList[deviceNSUUID]
    }

    /**
     ### Return a RemoteBehavioralSerialDevice object by passing the method the device of interest's String name.  This object is optional and must be unwrapped upon receiving.
     - parameter name: The string object used to identify the RemoteBehavioralSerialDevice object.
     */
    public func getDiscoveredRemoteDeviceByName(name: String)->RemoteBehavioralSerialDevice?{
        if let deviceID = discoveredDeviceIdByName[name]{
            return discoveredDeviceList[deviceID]
        }
        return nil
    }
    
    /**
     Returns number of discovered devices
     
     ```swift
     if(bbObject.getNumberOfDiscoveredDevices() > 0){
     connectDevice()
     }
     ```
     
     */
    public func getNumberOfDiscoveredDevices()->Int{
        // #MARK: UNUSED
        debugOutput("getNumberOfDiscoveredDevices: " + String(discoveredDeviceList.count))
        return discoveredDeviceList.count
    }
    
    /**
     Provides the name of a particular discovered device as a String object.
     
     ```swift
     println(getDeviceName(myDeviceNSUUID))
     ```
     
     ```xml
     Output: myDevice
     ```
     
     */
    public func getDeviceName(deviceOfInterest: NSUUID)->String?{
        return discoveredDeviceList[deviceOfInterest]?.getDeviceName()
    }
    
    /**
     Returns the local device's [NSUUID](http://nshipster.com/uuid-udid-unique-identifier/) as a String object.
     
     ```swift
     println(getDeviceUUIDAsString(myDeviceNSUUID)
     ```
     
     ```xml
     Output: BE5BA3D0-971C-4418-9ECF-E2D1ABCB66BE
     ```
     
     */
    public func getDeviceUUIDAsString(deviceOfInterest: NSUUID)->String?{
        return hardwareID?.UUIDString
    }

    
    // #MARK: Behavioral Mutators
    /**
     ###Sets whether the connected serial device should be dismissed when the app enters the background.
     - parameter allow: Bool
     */
    public func setBackgroundConnection(enabled: Bool){
        allowConnectionInBackground = enabled
        // #MARK: UNIMP
        debugOutput("setBackgroundConnection")
    }
    
    /**
     ###Limits the local device as to how many remote devices can be connected at one time.
     - parameter connectionLimit: Integer representining the device connection limit.
     */
    public func setNumberOfConnectionsAllowed(limit: Int){
        connectionsLimit = limit
        debugOutput("setNumberOfConnectionsAllowed")
    }
    
    /**
    ###Controls automatic reconnect behavior.  If this option is set to true, the local device will attempt to automatically reconnect to all remote devices which lose connection.
    - parameter enabled: Should the reconnection be attempted.
    - parameter tries: An integer representing how many attempts should be made to reconnect before foreiting the connection.
    - parameter timeBetweenTries: Double representing how long of a delay is made before another attempt to reconnect is made.
    */
    public func reconnectOnDisconnect(tries tries: Int, timeBetweenTries: Double){
        timeBeforeAttemptingReconnectOnDisconnect = timeBetweenTries
        retriesAfterConnectionFail = tries
        debugOutput("setAutomaticReconnectOnDisconnect")
    }
    
    /**
    ###Controls automatic behavior for reconnecting to a remote device after failing to initially connect.  If this option is set to true, the local device will attempt to automatically reconnect to all remote devices which lose connection.
    - parameter enabled: Should the reconnection be attempted.
    - parameter tries: An integer representing how many attempts should be made to reconnect before foreiting the connection.
    - parameter timeBetweenTries: Double representing how long of a delay is made before another attempt to reconnect is made.
    */
    public func reconnectOnFail(tries tries: Int, timeBetweenTries: Double){
        timeBeforeAttemptingReconnectOnConnectionFail = timeBetweenTries
        retriesAfterConnectionFail = tries
        debugOutput("setRetryConnectAfterFail")
    }

    /**
     ###Attempts to connect to last connected device, without discovery.
     */
    public func connectToLastConnected(){
        debugOutput("connectToLastConnected")
        // #MARK: UNIMP
    }
    
    // #MARK: Read and Write
    
    /**
     ###Clears all received data for a particular device from its respective local buffer.  Each remote device has its own received buffer contained within the LocalDevice object.
     - parameter deviceOfInterest: NSUUID of device buffer which should be flushed.
     */
    public func clearRxBuffer(deviceOfInterest: NSUUID){
        debugOutput("clearRxBuffer")
                // #MARK: UNUSED
    }
    
    /**
     ###Returns the first Character (as Swift object) from the rxBuffer.  It then removes the character from the buffer.
     - parameter deviceOfInterest: NSUUID of the device which you would like to get a Character from its sent data.
     */
    public func getRxBufferChar(deviceOfInterest: NSUUID)->Character{
        var returnCharacter: Character?
        returnCharacter = "c"
                // #MARK: UNUSED
        debugOutput("getRxBufferChar")
        return returnCharacter!
    }
    
    /**
     ###Check to see if any serial data has arrived from device of interest.
     - parameter deviceOfInterest: The NSUUID of the device which you would like to obtain serial data.
     */
    public func serialDataAvailable(deviceOfInterest: NSUUID){
        // #MARK: UNUSED
        debugOutput("serialDataAvailable")
    }
    
    // #MARK: Discovered but not Connected Info
    
    /**
     Returns the device of interest's [Radio Signal Strength Indicator (RSSI)](https://en.wikipedia.org/wiki/Received_signal_strength_indication) as an integer.
     
     ```swift
     println(getDeviceRSSI(myDeviceNSUUID))
     ```
     
     ```xml
     Output: -56
     ```
     This option is key for NFC imitation.  For example,
     
     [![iPhone Connects Based on Proximity](https://i.ytimg.com/vi/vcrPdhN9MJw/mqdefault.jpg)](https://youtu.be/vcrPdhN9MJw)
     
     */
    public func getDeviceRSSI(deviceOfInterest: NSUUID)->Int {
                // #MARK: UNUSED
        if let rssi = discoveredDeviceList[deviceOfInterest]?.rssi {
            return rssi
        }
        else {
            return 0
        }
    }
    
    
    public func getDiscoveredDeviceByRSSIDictionary()->Dictionary<NSUUID, Int>{
        
        
        let arrayOfDevices = Array(discoveredDeviceList.keys)
        var dict: Dictionary<NSUUID, Int>?
        for key in arrayOfDevices {
            if let rssiForDevice = discoveredDeviceList[key]?.rssi {
                dict?.updateValue(rssiForDevice, forKey: key)
            }
        }
        if let dict = dict {
            return dict
        }
        return [:]
    }
    
    /**
     Returns an array of two arrays, i.e., <Array<NSUUID>, Array<NSNumber>> sorted by ascending RSSI.  Helpful for connecting to the closest device.
     
     ```swift
     let devicesSortedByRSSI = getSortedArraysBasedOnRSSI()
     connectToDevice(devicesSortedByRSSI[0])
     ```
     
     ```xml
     This should result in connecting to the nearest device. 
     (More accurately, connecting to the device with the greatest RSSI.)
     ```
     
     */
    public func getAscendingSortedArraysBasedOnRSSI()-> (nsuuids: Array<NSUUID>, rssies: Array<NSNumber>){
                // #MARK: UNUSED
        
        // Bubble-POP! :)
        var rssies = discoveredDeviceRSSIArray
        var nsuuids = discoveredDeviceIdArray
        let itemCount = discoveredDeviceIdArray.count
        
        var x = 0
        var y = 0
        //var bubblePop = true
        
        while(x < itemCount)
        {
            while(y < itemCount - 1)
            {
                if(Int(rssies[y]) < Int(rssies[y+1]))
                {
                    let temp1 = Int(rssies[y+1])
                    let temp2 = nsuuids[y+1]
                    
                    rssies[y+1] = Int(rssies[y]);
                    nsuuids[y+1] = nsuuids[y]
                    
                    rssies[y] = temp1
                    nsuuids[y] = temp2
                }
                y++
            }
            x++
        }
        return (nsuuids, rssies)
    }
    
    /**
     Returns the full Behavioral DeviceState object.
     */
    internal func getDeviceState()->DeviceState{
        // Provide the raw state of the device.
                // #MARK: UNUSED
        return DeviceState.unknown
    }
    
    @objc internal func searchTimerExpire(){
        searchTimeoutTimer.invalidate()
        searchComplete = true

        if let searchTimerExpired = delegate?.searchTimerExpired?(){
            searchTimerExpired
        }
        else {
            // THROW ERROR
        }
        
    }
    
    /**
     Returns true if already connected to the deviceOfInterest.
     */
    public func alreadyConnected(deviceNSUUID: NSUUID) -> Bool {
        // Checks if we are already connected to a device.
                // #MARK: UNUSED
        return connectedRemotes[deviceNSUUID] != nil
    }
    
    
    internal func clearDiscoveredDevices(){
        // Device descriptors for discovered devices.
        discoveredDeviceList.removeAll()
    }

    internal func clearConnectedDevices(){
        discoveredDeviceList.removeAll()
    }
    
    // #MARK: Debug info.
    public func printDiscoveredDeviceListInfo(){
        // Check to make sure we're done searching, then print the all devices info.
    if(searchComplete){
            for ID in discoveredDeviceList.keys {
                if let name = discoveredDeviceList[ID]?.getDeviceName(){
                    print("Device UUID: \(name)")
                }
                if let thisUUID = discoveredDeviceList[ID]?.idAsString() {
                    print("\t\tUUID: \(thisUUID)")
                }
                if let RSSI = discoveredDeviceList[ID]?.rssi{
                    print("\t\tRRSI: \(RSSI)")
                }
            }
            
        }
    }
    
    public func printConnectedDevices(){
        print("Number of connected devices: \(connectedRemotes.count)")
    }
}

public class LocalCentral: LocalBehavioralSerialDevice {
    
}

public class LocalPeripheral: LocalBehavioralSerialDevice {
    
}


public class LocalBluetoothCentral: LocalPeripheral {
    
}


class LocalBluetoothPeripheral: LocalPeripheral {
    
}

class LocalBluetoothLEPeripheral: LocalPeripheral {
    
}




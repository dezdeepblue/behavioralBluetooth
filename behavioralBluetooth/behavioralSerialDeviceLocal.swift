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
public class LocalBehavioralSerialDevice: NSObject {
    
    // Device information
    private var connectedRemote: RemoteBehavioralSerialDevice?
    private var state = DeviceState()
    private var hardwareID: NSUUID?
    private var discoveredDevices: Dictionary<NSUUID, RemotePeripheral>?
    private var lastConnectedDevice: NSUUID?
    private var allowConnectionInBackground: Bool?
    private var rxSerialBuffer: String?
    private var purposefulDisconnect = false
    
    // Behavioral
    private var connectionsLimit: Int?
    private var reconnectOnLostConnection: Bool?
    private var automaticConnectionRetryOnFail: Bool?
    private var retriesAfterConnectionFail: Int = 0
    private var retriesOnDisconnect: Int = 0
    private var automaticReconnectOnDisconnect: Bool = false
    // Behavioral: Durations.
    private var searchTimeout: Double?
    private var reconnectTimerDuration: Double?
    private var timeBeforeAttemptingReconnectOnConnectionFail: Double = 0.0
    private var timeBeforeAttemptingReconnectOnDisconnect: Double = 0.0
    // Behavioral: Indexes
    private var retryIndexOnFail: Int = 0
    private var retryIndexOnDisconnect: Int = 0

    
    // Delegate for search updates.
    var delegate:LocalBehavioralSerialDeviceDelegate? = nil
    
    //  CoreBluetooth Classes
    private var activeCentralManager = CBCentralManager()
    private var activePeripheralManager = CBPeripheralManager()
    private var peripheralDevice: CBPeripheral?
    private var lastConnectedPeripheralNSUUID: NSUUID?
    
    // Search properities.
    private var searchComplete: Bool = false
    private var searchTimeoutTimer: NSTimer = NSTimer()
    private var reconnectTimer: NSTimer = NSTimer()
    
    // Device descriptors for discovered devices.
    private var discoveredDeviceList: Dictionary<NSUUID, CBPeripheral> = Dictionary()
    private var discoveredDeviceListRSSI: Dictionary<NSUUID, NSNumber> = Dictionary()
    private var discoveredDeviceListAdvertisementData: Dictionary<NSUUID, [String : AnyObject]> = Dictionary()
    private var discoveredDeviceListUUIDString: Dictionary<NSUUID, String> = Dictionary()
    private var discoveredDeviceListNameString: Dictionary<NSUUID, String> = Dictionary()
    
    // Discovered device advertisement data.
    private var discoveredDevicekCBAdvDataManufacturerData: Dictionary<NSUUID, AnyObject> = Dictionary()
    private var discoveredDevicekCBAdvDataIsConnectable: Dictionary<NSUUID, AnyObject> = Dictionary()
    private var discoveredDevicekCBAdvDataServiceUUIDs: Dictionary<NSUUID, AnyObject> = Dictionary()
    private var discoveredDevicekCBAdvDataTxPowerLevel: Dictionary<NSUUID, AnyObject> = Dictionary()
    private var discoveredDevicekCBAdvDataServiceData: Dictionary<NSUUID, AnyObject> = Dictionary()
    private var discoveredDevicekCBAdvSolicitedServiceUUID: Dictionary<NSUUID, AnyObject> = Dictionary()
    private var discoveredDevicekCBAdvDataLocalName: Dictionary<NSUUID, AnyObject> = Dictionary()
    
    // Device descriptors for connected device.
    private var connectedPeripherals: Dictionary<NSUUID, CBPeripheral> = Dictionary()
    private var connectedPeripheralServices: Array<CBService> = Array()
    private var connectedPeripheralCharacteristics: Array<CBCharacteristic> = Array()
    private var connectedPeripheralCharacteristicsDescriptors: Array<CBDescriptor> = Array()
    
    override init(){
        
    }
    
    // #MARK: Internal
    /** 
    ###Set the ID for the desired connected device. The device passed to this function will become the local device's new sought device.  If this will affect autoreconnect scenarios.
    - parameter device: The behavioralBluetooth RemoteSerialDevice desired.
    */
    public func setConnectedDevice(device: RemoteBehavioralSerialDevice){
        connectedRemote = device
    }
    
    // #MARK: Behavioral Mutators
    /**
     ###Sets whether the connected serial device should be dismissed when the app enters the background.
     - parameter allow: Bool
     */
    public func setBackgroundConnection(allow: Bool){
        
    }
    
    /**
     ###Limits the local device as to how many remote devices can be connected at one time.
     - parameter connectionLimit: Integer representining the device connection limit.
     */
    public func setNumberOfConnectionsAllowed(connectionLimit: Int){
        
    }
    
    /**
    ###Controls automatica reconnect behavior.  If this option is set to true, the local device will attempt to automatically reconnect to all remote devices which lose connection.
    - parameter enabled: Should the reconnection be attempted.
    - parameter tries: An integer representing how many attempts should be made to reconnect before foreiting the connection.
    - parameter timeBetweenTries: Double representing how long of a delay is made before another attempt to reconnect is made.
    */
    public func setAutomaticReconnectOnDisconnect(enabled: Bool, tries: Int, timeBetweenTries: Double){
        
    }
    
    /**
    ###Controls automatic behavior for reconnecting to a remote device after failing to initially connect.  If this option is set to true, the local device will attempt to automatically reconnect to all remote devices which lose connection.
    - parameter enabled: Should the reconnection be attempted.
    - parameter tries: An integer representing how many attempts should be made to reconnect before foreiting the connection.
    - parameter timeBetweenTries: Double representing how long of a delay is made before another attempt to reconnect is made.
    */
    public func setRetryConnectAfterFail(enabled: Bool, tries: Int, timeBetweenTries: Double){
        
    }

    /**
     ###Attempts to last connected device, without discovery.
     */
    public func connectToLastConnected(){
        
    }
    
    // #MARK: Read and Write
    
    /**
     ###Writes data to a particular RemoteDevice
     */
    public func writeToDevice(deviceOfInterest: NSUUID, data: String){
        
    }
    
    /**
     ###Clears all received data for a particular device from its respective local buffer.  Each remote device has its own received buffer contained within the LocalDevice object.
     - parameter deviceOfInterest: NSUUID of device buffer which should be flushed.
     */
    public func clearRxBuffer(deviceOfInterest: NSUUID){
        
    }
    
    /**
     ###Returns the first Character (as Swift object) from the rxBuffer.  It then removes the character from the buffer.
     - parameter deviceOfInterest: NSUUID of the device which you would like to get a Character from its sent data.
     */
    public func getRxBufferChar(deviceOfInterest: NSUUID)->Character{
        var returnCharacter: Character?
        
        return returnCharacter!
    }
    
    /**
     ###Check to see if any serial data has arrived from device of interest.
     - parameter deviceOfInterest: The NSUUID of the device which you would like to obtain serial data.
     */
    public func serialDataAvailable(deviceOfInterest: NSUUID){
        
    }
    
    // #MARK: Discovered but not Connected Info
    /**
    Returns a Dictionary object of discovered peripheral devices.
    */
    public func getdiscoveredDeviceDictionary()->Dictionary<NSUUID, CBPeripheral>{
        return discoveredDeviceList
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
        return discoveredDeviceList.count
    }
    
    /**
    Returns the discovered devices as an array.
    */
    public func getDeviceListAsArray()->Array<NSUUID>{
        let deviceListArray =  Array(discoveredDeviceList.keys)
        return deviceListArray
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
    public func getDeviceName(deviceOfInterest: NSUUID)->String{
        let deviceName = discoveredDeviceListNameString[deviceOfInterest]
        if let deviceName = deviceName {
            return deviceName
        }
        else {
            return ""
        }
    }
    
    /**
     Returns the device's [NSUUID](http://nshipster.com/uuid-udid-unique-identifier/) as a String object.
     
     ```swift
     println(getDeviceUUIDAsString(myDeviceNSUUID)
     ```
     
     ```xml
     Output: BE5BA3D0-971C-4418-9ECF-E2D1ABCB66BE
     ```
     
    */
    public func getDeviceUUIDAsString(deviceOfInterest: NSUUID)->String{
        let deviceUUIDasString = discoveredDeviceListUUIDString[deviceOfInterest]
        if let deviceUUIDasString = deviceUUIDasString {
            return deviceUUIDasString
        }
        else {
            return ""
        }
    }
    
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
        let deviceRSSI = discoveredDeviceListRSSI[deviceOfInterest]
        if let deviceRSSI = deviceRSSI {
            return Int(deviceRSSI)
        }
        else {
            return 0
        }
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
    private func getAscendingSortedArraysBasedOnRSSI()-> (nsuuids: Array<NSUUID>, rssies: Array<NSNumber>){
        
        // Bubble-POP! :)
        var rssies = Array(discoveredDeviceListRSSI.values)
        var nsuuids = Array(discoveredDeviceListRSSI.keys)
        let countOfKeys = discoveredDeviceListRSSI.keys.count
        
        var x = 0
        var y = 0
        //var bubblePop = true
        
        while(x < countOfKeys)
        {
            while(y < countOfKeys - 1)
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
    public func getDeviceState()->DeviceState{
        // Provide the raw state of the device.
        return self.state
    }
    
    private func searchTimerExpire(){
        searchTimeoutTimer.invalidate()
        searchComplete = true
        printDiscoveredDeviceListInfo()
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
        return connectedPeripherals[deviceNSUUID] != nil
    }
    
    
    private func clearDiscoveredDevices(){
        // Device descriptors for discovered devices.
        discoveredDeviceList.removeAll()
        discoveredDeviceListRSSI.removeAll()
        discoveredDeviceListAdvertisementData.removeAll()
        discoveredDeviceListUUIDString.removeAll()
        discoveredDeviceListNameString.removeAll()
    }
    
    private func clearDiscoveredDevicesAdvertisementData(){
        connectedPeripherals.removeAll()
        connectedPeripheralServices.removeAll()
        connectedPeripheralCharacteristics.removeAll()
        connectedPeripheralCharacteristicsDescriptors.removeAll()
        
    }
    
    private func clearConnectedDevices(){
        // Clear connected devices
        connectedPeripherals.removeAll()
        connectedPeripheralServices.removeAll()
        connectedPeripheralCharacteristics.removeAll()
        connectedPeripheralCharacteristicsDescriptors.removeAll()
    }
    
    // #MARK: Debug info.
    public func printDiscoveredDeviceListInfo(){
        // Check to make sure we're done searching, then print the all devices info.
        if(searchComplete){
            for ID in self.discoveredDeviceList.keys {
                if let name = self.discoveredDeviceListNameString[ID]{
                    print("Device UUID: \(name)")
                }
                if let thisUUID = self.discoveredDeviceListUUIDString[ID] {
                    print("\t\tUUID: \(String(thisUUID))")
                }
                if let RSSI = self.discoveredDeviceListRSSI[ID] {
                    print("\t\tRRSI: \(RSSI)")
                }
            }
        }
        else{
            print("Search for devices is not yet complete")
        }
    }
    
    public func printConnectedDevices(){
        print("Number of connected devices: \(connectedPeripherals.count)")
    }
}

public class LocalCentral: LocalBehavioralSerialDevice {
    
}

public class LocalPeripheral: LocalBehavioralSerialDevice {
    
}

class LocalBluetoothCentral: LocalPeripheral {
    
}

/// ##The Local Bluetooth LE Object
class LocalBluetoothLECentral: LocalPeripheral, CBCentralManagerDelegate, CBPeripheralDelegate {
    var conectedPeripherals: RemoteBluetoothLEPeripheral?
    

    // #MARK: Central Manager init.
    /**
    ###Updates the the state of the Local Bluetooth LE device.
    - parameter
    */
    internal func centralManagerDidUpdateState(central: CBCentralManager) {
        
        // Make sure the BLE device is on.
        switch activeCentralManager.state {
        case CBCentralManagerState.Unknown:
            print("Unknown")
            //self.state = central.state.rawValue
            break
        case CBCentralManagerState.Resetting:
            print("Resetting")
            break
        case CBCentralManagerState.Unsupported:
            print("Unsupported")
            break
        case CBCentralManagerState.Unauthorized:
            print("Unauthorized")
            break
        case CBCentralManagerState.PoweredOff:
            print("PoweredOff")
            break
        case CBCentralManagerState.PoweredOn:
            // Scan for peripherals if BLE is turned on
            central.scanForPeripheralsWithServices(nil, options: nil)
            print("Searching for BLE Devices")
            break
        }
    }
    
    // #MARK: Connect to device
    /**
    Requests the Local Device connect to a Bluetooth LE Remote device of interest.  The call will assure a connection to the particular device doesn't exist.  If the `connectionsLimit` has not been reached.
    */
    public func connectToDevice(deviceNSUUID: NSUUID) -> Bool {
        
        // Remember NSUUID
        lastConnectedPeripheralNSUUID = deviceNSUUID
        
        // Check if if we have discovered anything, if so, make sure we are not already connected.
        if(discoveredDeviceList.isEmpty || alreadyConnected(deviceNSUUID)){
            print("Already connected, silly")
            return false
        }
        else {
            if(connectedPeripherals.count < connectionsLimit){
                if let deviceToConnect = discoveredDeviceList[deviceNSUUID] {
                    activeCentralManager.connectPeripheral(deviceToConnect, options: nil)
                }
                else {
                    return false
                }
            }
            else
            {
                print("Too many connections")
            }
            if(automaticReconnectOnDisconnect){
                retryIndexOnDisconnect = 0
            }
        }
        return true
    }

    
    // #MARK: Search for devices
    /**
    Requests the Local Device connect to a Bluetooth LE Remote device of interest.  The call will assure a connection to the particular device doesn't exist.  If the `connectionsLimit` has not been reached.
    */
    private func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        // Let's get all the information about the discovered devices.
        discoveredDeviceList.updateValue(peripheral, forKey: peripheral.identifier)
        discoveredDeviceListRSSI.updateValue(RSSI, forKey: peripheral.identifier)
        discoveredDeviceListAdvertisementData.updateValue(advertisementData, forKey: peripheral.identifier)
        discoveredDeviceListUUIDString.updateValue(peripheral.identifier.UUIDString, forKey: peripheral.identifier)
        
        // Advertising data.
        let AdvertisementDataIsConnectable = advertisementData[CBAdvertisementDataIsConnectable]
        if let AdvertisementDataIsConnectable = AdvertisementDataIsConnectable {
            discoveredDevicekCBAdvDataIsConnectable.updateValue(AdvertisementDataIsConnectable, forKey: peripheral.identifier)
        }
        else
        {
            print("Nil found unwrapping AdvertisementDataIsConnectable")
        }
        
        
        let AdvertisementDataManufacturerDataKey = advertisementData[CBAdvertisementDataManufacturerDataKey]
        if let AdvertisementDataManufacturerDataKey = AdvertisementDataManufacturerDataKey{
            discoveredDevicekCBAdvDataManufacturerData.updateValue(AdvertisementDataManufacturerDataKey, forKey: peripheral.identifier)
        }
        else
        {
            print("Nil found unwrapping AdvertisementDataManufacturerDataKey")
        }
        
        
        let AdvertisementDataServiceDataKey = advertisementData[CBAdvertisementDataServiceDataKey] as? Dictionary<CBUUID, NSData>
        if let AdvertisementDataServiceDataKey = AdvertisementDataServiceDataKey {
            discoveredDevicekCBAdvDataServiceData.updateValue(AdvertisementDataServiceDataKey, forKey: peripheral.identifier)
        }
        else
        {
            print("Nil found unwrapping AdvertisementDataServiceDataKey")
        }
        
        
        let AdvertisementDataLocalNameKey = advertisementData[CBAdvertisementDataLocalNameKey]
        if let AdvertisementDataLocalNameKey = AdvertisementDataLocalNameKey {
            discoveredDevicekCBAdvDataLocalName.updateValue(AdvertisementDataLocalNameKey, forKey: peripheral.identifier)
        }
        else
        {
            print("Nil found unwrapping AdvertisementDataLocalNameKey")
        }
        
        let AdvertisementDataTxPowerLevelKey = advertisementData[CBAdvertisementDataTxPowerLevelKey]
        if let AdvertisementDataTxPowerLevelKey = AdvertisementDataTxPowerLevelKey{
            discoveredDevicekCBAdvDataTxPowerLevel.updateValue(AdvertisementDataTxPowerLevelKey, forKey: peripheral.identifier)
        }
        else
        {
            print("Nil found unwrapping AdvertisementDataTxPowerLevelKey")
        }
        
        let AdvertisementDataServiceUUIDsKey = advertisementData[CBAdvertisementDataServiceUUIDsKey]
        if let AdvertisementDataServiceUUIDsKey = AdvertisementDataServiceUUIDsKey {
            discoveredDevicekCBAdvDataServiceUUIDs.updateValue(AdvertisementDataServiceUUIDsKey, forKey: peripheral.identifier)
        } else
        {
            print("Nil found unwrapping AdvertisementDataServiceUUIDsKey")
        }
        
        let AdvertisementDataSolicitedServiceUUIDsKey = advertisementData[CBAdvertisementDataSolicitedServiceUUIDsKey]
        if let AdvertisementDataSolicitedServiceUUIDsKey = AdvertisementDataSolicitedServiceUUIDsKey {
            discoveredDevicekCBAdvSolicitedServiceUUID.updateValue(AdvertisementDataSolicitedServiceUUIDsKey, forKey: peripheral.identifier)
        } else {
            print("Nil found unwrapping AdvertisementDataSolicitedServiceUUIDsKey")
        }
        // Clear any connections.  (Strangely, if a search is initiated, all devices are disconnected without
        // didDisconnectPeripheral() being called.
        connectedPeripheralServices.removeAll()
        connectedPeripheralCharacteristics.removeAll()
        connectedPeripheralCharacteristicsDescriptors.removeAll()
        
        //        print(CBAdvertisementDataLocalNameKey)
        
        //        print(advertisementData)
        
        if let name = peripheral.name {
            discoveredDeviceListNameString.updateValue(name, forKey: peripheral.identifier)
        }
    }
    
    private func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        // Add peripheral to connectedPeripheral dictionary.
        connectedPeripherals.updateValue(peripheral, forKey: peripheral.identifier)
        
        peripheralDevice = peripheral
        peripheralDevice?.delegate = self
        
        // Look for set services
        
        // If not, do below.
        
        if let peripheralDevice = peripheralDevice {
            peripheralDevice.discoverServices(nil)
        }
        
        if let connectedToDevice = delegate?.connectedToDevice?(){
            connectedToDevice
        }
        else {
            
            // Handle if no delegate is setup.
            
        }
    }
    
    private func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        // Look for set characteristics.
        
        // If not, do below.
        
        if let peripheralDevice = peripheralDevice {
            if let serviceArray = peripheralDevice.services {
                for service in serviceArray {
                    connectedPeripheralServices.append(service)
                    peripheralDevice.discoverCharacteristics(nil, forService: service)
                }
            }
        }
        
        
    }
    
    private func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        // Look for set characteristics descriptors.
        
        // If not, do below.
        
        if let peripheralDevice = peripheralDevice {
            if let characteristicsArray = service.characteristics {
                for characteristic in characteristicsArray {
                    connectedPeripheralCharacteristics.append(characteristic)
                    peripheralDevice.discoverDescriptorsForCharacteristic(characteristic)
                }
            }
        }
    }
    
    private func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let  descriptorsArray = characteristic.descriptors {
            for descriptors in descriptorsArray {
                connectedPeripheralCharacteristicsDescriptors.append(descriptors)
            }
        }
        // End of the line.
    }
    
    private func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        // If we fail to connect, don't remember this device.
        
        if(automaticConnectionRetryOnFail == true && retryIndexOnFail < retriesAfterConnectionFail){
            reconnectTimer = NSTimer.scheduledTimerWithTimeInterval(timeBeforeAttemptingReconnectOnConnectionFail, target: self, selector: Selector("reconnectTimerExpired"), userInfo: nil, repeats: false)
        }
        else {
            lastConnectedPeripheralNSUUID = nil
        }
    }
    
    public func search(timeoutSecs: NSTimeInterval){
        searchComplete = false
        clearDiscoveredDevices()
        // Strange.  If a search for peripherals is initiated it cancels all connections
        // without firing didDisconnectPeripheral.  This compensates.
        clearConnectedDevices()
        activeCentralManager = CBCentralManager(delegate: self, queue: nil)
        searchTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(timeoutSecs, target: self, selector: Selector("searchTimerExpire"), userInfo: nil, repeats: false)
    }
    
    public func connectToDevice(serviceOfInterest: CBService, characteristicOfInterest: CBCharacteristic){
        
    }
    
    // #MARK: Connection Lost.
    private func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        // If connection is lost, remove it from the connected device dictionary.
        connectedPeripherals.removeValueForKey(peripheral.identifier)
        print("Lost connection to: \(peripheral.identifier)")
        
        if(automaticReconnectOnDisconnect && purposefulDisconnect == false){
            activePeripheralManager.state
            reconnectTimer = NSTimer.scheduledTimerWithTimeInterval(timeBeforeAttemptingReconnectOnDisconnect, target: self, selector: Selector("reconnectTimerExpired"), userInfo: nil, repeats: false)
        }
        else {
            //if let deviceStatusChanged = delegate?.deviceStatusChanged?(peripheral.identifier, deviceState: self.state){
                purposefulDisconnect = false
                //deviceStatusChanged
            //}
        }
        
        
    }
    
    public func disconnectFromPeriphera(deviceOfInterest: NSUUID)->Bool {
        let deviceToDisconnect = connectedPeripherals[deviceOfInterest]
        if let deviceToDisconnect = deviceToDisconnect {
            activeCentralManager.cancelPeripheralConnection(deviceToDisconnect)
            purposefulDisconnect = true
            return true
        }
        else
        {
            // ERROR: Device does not exist.
            return false
        }
    }
    
    /**
     ```swift
     println(getDeviceRSSI(myDeviceNSUUID))
     ```
     
     ```xml
     Output: -56
     ```
     */
    public func getAdvDeviceConnectable(deviceOfInterest: NSUUID)->Bool{
        if let discoveredDevicekCBAdvDataIsConnectable = discoveredDevicekCBAdvDataIsConnectable[deviceOfInterest] {
            let connectableFlag = discoveredDevicekCBAdvDataIsConnectable as? Bool
            if let connectableFlag = connectableFlag {
                return connectableFlag
            }
        }
        return false
    }
    
    public func getAdvDeviceName(deviceOfInterest: NSUUID)->String{
        if let discoveredDevicekCBAdvDataLocalName = discoveredDevicekCBAdvDataLocalName[deviceOfInterest] {
            let nameAsString = discoveredDevicekCBAdvDataLocalName as? String
            if let nameAsString = nameAsString {
                return nameAsString
            }
        }
        return ""
    }
    
    
    public func getAdvDeviceManufactureData(deviceOfInterest: NSUUID)->String{
        if let discoveredDevicekCBAdvDataManufacturerData = discoveredDevicekCBAdvDataManufacturerData[deviceOfInterest] {
            let data = discoveredDevicekCBAdvDataManufacturerData as? NSData
            if let data = data {
                let dataString = NSString(data: data, encoding: NSUTF16StringEncoding) as? String
                if let dataString = dataString {
                    return dataString
                }
            }
        }
        return ""
    }
    
    public func getAdvDeviceServiceData(deviceOfInterest: NSUUID) -> Array<String>{
        if let discoveredDevicekCBAdvDataServiceData = discoveredDevicekCBAdvDataServiceData[deviceOfInterest] {
            let dictionaryCast = discoveredDevicekCBAdvDataServiceData as? Dictionary<CBUUID, NSData>
            var cbuuidAsStringArray: Array<String> = []
            if let dictionaryCast = dictionaryCast {
                for CBUUID in dictionaryCast.values {
                    let cbuuidString = NSString(data: CBUUID, encoding: NSUTF16StringEncoding)
                    if let cbuuidString = cbuuidString {
                        cbuuidAsStringArray.append(cbuuidString as String)
                    }
                }
                return cbuuidAsStringArray
            }
        }
        return [""]
    }
    
    public func getAdvDeviceServiceUUIDasNSArray(deviceOfInterest: NSUUID)->NSArray{
        if let discoveredDevicekCBAdvDataServiceUUIDs = discoveredDevicekCBAdvDataServiceUUIDs[deviceOfInterest] {
            let discoveredDevicekCBAdvDataServiceUUIDStrings = discoveredDevicekCBAdvDataServiceUUIDs as? NSArray
            if let discoveredDevicekCBAdvDataServiceUUIDStrings = discoveredDevicekCBAdvDataServiceUUIDStrings
            {
                if(discoveredDevicekCBAdvDataServiceUUIDs.count > 0){
                    return discoveredDevicekCBAdvDataServiceUUIDStrings
                }
                else {
                    return []
                }
            }
        }
        return []
    }
    
    
    
    public func getAdvTxPowerLevel(deviceOfInterest: NSUUID)->Int{
        if let discoveredDevicekCBAdvDataTxPowerLevel = discoveredDevicekCBAdvDataTxPowerLevel[deviceOfInterest] {
            let txPowerLevelInt = discoveredDevicekCBAdvDataTxPowerLevel as? Int
            if let txPowerLevelInt = txPowerLevelInt
            {
                return txPowerLevelInt
            }
        }
        return 0
    }
    
    public func getAdvSolicitedUUID(deviceOfInterest: NSUUID)->NSArray?{
        if let discoveredDevicekCBAdvSolicitedServiceUUID = discoveredDevicekCBAdvSolicitedServiceUUID[deviceOfInterest] {
            let solicitedUUID = discoveredDevicekCBAdvSolicitedServiceUUID as? NSArray
            if let solicitedUUID = solicitedUUID
            {
                if(solicitedUUID.count > 0){
                    return solicitedUUID
                }
                else {
                    return []
                }
            }
        }
        return []
    }

    private func reconnectTimerExpired(){
        if let lastConnectedPeripheralNSUUID = lastConnectedPeripheralNSUUID {
            connectToDevice(lastConnectedPeripheralNSUUID)
        }
    }
    
}

class LocalBluetoothPeripheral: LocalPeripheral {
    
}

class LocalBluetoothLEPeripheral: LocalPeripheral {
    
}




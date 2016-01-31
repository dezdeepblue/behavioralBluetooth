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
    public var discoveredDeviceList: Dictionary<NSUUID, RemoteBehavioralSerialDevice> = [:]
    public var discoveredDeviceIdByName: Dictionary<String, NSUUID> = [:]
    
    // Device information
    private var connectedRemotes: Dictionary<NSUUID, RemoteBehavioralSerialDevice> = [:]
    public var state = DeviceState()
    public var hardwareID: NSUUID?
    public var lastConnectedDevice: NSUUID?
    public var allowConnectionInBackground: Bool = false
    public var rxSerialBuffer: String?
    public var purposefulDisconnect = false
    
    // Behavioral
    private var connectionsLimit: Int = 1
    private var retriesAfterConnectionFail: Int = 1
    private var retriesOnDisconnect: Int = 1
    private var verboseOutput = false
    // Behavioral: Durations.
    private var searchTimeout: Double = 1.0
    private var reconnectTimerDuration: Double = 1.0
    public var timeBeforeAttemptingReconnectOnConnectionFail: Double = 0.5
    public var timeBeforeAttemptingReconnectOnDisconnect: Double = 0.5
    // Behavioral: Indexes
    public var retryIndexOnFail: Int = 0
    public var retryIndexOnDisconnect: Int = 0

    
    // Delegate for search updates.
    var delegate:LocalBehavioralSerialDeviceDelegate? = nil
    
    //  CoreBluetooth Classes
    private var activeCentralManager = CBCentralManager()
    private var activePeripheralManager = CBPeripheralManager()
    private var lastConnectedPeripheralNSUUID: NSUUID?
    
    // Search properities.
    private var searchComplete: Bool = false
    private var searchTimeoutTimer: NSTimer = NSTimer()
    private var reconnectTimer: NSTimer = NSTimer()

    
    override init(){
        
    }
    
    func update() {
        
    }
    
    func debugOutput(output: String){
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
    
    public func getDeviceIdByName(name: String)->NSUUID{
        if let deviceID = discoveredDeviceIdByName[name]{
             return deviceID
        }
        return NSUUID()
    }
    
    // #MARK: Behavioral Mutators
    /**
     ###Sets whether the connected serial device should be dismissed when the app enters the background.
     - parameter allow: Bool
     */
    public func setBackgroundConnection(enabled: Bool){
        allowConnectionInBackground = enabled
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
    ###Controls automatica reconnect behavior.  If this option is set to true, the local device will attempt to automatically reconnect to all remote devices which lose connection.
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
     ###Attempts to last connected device, without discovery.
     */
    public func connectToLastConnected(){
        debugOutput("connectToLastConnected")
        // #MARK: UNUSED
    }
    
    // #MARK: Read and Write
    
    /**
     ###Writes data to a particular RemoteDevice
     */
    public func writeToDevice(deviceOfInterest: NSUUID, data: String){
        debugOutput("writeToDevice")
                // #MARK: UNUSED
    }
    
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
    Returns a Dictionary object of discovered peripheral devices.
    */
    public func bbDeviceByIdDictionary()->Dictionary<NSUUID, RemoteBehavioralSerialDevice>{
                // #MARK: UNUSED
        debugOutput("getdiscoveredDeviceDictionary has #" + String(discoveredDeviceList.count) + " items")
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
                // #MARK: UNUSED
        debugOutput("getNumberOfDiscoveredDevices: " + String(discoveredDeviceList.count))
        return discoveredDeviceList.count
    }
    
    /**
    Returns the discovered devices as an array.
    */
    public func bbDeviceByIdArray()->Array<NSUUID>{
                // #MARK: UNUSED
        let deviceListArray = Array(discoveredDeviceList.keys)
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
        if let deviceName = discoveredDeviceList[deviceOfInterest]?.nameString {
                    // #MARK: UNUSED
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
        if let hardwareID = discoveredDeviceList[deviceOfInterest]?.idAsString(){
                    // #MARK: UNUSED
            return hardwareID
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
                // #MARK: UNUSED
        if let rssi = discoveredDeviceList[deviceOfInterest]?.rssi {
            return rssi
        }
        else {
            return 0
        }
    }
    
    
    private func discoveredDeviceRSSIDictionary()->Dictionary<NSUUID, Int>{
                // #MARK: UNUSED
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
    private func getAscendingSortedArraysBasedOnRSSI()-> (nsuuids: Array<NSUUID>, rssies: Array<NSNumber>){
                // #MARK: UNUSED
        let discoveredDeviceListRSSI: Dictionary<NSUUID, Int> = discoveredDeviceRSSIDictionary()
        
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
                // #MARK: UNUSED
        return self.state
    }
    
    @objc private func searchTimerExpire(){
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
    
    
    private func clearDiscoveredDevices(){
        // Device descriptors for discovered devices.
        discoveredDeviceList.removeAll()
    }

    private func clearConnectedDevices(){
        discoveredDeviceList.removeAll()
    }
    
    // #MARK: Debug info.
    public func printDiscoveredDeviceListInfo(){
        // Check to make sure we're done searching, then print the all devices info.
    if(searchComplete){
            for ID in discoveredDeviceList.keys {
                if let name = discoveredDeviceList[ID]?.nameString{
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

// #MARK: Bluetooth Low Energy
/// ##The Local Bluetooth LE Object
public class LocalBluetoothLECentral: LocalPeripheral, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var connectedPeripherals: Dictionary<NSUUID, RemoteBluetoothLEPeripheral> = [:]
    public var discoveredPeripherals: Dictionary<NSUUID, RemoteBluetoothLEPeripheral> = [:]
    public var discoveredPeripheralNames: Array<String> = [""]
    
    // Behavioral: Variables.
    var discoverAdvertizingDataOnSearch: Bool = false;
    
    // Behavioral: Methods.
    func obtainAdvertizingDataOnConnect(enable: Bool){
        discoverAdvertizingDataOnSearch = enable
    }
    
    // #MARK: Remote Device update delegate method
    /**
    Delegate method called from Remote objects.
    - parameter more on this later: more on this later.
    */
    override func update() {
        //
    }
    
    
    // #MARK: Central Manager init.
    /**
    ###Updates the the state of the Local Bluetooth LE device.
    - parameter
    */
    public func centralManagerDidUpdateState(central: CBCentralManager) {
        
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
    func connectToDevice(deviceNSUUID: NSUUID) -> Bool {
        
        // Remember NSUUID
        lastConnectedPeripheralNSUUID = deviceNSUUID
        
        // Check if if we have discovered anything, if so, make sure we are not already connected.
        if(discoveredDeviceList.isEmpty || alreadyConnected(deviceNSUUID)){
            print("Already connected, silly")
            return false
        }
        else {
            if(connectedRemotes.count < connectionsLimit){
                if let peripheralToConnect = discoveredPeripherals[deviceNSUUID]?.bbPeripheral{
                   
                    if let connectedRemoteSerialDevice = discoveredDeviceList[deviceNSUUID] {
                        setConnectedDevice(deviceNSUUID, device: connectedRemoteSerialDevice)
                    }
                    
                    activeCentralManager.connectPeripheral(peripheralToConnect, options: nil)
                }
                else {
                    return false
                }
            }
            retryIndexOnDisconnect = 0
        }
        return true
    }
    
    
    @objc public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        // Add peripheral to connectedPeripheral dictionary.
        // What happens when it connects to a device without discovering it? (reconnect)?
        if let discoveredDeviceList = discoveredDeviceList[peripheral.identifier] {
            connectedRemotes.updateValue(discoveredDeviceList, forKey: peripheral.identifier)
            debugOutput("didConnectToPeripheral: " + peripheral.identifier.UUIDString )
        }
 
        // Transfer device object from discovered device dictionary to our connected
        // device dictionary.
        if let desiredDevice = discoveredPeripherals[peripheral.identifier] {
            connectedPeripherals.updateValue(desiredDevice, forKey: peripheral.identifier)
        }
        
        // 
        if var desiredDeviceInConnectedDevices = connectedPeripherals[peripheral.identifier]?.bbPeripheral {
            desiredDeviceInConnectedDevices = peripheral
            desiredDeviceInConnectedDevices.delegate = self
            
            // #MARK: ADD
            // LIMIT SEARCH BY ARGUMENT
            
            desiredDeviceInConnectedDevices.discoverServices(nil)
        }
        
        if let connectedToDevice = delegate?.connectedToDevice?(){
            connectedToDevice
            debugOutput("Invoked Delegate: connectedToDevice")
        }
        else {
            // #MARK: ADD
            // Handle if no delegate is setup.
        }
    }
    

    
    @objc public func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        // If we fail to connect, don't remember this device.
        
        if(retryIndexOnFail < retriesAfterConnectionFail){
            reconnectTimer = NSTimer.scheduledTimerWithTimeInterval(timeBeforeAttemptingReconnectOnConnectionFail, target: self, selector: Selector("reconnectTimerExpired"), userInfo: nil, repeats: false)

            debugOutput("didFailToConnectPeripheral: Retry# " + String(retryIndexOnFail) + " of " + String(retriesAfterConnectionFail) + " with " + String(timeBeforeAttemptingReconnectOnConnectionFail) + "secs inbetween attempt")
            
        }
        else {
            debugOutput("didFailToConnectPeripheral: Unable to connect")
            lastConnectedPeripheralNSUUID = nil
        }
    }
    
    public func search(timeoutSecs: NSTimeInterval){
        searchComplete = false
        //clearDiscoveredDevices()
        // Strange.  If a search for peripherals is initiated it cancels all connections
        // without firing didDisconnectPeripheral.  This compensates.
        clearConnectedDevices()
        activeCentralManager = CBCentralManager(delegate: self, queue: nil)
        searchTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(timeoutSecs, target: self, selector: Selector("searchTimerExpire"), userInfo: nil, repeats: false)
        debugOutput("Started search with "+String(timeoutSecs) + " sec timeout")
    }
    
    public func connectToDevice(serviceOfInterest: CBService, characteristicOfInterest: CBCharacteristic){
    }
    
    // #MARK: Connection Lost.
    @objc public func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {

        // If connection is lost, remove it from the connected device dictionary.
        connectedRemotes.removeValueForKey(peripheral.identifier)
        print("Lost connection to: \(peripheral.identifier.UUIDString)")
        
        if(purposefulDisconnect == false){
            if(retryIndexOnDisconnect < retriesOnDisconnect){

                activePeripheralManager.state
                reconnectTimer = NSTimer.scheduledTimerWithTimeInterval(timeBeforeAttemptingReconnectOnDisconnect, target: self, selector: Selector("reconnectTimerExpired"), userInfo: nil, repeats: false)
                debugOutput("didDisconnectPeripheral, purpose = " + String(purposefulDisconnect) + "\n\tRetry# " + String(retryIndexOnDisconnect) + " of " + String(retriesOnDisconnect) + " with " + String(timeBeforeAttemptingReconnectOnDisconnect) + "secs inbetween attempt")
            }
            else {
                    debugOutput("didDisconnectPeripheral: Unable to Connect")
                }
        }
        else {
            //if let deviceStatusChanged = delegate?.deviceStatusChanged?(peripheral.identifier, deviceState: self.state){
                purposefulDisconnect = false
                //deviceStatusChanged
            //}
            
            debugOutput("Disconneted with purpose")
        }
    }
    
    // #MARK: CoreBluetooth Central Manager
    public func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        debugOutput("didDiscoverPeripheral "+String(peripheral.identifier.UUIDString))
        // 1. Creates RemotebBluetoothLE object and populates its data.
        // 2. Add the remote object to our Remote object Dictioanry.
        
        let thisRemoteDevice = RemoteBluetoothLEPeripheral()
        
        // Populate the object.
        thisRemoteDevice.ID = peripheral.identifier
        thisRemoteDevice.bbPeripheral = peripheral

        // Set its name.
        if let name = peripheral.name {
            thisRemoteDevice.nameString = name
            discoveredPeripheralNames.append(name)
        }
        // Set RSSI
        thisRemoteDevice.rssi = Int(RSSI)
        
        // Advertising data.
        if(discoverAdvertizingDataOnSearch){
            
            debugOutput("didDiscoverPeripheral found Adv. Data.")
            // Get DataLocalNameKey
            if let advertisementDataLocalNameKey = advertisementData[CBAdvertisementDataLocalNameKey] {
                thisRemoteDevice.advDataLocalName = String(advertisementDataLocalNameKey)
                }
            else
            {
                print("Nil found unwrapping AdvertisementDataLocalNameKey")
            }
            
            // Get ManufacturerDataKey
            if let advertisementDataManufacturerDataKey = advertisementData[CBAdvertisementDataManufacturerDataKey] {
                thisRemoteDevice.advDataManufacturerData = String(advertisementDataManufacturerDataKey)
            }
            else
            {
                print("Nil found unwrapping AdvertisementDataManufacturerDataKey")
            }
            
            // Get ServiceDataKeys
            if let advertisementDataServiceDataKeys = advertisementData[CBAdvertisementDataServiceDataKey] as? Dictionary<CBUUID, NSData> {
                // Get an array of the Data Service Data Keys Keys :)
                let cbuuidArray = Array(advertisementDataServiceDataKeys.keys)
                // Itterate.
                for cbuuid in cbuuidArray {
                    // Convert each to a string
                    if let data = advertisementDataServiceDataKeys[cbuuid]{
                        if let advString = String(data: data, encoding: NSUTF8StringEncoding) {
                            thisRemoteDevice.advDataServiceUUIDs?.updateValue(advString, forKey: cbuuid)
                        }
                    }
                }
            }
            else
            {
                print("Nil found unwrapping AdvertisementDataServiceDataKey")
            }
            
            // Get OverflowServiceUUIDsKey
            if let advertisementDataOverflowServiceUUIDsKey = advertisementData[CBAdvertisementDataOverflowServiceUUIDsKey] as? Array<String> {
                for item in advertisementDataOverflowServiceUUIDsKey {
                    thisRemoteDevice.advDataOverflowServiceUUIDsKey?.append(item)
                }
            }
            else
            {
                print("Nil found unwrapping AdvertisementDataOverflowServiceUUIDsKey")
            }
            
            if let advertisementDataTxPowerLevelKey = advertisementData[CBAdvertisementDataTxPowerLevelKey] {
                if let txInt = advertisementDataTxPowerLevelKey as? Int{
                    thisRemoteDevice.advDataTxPowerLevel = txInt
                }
            }
            else
            {
                print("Nil found unwrapping AdvertisementDataTxPowerLevelKey")
            }
            
            // Get IsConnectable
            let advertisementDataIsConnectable = advertisementData[CBAdvertisementDataIsConnectable]
            if let advertisementDataIsConnectable = advertisementDataIsConnectable {
                thisRemoteDevice.advDataIsConnectable = String(advertisementDataIsConnectable)
            }
            else
            {
                print("Nil found unwrapping AdvertisementDataIsConnectable")
            }
            
            if let advertisementDataSolicitedServiceUUIDsKey = advertisementData[CBAdvertisementDataSolicitedServiceUUIDsKey] as? Array<String> {
                for item in advertisementDataSolicitedServiceUUIDsKey {
                    thisRemoteDevice.advSolicitedServiceUUID?.append(item)
                }
            }
            else
            {
                print("Nil found unwrapping AdvertisementDataSolicitedServiceUUIDsKey")
            }
        }
        
        if let thisRemoteDeviceID = thisRemoteDevice.ID {
                discoveredDeviceList.updateValue(thisRemoteDevice, forKey: thisRemoteDeviceID)
        }
        
        if let peripheralName = peripheral.name {
            discoveredDeviceIdByName.updateValue(peripheral.identifier, forKey: peripheralName)
        }
        discoveredPeripherals.updateValue(thisRemoteDevice, forKey: peripheral.identifier)
        // Clear any connections.  Strangely, if a search is initiated, all devices are disconnected without didDisconnectPeripheral() being called.
        
    }
    
    @objc public func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        // Look for set characteristics.
        // If not, do below.
        if let connectedPeripheral = connectedPeripherals[peripheral.identifier]{
            if let connectedPeripheralbbPeripheral = connectedPeripheral.bbPeripheral {
                if let peripheralServices = peripheral.services {
                    for service in peripheralServices {
                        connectedPeripheralbbPeripheral.discoverCharacteristics(nil, forService: service)
                        connectedPeripheral.bbServices?.append(service)
                        debugOutput("didDiscoverServices: "+String(service.UUID.UUIDString))
                    }
                }
            }
        }
    }
    
    @objc public func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        // Look for set characteristics descriptors.
        // If not, do below.
        if let connectedPeripheral = connectedPeripherals[peripheral.identifier]{
            if let connectedPeripheralbbPeripheral = connectedPeripheral.bbPeripheral
            {
                if let serviceCharacteristics = service.characteristics {
                    for characteristic in serviceCharacteristics {
                        connectedPeripheral.bbCharacteristics?.append(characteristic)
                        connectedPeripheralbbPeripheral.discoverDescriptorsForCharacteristic(characteristic)
                    }
                }
            }
        }
    }
    
    @objc public func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        // Look for set characteristics descriptors.
        // If not, do below.
        if let connectedPeripheral = connectedPeripherals[peripheral.identifier]{
            if let descriptors = characteristic.descriptors {
                for descriptor in descriptors {
                    connectedPeripheral.bbDescriptors?.append(descriptor)
                }
            }
        }
    }

    
    internal func disconnectFromPeripheral(deviceOfInterest: NSUUID)->Bool {
        if let deviceToDisconnectPeripheral = connectedPeripherals[deviceOfInterest]?.bbPeripheral {
            activeCentralManager.cancelPeripheralConnection(deviceToDisconnectPeripheral)
            purposefulDisconnect = true
            return true
        }
        else
        {
            // ERROR: Device does not exist.
            return false
        }
    }

    internal func reconnectTimerExpired(){
        if let lastConnectedPeripheralNSUUID = lastConnectedPeripheralNSUUID {
            connectToDevice(lastConnectedPeripheralNSUUID)
        }
    }
    
}

class LocalBluetoothPeripheral: LocalPeripheral {
    
}

class LocalBluetoothLEPeripheral: LocalPeripheral {
    
}




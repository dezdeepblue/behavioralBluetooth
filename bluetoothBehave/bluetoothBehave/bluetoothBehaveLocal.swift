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
@objc public protocol bluetoothBehaveLocalDelegate {
    optional func searchTimerExpired()
    optional func localDeviceStateChange()
    optional func connectedToDevice()
}

// #MARK: LocalBehavioralSerialDevice
/// This hopefully provides some info
public class bluetootBehaveLocal: NSObject, bluetoothBehaveLocalDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: Properties START
    // Device lists
    
    // Discovered Device handles
    private var discoveredDeviceIdByName: Dictionary<String, NSUUID> = [:]
    private var discoveredDeviceNameById: Dictionary<NSUUID, String> = [:]
    internal var discoveredDeviceIdArray: Array<NSUUID> = []
    internal var discoveredDeviceRSSIArray: Array<Int> = []
    
    // Device information
    internal var deviceState = DeviceState()
    
    public var hardwareID: NSUUID?
    public var lastConnectedDevice: NSUUID?
    public var allowConnectionInBackground: Bool = false
    public var rxSerialBuffer: String?
    public var purposefulDisconnect = false
    
    // Behavioral
    internal var connectionsLimit: Int = 1
    internal var retriesAfterConnectionFail: Int = 1
    internal var retriesOnDisconnect: Int = 1
    private var characteristicsAreAlwaysInteresting: Bool = false
    private var verboseOutput = false
    // Behavioral: Durations.
    internal var searchTimeout: Double = 1.0
    internal var reconnectTimerDuration: Double = 1.0
    public var timeBeforeAttemptingReconnectOnConnectionFail: Double = 0.5
    public var timeBeforeAttemptingReconnectOnDisconnect: Double = 0.5
    // Behavioral: Indexes
    public var retryIndexOnFail: Int = 0
    public var retryIndexOnDisconnect: Int = 0

    // Delegate for search updates.
    public var delegate:bluetoothBehaveLocalDelegate? = nil
    internal var lastConnectedPeripheralNSUUID: NSUUID?
    
    // Search properities.
    //internal var searchComplete: Bool = false
    internal var searchTimeoutTimer: NSTimer = NSTimer()
    internal var reconnectTimer: NSTimer = NSTimer()
    
    //  CoreBluetooth Classes
    internal var activeCentralManager = CBCentralManager()
    internal var activePeripheralManager = CBPeripheralManager()
    
    // Peripheral List
    private var connectedPeripherals: Dictionary<NSUUID, bluetoothBehaveRemote> = [:]
    private var discoveredPeripherals: Dictionary<NSUUID, bluetoothBehaveRemote> = [:]
    private var discoveredPeripheralsNames: Dictionary<String, NSUUID> = [:]
    private var discoveredPeripheralNameById: Dictionary<NSUUID, String> = [:]
    
    // Behavioral: Variables.
    internal var discoverAdvertizingDataOnSearch: Bool = false;
    private var discoveredServices: Array<CBUUID>?
    var interestingCharacteristics: Array<CBCharacteristic>?
    
    
    // Unknown Index
    var unknownIndex = 0
    
    // MARK: Properties END
    
    // MARK: Updates from Remote
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
    internal func setConnectedDevice(nsuuidAsKey: NSUUID, device: bluetoothBehaveRemote){
        
        connectedPeripherals.updateValue(device, forKey: nsuuidAsKey)
        debugOutput("setConnectedDevice")
    }
    // #MARK: State Getters
    public func getHardwareState()->DeviceState.hardwareStates {
        return self.deviceState.hardware
    }

    public func getConnectionState()->DeviceState.connectionStates{
        return self.deviceState.connection
    }

    public func getSearchState()->DeviceState.searchStates{
        return self.deviceState.search
    }

    // #MARK: LocalBluetoothLECentral: Getters / Setters
    public override init() {
        super.init()
        activeCentralManager.delegate = self
    }
    
    // Behavioral: Methods.
    
    public func characteristicsAreAlwaysInteresting(enable: Bool) -> Bool{
        characteristicsAreAlwaysInteresting = enable
        return characteristicsAreAlwaysInteresting
    }
    
    public func clearInterestingCharacteristics(){
        interestingCharacteristics?.removeAll()
    }
    
    public func addDesiredService(service: String){
        let serviceAsCBUUID = CBUUID(string: service)
        if var discoveredServices = discoveredServices {
            if(!discoveredServices.contains(serviceAsCBUUID)){
                discoveredServices.append(serviceAsCBUUID)
            }
        }
    }
    
    public func cleardiscoveredServices(){
        discoveredServices?.removeAll()
    }
    
    public func setDiscoverAdvertizingData(enable: Bool){
        discoverAdvertizingDataOnSearch = enable
    }
    
    /**
     ### Returns a discovered device's NSUUID.
     - parameter name: String representing the device's advertized name.
     */
    public func getDeviceIdByName(name: String)->NSUUID?{
        return discoveredPeripheralsNames[name]
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
        return discoveredPeripheralNameById[deviceOfInterest]
    }
    
    /**
     ### Returns a RemoteBluetoothLEPeripheral object of interest.
     - parameter deviceOfInterest: NSUUID
     */
    public func getDiscoveredRemoteDeviceByID(deviceNSUUID: NSUUID)->bluetoothBehaveRemote?{
        return discoveredPeripherals[deviceNSUUID]
    }
    
    /**
     ### Returns a RemoteBluetoothLEPeripheral object of interest.
     - parameter name: String representing a RemoteBluetoothLEPeripheral object's advertized name.
     */
    public func getDiscoveredRemoteDeviceByName(name: String)->bluetoothBehaveRemote?{
        if let deviceID = getDeviceIdByName(name){
            return getDiscoveredRemoteDeviceByID(deviceID)
        }
        return nil
    }
    
    public func getDeviceNamesAsArray()->Array<String>{
        var names: Array<String> = [""]
        names = Array<String>(discoveredPeripheralsNames.keys)
        return names
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
        debugOutput("getNumberOfDiscoveredDevices: " + String(discoveredPeripherals.count))
        return discoveredPeripherals.count
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
    
    public func verboseOutput(enabled: Bool){
        verboseOutput = enabled
    }
    
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
        if let rssi = discoveredPeripherals[deviceOfInterest]?.rssi {
            return rssi
        }
        else {
            return 0
        }
    }
    
    
    public func getDiscoveredDeviceByRSSIDictionary()->Dictionary<NSUUID, Int>{
        
        
        let arrayOfDevices = Array(discoveredPeripherals.keys)
        var dict: Dictionary<NSUUID, Int>?
        for key in arrayOfDevices {
            if let rssiForDevice = discoveredPeripherals[key]?.rssi {
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
        
        // Bubble-POP! :)
        var rssies = discoveredDeviceRSSIArray
        var nsuuids = discoveredDeviceIdArray
        let itemCount = discoveredDeviceIdArray.count
        
        for(var i = 1; i < itemCount; i++){
            for(var j = 0; j < itemCount - 1;j++)
            {
                // Multiply by -1 to make it descending.
                if((Int(rssies[j]) * -1) > (Int(rssies[j+1]) * -1))
                {
                    let temp1 = Int(rssies[j])
                    let temp2 = nsuuids[j]
                    
                    rssies[j] = Int(rssies[j+1]);
                    nsuuids[j] = nsuuids[j+1]
                    
                    rssies[j+1] = temp1
                    nsuuids[j+1] = temp2
                }
            }
        }
        
        return (nsuuids, rssies)
    }

    /**
     Returns the full Behavioral DeviceState object.
     */
    internal func getDeviceState()->DeviceState{
        // Provide the raw state of the device.
                // #MARK: UNUSED
        return self.deviceState
    }
    
    /**
     Returns true if already connected to the deviceOfInterest.
     */
    public func alreadyConnected(deviceNSUUID: NSUUID) -> Bool {
        // Checks if we are already connected to a device.
                // #MARK: UNUSED
        return connectedPeripherals[deviceNSUUID] != nil
    }
    
    
    internal func clearDiscoveredDevices(){
        // Device descriptors for discovered devices.
        discoveredPeripherals.removeAll()
    }

    internal func clearConnectedDevices(){
        discoveredPeripherals.removeAll()
    }
    
    // #MARK: Debug info.
    public func printDiscoveredDeviceListInfo(){
        // Check to make sure we're done searching, then print the all devices info.
    //if(searchComplete){
        if(self.deviceState.search == DeviceState.searchStates.idleWithDiscoveredDevices){
            for ID in discoveredPeripherals.keys {
                if let name = discoveredPeripherals[ID]?.getDeviceName(){
                    print("Device UUID: \(name)")
                }
                if let thisUUID = discoveredPeripherals[ID]?.idAsString() {
                    print("\t\tUUID: \(thisUUID)")
                }
                if let RSSI = discoveredPeripherals[ID]?.rssi{
                    print("\t\tRRSI: \(RSSI)")
                }
            }
            
        }
    }
    
    public func printConnectedDevices(){
        print("Number of connected devices: \(connectedPeripherals.count)")
    }

    
    
    // #MARK: LocalBluetoothLECentral: Actions
    
    public func addServiceOfInterest(serviceOfInterest: String){
        let cbServiceOfInterest = CBUUID(string: serviceOfInterest)
        discoveredServices?.append(cbServiceOfInterest)
    }
    
    /**
     ### Method called to initiate the CBCentralManager didScanForPeripherals.  The method is an NSTimeInterval representing how long the CBCentralManager should search before stopping.  The method SearchTimerExpired is called after the interval expires.
     - parameter timeoutSecs: An NSTimeInterval representing the search duration.
     */
    public func search(timeoutSecs: NSTimeInterval){
        // 1. Empty peripheral lists.
        // 2. Reset unknownDevice index; used for avoiding duplicate names.
        // 3. Set device state to scanning.
        
        discoveredPeripherals = [:]
        discoveredDeviceRSSIArray = []
        discoveredDeviceIdArray = []
        
        unknownIndex = 0
        
        self.deviceState.search = DeviceState.searchStates.scanning
        //clearDiscoveredDevices()
        // Strange.  If a search for peripherals is initiated it cancels all connections without firing didDisconnectPeripheral.  This compensates.
        clearConnectedDevices()
        
        //activeCentralManager = CBCentralManager(delegate: self, queue: nil)
        
        activeCentralManager.scanForPeripheralsWithServices(discoveredServices, options: nil)
        searchTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(timeoutSecs, target: self, selector: Selector("searchTimerExpire"), userInfo: nil, repeats: false)
        debugOutput("Started search with "+String(timeoutSecs) + " sec timeout")
    }
    
    /**
     Requests the Local Device connect to a Bluetooth LE Remote device of interest.  The call will assure a connection to the particular device doesn't exist.  If the `connectionsLimit` has not been reached.
     */
    public func connectToDevice(remoteDevice: bluetoothBehaveRemote) -> Bool {
        
        // 1. Set state.
        // 2. Get peripheral out of bbObject.
        // 3. Get peripheral name.
        // 4. Set new lastConnect peripheral.
        // 5. Return false if already connected or no peripherals discovered.
        // 6. Check to see if connection threshold is met.
        
        // 1
        self.deviceState.connection = DeviceState.connectionStates.connecting
        // 2
        if let peripheral = remoteDevice.bbPeripheral{
            
            // 3
            var thisDeviceName = ""
            if let deviceName = getDeviceName(peripheral.identifier) {
                thisDeviceName = deviceName
            }
            
            debugOutput("Attempting to connect to: " + thisDeviceName)
            
            // 4
            lastConnectedPeripheralNSUUID = peripheral.identifier
            
            // 5
            if(discoveredPeripherals.isEmpty || alreadyConnected(peripheral.identifier)){
                if(discoveredPeripherals.isEmpty){
                    debugOutput("There are no discovered peripherals")
                } else {
                    debugOutput("Already connected to " + thisDeviceName)
                }
                return false
            }
                // 6
            else {
                if(connectedPeripherals.count < connectionsLimit){
                    if let peripheralToConnect = discoveredPeripherals[peripheral.identifier]?.bbPeripheral{
                        
                        if let connectedRemoteSerialDevice = discoveredPeripherals[peripheral.identifier] {
                            setConnectedDevice(peripheral.identifier, device: connectedRemoteSerialDevice)
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
        return false
    }
    
    /**
     ###Writes data to a particular RemoteDevice
     */
    public func writeToDevice(deviceOfInterest: NSUUID, data: String){
        debugOutput("writeToDevice")
        
        // 1. Find the connected remote in list and get its peripheral.
        // 2. Convert the String to NSData
        // 3. If a desired characteristic has been given, write to it.  Probably need to change desiredCharacteristic to be part of the remoteDevice object.
        // 4. Write NSData to characteristic(s)
        
        if let peripheralOfInterest = connectedPeripherals[deviceOfInterest]?.bbPeripheral {
            
            if let stringAsNSData = data.dataUsingEncoding(NSUTF8StringEncoding) {
                if let interestingCharacteristics = interestingCharacteristics {
                    for characteristic in interestingCharacteristics {
                        debugOutput("Wrote to characteristic: \(characteristic) on device named: \(peripheralOfInterest.name) with data:\n\(stringAsNSData)")
                        peripheralOfInterest.writeValue(stringAsNSData, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithoutResponse)
                        // #MARK: Add "WriteWithResponse" option.
                    }
                } else {
                    debugOutput("No desiredCharacteristic set.  Nothing written")
                }
            }
        }
        // #MARK: ADD
    }
    
    /**
     ### The CBCentralManager will actively attempt to disconnect from a remote device.
     - parameter deviceOfInterest: The NSUUID of device needed to be disconnecting.
     */
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
    
    public func disconnectFromAllPeripherals(){
        
    }
    
    /**
     ### Method fired after lost connection with device.  The delay can be changed by calling either reconnectOnFail or reconnectOnDisconnect.
     */
    internal func reconnectTimerExpired(){
        if let lastConnectedPeripheralNSUUID = lastConnectedPeripheralNSUUID {
            activeCentralManager.stopScan()
            if let lastConnectedDevice = discoveredPeripherals[lastConnectedPeripheralNSUUID]{
                retryIndexOnFail++
                connectToDevice(lastConnectedDevice)
            }
        }
    }
    
    /**
     ### Method after search duration has expired.
     */
    @objc internal func searchTimerExpire(){
        searchTimeoutTimer.invalidate()
        
        if(discoveredPeripherals.isEmpty){
            self.deviceState.search = DeviceState.searchStates.idle
        } else {
            self.deviceState.search = DeviceState.searchStates.idleWithDiscoveredDevices
        }
        
        //searchComplete = true
        
        // Be respectful of battery life.
        self.activeCentralManager.stopScan()
        
        if let searchTimerExpired = delegate?.searchTimerExpired?(){
            searchTimerExpired
        }
        else {
            // THROW ERROR
        }
        
    }
    
    // #MARK: Central Manager Methods
    
    /**
    ### Updates the the state of the Local Bluetooth LE device.
    */
    public func centralManagerDidUpdateState(central: CBCentralManager) {
        // Make sure the BLE device is on.
        switch activeCentralManager.state {
        case CBCentralManagerState.Unknown:
            self.deviceState.hardware = DeviceState.hardwareStates.unknown
            break
        case CBCentralManagerState.Resetting:
            self.deviceState.hardware = DeviceState.hardwareStates.resetting
            break
        case CBCentralManagerState.Unsupported:
            self.deviceState.hardware = DeviceState.hardwareStates.unsupported
            break
        case CBCentralManagerState.Unauthorized:
            self.deviceState.hardware = DeviceState.hardwareStates.unauthorized
            break
        case CBCentralManagerState.PoweredOff:
            self.deviceState.hardware = DeviceState.hardwareStates.off
            break
        case CBCentralManagerState.PoweredOn:
            self.deviceState.hardware = DeviceState.hardwareStates.unknown
            break
        }
        if let deviceStateChanged = delegate?.localDeviceStateChange?(){
            deviceStateChanged
        }
    }
    
    /**
     ### CoreBluteooth method called when CBCentralManager when scan discovers peripherals.
     */
    public func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        debugOutput("didDiscoverPeripheral "+String(peripheral.identifier.UUIDString))
        // 1. Creates RemotebBluetoothLE object and populates its data.
        // 2. Add the remote object to our Remote object Dictioanry.
        
        let thisRemoteDevice = bluetoothBehaveRemote()
        
        // Populate the object.
        thisRemoteDevice.ID = peripheral.identifier
        thisRemoteDevice.bbPeripheral = peripheral
        
        discoveredDeviceIdArray.append(peripheral.identifier)
        discoveredDeviceRSSIArray.append(Int(RSSI))
        
        // Set its name.
        if let name = peripheral.name {
            discoveredPeripheralsNames[name] = peripheral.identifier
            discoveredPeripheralNameById[peripheral.identifier] = name
        }
        else {
            let stringIndex = String(unknownIndex)
            discoveredPeripheralsNames["Unknown_\(stringIndex)"] = peripheral.identifier
            discoveredPeripheralNameById[peripheral.identifier] = "Unknown_\(stringIndex)"
            unknownIndex++
        }
        // Set RSSI
        print(RSSI)
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
            discoveredPeripherals.updateValue(thisRemoteDevice, forKey: thisRemoteDeviceID)
        }
        
        discoveredPeripherals.updateValue(thisRemoteDevice, forKey: peripheral.identifier)
        // Clear any connections.  Strangely, if a search is initiated, all devices are disconnected without didDisconnectPeripheral() being called.
        
    }
    
    /**
     ### CoreBluetooth method called when CBCentralManager connects to peripheral.
     */
    @objc public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        // 1. Add the conencted peripheral to the discoveredPeripherals dictionary
        // 2. Find desired device in connectedPeripherals
        // 3. Set the new connected device's peripheral delegate.
        // 4. If a specific services are listed, discover them, if not, discover all.
        // 5. Set connection status to connected.
        // 6. Notify the optional delegate.
        
        // 1
        if let desiredDevice = discoveredPeripherals[peripheral.identifier] {
            connectedPeripherals.updateValue(desiredDevice, forKey: peripheral.identifier)
                debugOutput("didConnectToPeripheral: " + peripheral.identifier.UUIDString )
        }
        
        // 2
        if var desiredDeviceInConnectedDevices = connectedPeripherals[peripheral.identifier]?.bbPeripheral {
            
            // 3
            desiredDeviceInConnectedDevices = peripheral
            desiredDeviceInConnectedDevices.delegate = self
            
            // 4  NOTE: If array is empty, it will automatically search for all as the array will be nil.
            desiredDeviceInConnectedDevices.discoverServices(discoveredServices)
        }
        
        // 5
        self.deviceState.connection = DeviceState.connectionStates.connected
        
        if let connectedToDevice = delegate?.connectedToDevice?(){
            connectedToDevice
            debugOutput("Invoked Delegate: connectedToDevice")
        }
        else {
            // #MARK: ADD
            // Handle if no delegate is setup.
        }
    }
    
    /**
     ### CoreBluteooth method called when CBCentralManager fails to connect to a peripheral.
     */
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
    
    /**
     ### CoreBluteooth method called when CBCentralManager loses connection.
     */
    @objc public func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        // If connection is lost, remove it from the connected device dictionary.
        connectedPeripherals.removeValueForKey(peripheral.identifier)
        print("Lost connection to: \(peripheral.identifier.UUIDString)")
        
        // Set the peripheral
        discoveredPeripherals[peripheral.identifier]?.deviceState.connection = DeviceState.connectionStates.purposefulDisconnect
        
        if(purposefulDisconnect == false){
            
            discoveredPeripherals[peripheral.identifier]?.deviceState.connection = DeviceState.connectionStates.disconnected
            
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
    
    // #MARK: Peripheral Manager Methods
    /**
    ### CoreBluteooth method called when CBCentralManager discovers a peripheral's services.
    */
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
    
    /**
     ### CoreBluteooth method called when CBCentralManager discovers a service's characteristics.
     */
    @objc public func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        // Look for set characteristics descriptors.
        // If not, do below.
        if let connectedPeripheral = connectedPeripherals[peripheral.identifier]{
            if let connectedPeripheralbbPeripheral = connectedPeripheral.bbPeripheral
            {
                if let serviceCharacteristics = service.characteristics {
                    for characteristic in serviceCharacteristics {
                        
                        if(characteristicsAreAlwaysInteresting == true){
                            // WEIRD! Method for appending to optional arrays.
                            if (interestingCharacteristics?.append(characteristic)) == nil {
                                interestingCharacteristics = [characteristic]
                            }
                        }
                            print("Int. Char. after: " + String(interestingCharacteristics))
                        connectedPeripheral.bbCharacteristics?.append(characteristic)
                        connectedPeripheralbbPeripheral.discoverDescriptorsForCharacteristic(characteristic)
                    }
                }
            }
        }
    }
    
    /**
     ### CoreBluteooth method called when CBCentralManager discovers a characteristic's descriptors.
     */
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
}




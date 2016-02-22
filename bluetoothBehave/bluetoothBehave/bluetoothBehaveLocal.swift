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
    optional func debug(message: String)
    optional func receivedNotificationAsString(deviceID: NSUUID, string: String)
    optional func receivedNotificationAsNSData(deviceID: NSUUID, data: NSData)
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
    private var connectedPeripheralsIDsByName: Dictionary<String, NSUUID> = [:]
    private var connectedPeripheralNameById: Dictionary<NSUUID, String> = [:]
    
    private var discoveredPeripherals: Dictionary<NSUUID, bluetoothBehaveRemote> = [:]
    private var discoveredPeripheralsIDsByName: Dictionary<String, NSUUID> = [:]
    private var discoveredPeripheralNameById: Dictionary<NSUUID, String> = [:]
    
    // Behavioral: Variables.
    internal var discoverAdvertizingDataOnSearch: Bool = false;
    private var discoveredServices: Array<CBUUID>?
    private var interestingCharacteristicsForWriting: Array<CBCharacteristic> = Array<CBCharacteristic>()
    private var interestingCharacteristicsForReading: Array<CBCharacteristic>?
    
    private var allCharacteristicsAreInterestingForReading: Bool = true
    private var allCharacteristicsAreInterestingForWriting: Bool = true
    
    // Unknown Index
    var unknownIndex = 0
    
    // MARK: Properties END
    
    // MARK: Updates from Remote
    func update() {
        
    }
    
    internal func debugOutput(message: String){
        if(verboseOutput){
            if let debug = delegate?.debug{
                debug(message+"\n")
            }
            print(message)
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
    public func state()->DeviceState.states {
        return self.deviceState.state
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
        interestingCharacteristicsForWriting.removeAll()
    }
    
    public func allDeviceUpdatesAreInteresting(enable: Bool){
        allCharacteristicsAreInterestingForReading = enable
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
    public func getDiscoveredDeviceIdByName(name: String)->NSUUID?{
        return discoveredPeripheralsIDsByName[name]
    }
    
    /**
     Provides the name of a particular connected device as a String object.
     
     ```swift
     println(getDeviceName(myDeviceNSUUID))
     ```
     
     ```xml
     Output: myDevice
     ```
     
     */
    public func getDiscoveredDeviceNameByID(deviceOfInterest: NSUUID)->String?{
        return discoveredPeripheralNameById[deviceOfInterest]
    }
    
    /**
     ### Returns a connected device's NSUUID.
     - parameter name: String representing the device's advertized name.
     */
    public func getConnectedDeviceIdByName(name: String)->NSUUID?{
        return connectedPeripheralsIDsByName[name]
    }
    
    /**
     Provides the name of a particular connected device as a String object.
     
     ```swift
     println(getDeviceName(myDeviceNSUUID))
     ```
     
     ```xml
     Output: myDevice
     ```
     
     */
    public func getConnectedDeviceNameByID(deviceOfInterest: NSUUID)->String?{
        return connectedPeripheralNameById[deviceOfInterest]
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
        if let deviceID = getDiscoveredDeviceIdByName(name){
            return getDiscoveredRemoteDeviceByID(deviceID)
        }
        return nil
    }
    
    public func getDeviceNamesAsArray()->Array<String>{
        var names: Array<String> = [""]
        names = Array<String>(discoveredPeripheralsIDsByName.keys)
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
    
    /**
     ### Returns an array of NSUUIDs of all devices connected to the iOS central.
     */
    public func connectedDevices()->Array<NSUUID>{
        return Array(connectedPeripheralsIDsByName.values)
    }

    /**
     ### Returns true if the NSUUID of interest is contained in the list of connected peripherals.
     - parameter deviceID: NSUUID of the device whose connection status is in question. lkkm
     */
    public func isPeripheralConnected(deviceID: NSUUID)->Bool {
        if(connectedDevices().contains(deviceID)){
            return true
        } else {
            return false
        }
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
        if(self.deviceState.state == DeviceState.states.idleWithDiscoveredDevices){
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
    
    public func addServiceOfWritingInterest(serviceOfInterest: String){
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
        
        self.deviceState.state = DeviceState.states.scanning
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
        self.deviceState.state = DeviceState.states.connecting
        // 2
        if let peripheral = remoteDevice.bbPeripheral{
            
            // 3
            var thisDeviceName = ""
            if let deviceName = getDiscoveredDeviceNameByID(peripheral.identifier) {
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
                        
                        // MARK: ADD CBConnectPeripheralOptions
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
    public func writeToDevice(deviceOfInterest: NSUUID, string: String){
        debugOutput("writeToDevice")
        
        // 1. Find the connected remote in list and get its peripheral.
        // 2. Convert the String to NSData
        // 3. If a desired characteristic has been given, write to it.  Probably need to change desiredCharacteristic to be part of the remoteDevice object.
        // 4. Write NSData to characteristic(s)
        
        if let peripheralOfInterest = connectedPeripherals[deviceOfInterest]?.bbPeripheral {
            if let stringAsNSData = string.dataUsingEncoding(NSUTF8StringEncoding) {
                for characteristic in interestingCharacteristicsForWriting {
                    debugOutput("Wrote to characteristic: \(characteristic) on device named: \(peripheralOfInterest.name) with data:\n\(stringAsNSData)")
                    peripheralOfInterest.writeValue(stringAsNSData, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithoutResponse)
                    // #MARK: Add "WriteWithResponse" option.
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
        
        // 1. Unwrap peripheral by ID
        // 2. Cancel connection to peripheral.
        // 3. Set state to purposeful disconnect.
        
        if let deviceToDisconnectPeripheral = connectedPeripherals[deviceOfInterest]?.bbPeripheral {
            activeCentralManager.cancelPeripheralConnection(deviceToDisconnectPeripheral)
            self.deviceState.state = DeviceState.states.purposefulDisconnect
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
        
        // 1. Unwrap peripheral(s)
        // 2. Disconnect all peripheral(s).
        
        for peripheral in connectedPeripherals {
            if let peripheral = peripheral.1.bbPeripheral {
                activeCentralManager.cancelPeripheralConnection(peripheral)
            }
        }
        
    }
    
    /**
     ### Method fired after lost connection with device.  The delay can be changed by calling either reconnectOnFail or reconnectOnDisconnect.
     */
    internal func reconnectTimerExpired(){
        
        // 1. If there has been a connection this session, unwrap the ID.
        // 2. Stop searching for devices. (Why do I have this here?)
        // 3. Check if last connected device ID is in the lsit of discovered peripheral, if so, unwrap it.
        // 4. Increment retry index.
        // 5. Attempt to connect to device.
        
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
        
        // 1. Invalidate timer.
        // 2. Set device state.
        // 3. Stop searching to save battery.
        // 4. Check for delegate, update delegate.
        
        // 1
        searchTimeoutTimer.invalidate()
        // 2
        if(discoveredPeripherals.isEmpty){
            self.deviceState.state = DeviceState.states.idle
        } else {
            self.deviceState.state = DeviceState.states.idleWithDiscoveredDevices
        }
        // 3
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
        
        // 1. Make sure the iOS hardware is on and pass it to the behave state manager.
        
        // Make sure the BLE device is on.
        switch activeCentralManager.state {
        case CBCentralManagerState.Unknown:
            self.deviceState.state = DeviceState.states.unknown
            break
        case CBCentralManagerState.Resetting:
            self.deviceState.state = DeviceState.states.resetting
            break
        case CBCentralManagerState.Unsupported:
            self.deviceState.state = DeviceState.states.unsupported
            break
        case CBCentralManagerState.Unauthorized:
            self.deviceState.state = DeviceState.states.unauthorized
            break
        case CBCentralManagerState.PoweredOff:
            self.deviceState.state = DeviceState.states.off
            break
        case CBCentralManagerState.PoweredOn:
            self.deviceState.state = DeviceState.states.unknown
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
        // 3. Populate the Remote object.
        // 4. Set device name.
        // 5. Discover Advertizing data.
        // 6. Add the populated Remote object to the list of discovered peripherals.
        
        let thisRemoteDevice = bluetoothBehaveRemote()
        
        // Populate the flat object.
        thisRemoteDevice.ID = peripheral.identifier
        thisRemoteDevice.bbPeripheral = peripheral
        
        discoveredDeviceIdArray.append(peripheral.identifier)
        discoveredDeviceRSSIArray.append(Int(RSSI))
        
        // Set its name.
        if let name = peripheral.name {
            discoveredPeripheralsIDsByName[name] = peripheral.identifier
            discoveredPeripheralNameById[peripheral.identifier] = name
        }
        else {
            let stringIndex = String(unknownIndex)
            discoveredPeripheralsIDsByName["Unknown_\(stringIndex)"] = peripheral.identifier
            discoveredPeripheralNameById[peripheral.identifier] = "Unknown_\(stringIndex)"
            unknownIndex++
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
            discoveredPeripherals.updateValue(thisRemoteDevice, forKey: thisRemoteDeviceID)
        }
        
    }
    
    /**
     ### CoreBluetooth method called when CBCentralManager connects to peripheral.
     */
    @objc public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        // 1. Add the conencted peripheral to the discoveredPeripherals dictionary
        // 2. Add device to deviceByName and deviceByID arrays.
        // 3. Find desired device in connectedPeripherals
        // 4. Set the new connected device's peripheral delegate.
        // 5. If a specific services are listed, discover them, if not, discover all.
        // 6. Set connection status to connected.
        // 7. Notify the optional delegate.
        
        // 1
        if let desiredDevice = discoveredPeripherals[peripheral.identifier] {
            connectedPeripherals.updateValue(desiredDevice, forKey: peripheral.identifier)
                debugOutput("didConnectToPeripheral: " + peripheral.identifier.UUIDString )
            // 2
            if let name = getDiscoveredDeviceNameByID(peripheral.identifier) {
                connectedPeripheralNameById[peripheral.identifier] = name
                connectedPeripheralsIDsByName[name] = peripheral.identifier
            }
        }
        

        
        // 3
        if var desiredDeviceInConnectedDevices = connectedPeripherals[peripheral.identifier]?.bbPeripheral {
            
            // 4
            desiredDeviceInConnectedDevices = peripheral
            desiredDeviceInConnectedDevices.delegate = self
            
            // 5  NOTE: If array is empty, it will automatically search for all as the array will be nil.
            desiredDeviceInConnectedDevices.discoverServices(discoveredServices)
        }
        
        // 6
        self.deviceState.state = DeviceState.states.connected
        
        // 7
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

        // 1. Set state
        // 2. Check if retry limit is exceeded.
        // 3.   Set reconnect timer.
        
        self.deviceState.state = DeviceState.states.failedToConnect
        
        if(retryIndexOnFail < retriesAfterConnectionFail){
            
            reconnectTimer = NSTimer.scheduledTimerWithTimeInterval(timeBeforeAttemptingReconnectOnConnectionFail, target: self, selector: Selector("reconnectTimerExpired"), userInfo: nil, repeats: false)
            
            debugOutput("didFailToConnectPeripheral: Retry# " + String(retryIndexOnFail) + " of " + String(retriesAfterConnectionFail) + " with " + String(timeBeforeAttemptingReconnectOnConnectionFail) + "secs inbetween attempt")
            
        }
        else {
            debugOutput("didFailToConnectPeripheral: Unable to connect")
        }
    }
    
    /**
     ### CoreBluteooth method called when CBCentralManager loses connection.
     */
    @objc public func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        // 1. Remove device ids & names from connected collections.
        // 2. Set the deviceState to purposefulDisconnect.
        // 3. If disconnected on purpose -- 
        // 4. Set device state.
        // 5. Check retry index; try to reconnect to last connected.
        // 6. If purposefully disconnected, tidy up, and set state.
        
        // 1
        if let name = getDiscoveredDeviceNameByID(peripheral.identifier){
            connectedPeripheralsIDsByName.removeValueForKey(name)
            connectedPeripheralNameById.removeValueForKey(peripheral.identifier)
        }
        connectedPeripherals.removeValueForKey(peripheral.identifier)

        debugOutput("Lost connection to: \(peripheral.identifier.UUIDString)")
        
        if(purposefulDisconnect == false){
            
            discoveredPeripherals[peripheral.identifier]?.deviceState.state = DeviceState.states.disconnected
            
            if(retryIndexOnDisconnect < retriesOnDisconnect){

                self.deviceState.state = DeviceState.states.connecting
                
                reconnectTimer = NSTimer.scheduledTimerWithTimeInterval(timeBeforeAttemptingReconnectOnDisconnect, target: self, selector: Selector("reconnectTimerExpired"), userInfo: nil, repeats: false)
                debugOutput("didDisconnectPeripheral, purpose = " + String(purposefulDisconnect) + "\n\tRetry# " + String(retryIndexOnDisconnect) + " of " + String(retriesOnDisconnect) + " with " + String(timeBeforeAttemptingReconnectOnDisconnect) + "secs inbetween attempt")
            }
            else {
                debugOutput("didDisconnectPeripheral: Unable to Connect")
            }
        }
        else {
            // Set the peripheral
            discoveredPeripherals[peripheral.identifier]?.deviceState.state = DeviceState.states.purposefulDisconnect
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
        
        // 1. Assert the discovered peripheral is connected.
        // 2. Unwrap the connected peripheral.
        // 3. Unwrap discovered service.
        // 4. For each service discovered discover characteristics and add the peripheral to the flat object.
        
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
        
        // 1. Assert the peripheral is connected.
        // 2. Unwrap the connected peripheral.
        // 3. Unwrap the discovered service characteristic array.
        // 4. If allCharInter == true, add the characteristic to array for writing or reading
        // 5. Add the characteristic to the flat object.
        // 6. Start discovering descriptors for the characteristic.
        
        
        if let connectedPeripheral = connectedPeripherals[peripheral.identifier]{
            if let connectedPeripheralbbPeripheral = connectedPeripheral.bbPeripheral
            {
                if let serviceCharacteristics = service.characteristics {
                    for characteristic in serviceCharacteristics {
                        
                        if(allCharacteristicsAreInterestingForReading == true){
                            connectedPeripheralbbPeripheral.setNotifyValue(true, forCharacteristic: characteristic)
                        }
                        else if ((interestingCharacteristicsForReading?.contains(characteristic)) != nil){
                            connectedPeripheralbbPeripheral.setNotifyValue(true, forCharacteristic: characteristic)
                        }
                        
                        if(allCharacteristicsAreInterestingForWriting == true){
                           interestingCharacteristicsForWriting.append(characteristic)
                        }
                        //else if (){
                        //    connectedPeripheralbbPeripheral.setNotifyValue(true, forCharacteristic: characteristic)
                        //}

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
        
        // 1. Assert the peripheral is connected.
        // 2. Unwrap the descriptor for the discovered characteristic.
        // 3. Attach the descriptor to flat object.
        
        if let connectedPeripheral = connectedPeripherals[peripheral.identifier]{
            if let descriptors = characteristic.descriptors {
                for descriptor in descriptors {
                    connectedPeripheral.bbDescriptors?.append(descriptor)
                }
            }
        }
    }
    
    public func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        // 1. Unwrap characteristic value
        // 2. Pass the value to delegate as data
        // 3. Pass the value to delegate as String.
        
        if let data = characteristic.value {
            if let receivedNotificationAsNSData = delegate?.receivedNotificationAsNSData?(peripheral.identifier, data: data){
                    receivedNotificationAsNSData
            }
            
            if let receivedNotificationAsString = delegate?.receivedNotificationAsString{
                if let string = String(data:data, encoding: NSUTF8StringEncoding){
                    receivedNotificationAsString(peripheral.identifier, string: string)
                }
            }
        }
    }
    

} // END Class




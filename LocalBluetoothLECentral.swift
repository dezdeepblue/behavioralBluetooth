//
//  LocalBluetoothLECentral.swift
//  behavioralBluetooth
//
//  Created by Casey Brittain on 1/31/16.
//  Copyright © 2016 Honeysuckle Hardware. All rights reserved.
//

import Foundation
import CoreBluetooth

// #MARK: Bluetooth Low Energy
/// ##The Local Bluetooth LE Object
public class LocalBluetoothLECentral: LocalPeripheral, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    //  CoreBluetooth Classes
    internal var activeCentralManager = CBCentralManager()
    internal var activePeripheralManager = CBPeripheralManager()
    
    // Peripheral List
    private var connectedPeripherals: Dictionary<NSUUID, RemoteBluetoothLEPeripheral> = [:]
    private var discoveredPeripherals: Dictionary<NSUUID, RemoteBluetoothLEPeripheral> = [:]
    private var discoveredPeripheralsNames: Dictionary<String, NSUUID> = [:]
    private var discoveredPeripheralNameById: Dictionary<NSUUID, String> = [:]
    
    // Behavioral: Variables.
    var discoverAdvertizingDataOnSearch: Bool = false;
    
    // Unknown Index
    var unknownIndex = 0
    
    override init() {
        super.init()
        activeCentralManager.delegate = self
    }
    
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

    
    public override func getDeviceIdByName(name: String)->NSUUID?{
        return discoveredPeripheralsNames[name]
    }
    
    public override func getDeviceName(deviceOfInterest: NSUUID)->String?{
        return discoveredPeripheralNameById[deviceOfInterest]
    }
    
    public override func getDiscoveredRemoteDeviceByID(deviceNSUUID: NSUUID)->RemoteBluetoothLEPeripheral?{
        return discoveredPeripherals[deviceNSUUID]
    }
    
    public override func getDiscoveredRemoteDeviceByName(name: String)->RemoteBluetoothLEPeripheral?{
        if let deviceID = getDeviceIdByName(name){
            return getDiscoveredRemoteDeviceByID(deviceID)
        }
        return nil
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
                self.deviceState = DeviceState.unknown
                break
            case CBCentralManagerState.Resetting:
                self.deviceState = DeviceState.resetting
                break
            case CBCentralManagerState.Unsupported:
                self.deviceState = DeviceState.unsupported
                break
            case CBCentralManagerState.Unauthorized:
                self.deviceState = DeviceState.unauthorized
                break
            case CBCentralManagerState.PoweredOff:
                self.deviceState = DeviceState.off
                break
            case CBCentralManagerState.PoweredOn:
                //activeCentralManager.scanForPeripheralsWithServices(nil, options: nil)
                self.deviceState = DeviceState.idle
                break
        }
        if let deviceStateChanged = delegate?.localDeviceStateChange?(){
            deviceStateChanged
        }
    }
    
    
    
    // #MARK: Connect to device
    /**
    Requests the Local Device connect to a Bluetooth LE Remote device of interest.  The call will assure a connection to the particular device doesn't exist.  If the `connectionsLimit` has not been reached.
    */
    func connectToDevice(remoteDevice: RemoteBluetoothLEPeripheral) -> Bool {

        if let peripheral = remoteDevice.bbPeripheral{

            var thisDeviceName = ""
            if let deviceName = getDeviceName(peripheral.identifier) {
                thisDeviceName = deviceName
            }
            
            debugOutput("Attempting to connect to: " + thisDeviceName)
            
            // Remember NSUUID
            lastConnectedPeripheralNSUUID = peripheral.identifier
            
            // Check if if we have discovered anything, if so, make sure we are not already connected.
            if(discoveredPeripherals.isEmpty || alreadyConnected(peripheral.identifier)){
                print("Already connected, silly")
                return false
            }
            else {
                if(connectedRemotes.count < connectionsLimit){
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
    
    
    @objc public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        // Add peripheral to connectedPeripheral dictionary.
        // What happens when it connects to a device without discovering it? (reconnect)?
        if let discoveredPeripherals = discoveredPeripherals[peripheral.identifier] {
            connectedRemotes.updateValue(discoveredPeripherals, forKey: peripheral.identifier)
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
    
    // #MARK: Search
    public func search(timeoutSecs: NSTimeInterval){
        
        // Reset unknown device index; used for naming devices lacking names.
        unknownIndex = 0
        
        searchComplete = false
        //clearDiscoveredDevices()
        // Strange.  If a search for peripherals is initiated it cancels all connections without firing didDisconnectPeripheral.  This compensates.
        clearConnectedDevices()
        print(self.deviceState)
        //activeCentralManager = CBCentralManager(delegate: self, queue: nil)
        activeCentralManager.scanForPeripheralsWithServices(nil, options: nil)
        searchTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(timeoutSecs, target: self, selector: Selector("searchTimerExpire"), userInfo: nil, repeats: false)
        debugOutput("Started search with "+String(timeoutSecs) + " sec timeout")
    }
    
    /**
     ###Writes data to a particular RemoteDevice
     */
    public func writeToDevice(deviceOfInterest: NSUUID, data: String){
        debugOutput("writeToDevice")
        // #MARK: UNUSED
    }
    
    // #MARK: Connection Lost.
    @objc public func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        // If connection is lost, remove it from the connected device dictionary.
        connectedRemotes.removeValueForKey(peripheral.identifier)
        print("Lost connection to: \(peripheral.identifier.UUIDString)")

        // Set the peripheral
        discoveredPeripherals[peripheral.identifier]?.deviceState = DeviceState.disconnected
        
        if(purposefulDisconnect == false){
            
            discoveredPeripherals[peripheral.identifier]?.deviceState = DeviceState.disconnected
            
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
            activeCentralManager.stopScan()
            if let lastConnectedDevice = discoveredPeripherals[lastConnectedPeripheralNSUUID]{
                retryIndexOnFail++
                connectToDevice(lastConnectedDevice)
            }
        }
    }
    
    @objc internal override func searchTimerExpire(){
        searchTimeoutTimer.invalidate()
        searchComplete = true
        
        // Be respectful of battery life.
        self.activeCentralManager.stopScan()
        
        if let searchTimerExpired = delegate?.searchTimerExpired?(){
            searchTimerExpired
        }
        else {
            // THROW ERROR
        }
        
    }
}

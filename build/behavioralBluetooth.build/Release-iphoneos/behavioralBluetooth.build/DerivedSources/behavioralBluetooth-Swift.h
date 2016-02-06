// Generated by Apple Swift version 2.1.1 (swiftlang-700.1.101.15 clang-700.1.81)
#pragma clang diagnostic push

#if defined(__has_include) && __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if defined(__has_include) && __has_include(<uchar.h>)
# include <uchar.h>
#elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
#endif

typedef struct _NSZone NSZone;

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif

#if defined(__has_attribute) && __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if defined(__has_attribute) && __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted) 
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if defined(__has_attribute) && __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name) enum _name : _type _name; enum SWIFT_ENUM_EXTRA _name : _type
#endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
#if defined(__has_feature) && __has_feature(modules)
@import UIKit;
@import ObjectiveC;
@import CoreBluetooth;
@import Foundation;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
@class UIWindow;
@class UIApplication;
@class NSObject;
@class NSURL;
@class NSManagedObjectModel;
@class NSPersistentStoreCoordinator;
@class NSManagedObjectContext;

SWIFT_CLASS("_TtC19behavioralBluetooth11AppDelegate")
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow * __nullable window;
- (BOOL)application:(UIApplication * __nonnull)application didFinishLaunchingWithOptions:(NSDictionary * __nullable)launchOptions;
- (void)applicationWillResignActive:(UIApplication * __nonnull)application;
- (void)applicationDidEnterBackground:(UIApplication * __nonnull)application;
- (void)applicationWillEnterForeground:(UIApplication * __nonnull)application;
- (void)applicationDidBecomeActive:(UIApplication * __nonnull)application;
- (void)applicationWillTerminate:(UIApplication * __nonnull)application;
@property (nonatomic, strong) NSURL * __nonnull applicationDocumentsDirectory;
@property (nonatomic, strong) NSManagedObjectModel * __nonnull managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator * __nonnull persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext * __nonnull managedObjectContext;
- (void)saveContext;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class NSUUID;
@class RemoteBehavioralSerialDevice;
@protocol LocalBehavioralSerialDeviceDelegate;
@class NSTimer;


/// This hopefully provides some info
SWIFT_CLASS("_TtC19behavioralBluetooth27LocalBehavioralSerialDevice")
@interface LocalBehavioralSerialDevice : NSObject
@property (nonatomic, copy) NSDictionary<NSUUID *, RemoteBehavioralSerialDevice *> * __nonnull connectedRemotes;
@property (nonatomic, copy) NSArray<NSUUID *> * __nonnull discoveredDeviceIdArray;
@property (nonatomic, copy) NSArray<NSNumber *> * __nonnull discoveredDeviceRSSIArray;
@property (nonatomic, strong) NSUUID * __nullable hardwareID;
@property (nonatomic, strong) NSUUID * __nullable lastConnectedDevice;
@property (nonatomic) BOOL allowConnectionInBackground;
@property (nonatomic, copy) NSString * __nullable rxSerialBuffer;
@property (nonatomic) BOOL purposefulDisconnect;
@property (nonatomic) NSInteger connectionsLimit;
@property (nonatomic) NSInteger retriesAfterConnectionFail;
@property (nonatomic) NSInteger retriesOnDisconnect;
@property (nonatomic) BOOL verboseOutput;
@property (nonatomic) double searchTimeout;
@property (nonatomic) double reconnectTimerDuration;
@property (nonatomic) double timeBeforeAttemptingReconnectOnConnectionFail;
@property (nonatomic) double timeBeforeAttemptingReconnectOnDisconnect;
@property (nonatomic) NSInteger retryIndexOnFail;
@property (nonatomic) NSInteger retryIndexOnDisconnect;
@property (nonatomic, strong) id <LocalBehavioralSerialDeviceDelegate> __nullable delegate;
@property (nonatomic, strong) NSUUID * __nullable lastConnectedPeripheralNSUUID;
@property (nonatomic) BOOL searchComplete;
@property (nonatomic, strong) NSTimer * __nonnull searchTimeoutTimer;
@property (nonatomic, strong) NSTimer * __nonnull reconnectTimer;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (void)update;
- (void)debugOutput:(NSString * __nonnull)output;

/// ###Set the ID for the desired connected device. The device passed to this function will become the local device's new sought device.  If this will affect autoreconnect scenarios.
///
/// \param device The behavioralBluetooth RemoteSerialDevice desired.
- (void)setConnectedDevice:(NSUUID * __nonnull)nsuuidAsKey device:(RemoteBehavioralSerialDevice * __nonnull)device;

/// <h3>Get the a discovered device's NSUUID using its name.</h3>
/// \param name A string object which should be the name of device.
- (NSUUID * __nullable)getDeviceIdByName:(NSString * __nonnull)name;

/// <h3>Return a RemoteBehavioralSerialDevice object by passing the method the device of interest's NSUUID.  This object is optional and must be unwrapped upon receiving.</h3>
/// \param NSUUID The NSUUID object used to identify the RemoteBehavioralSerialDevice object.
- (RemoteBehavioralSerialDevice * __nullable)getDiscoveredRemoteDeviceByID:(NSUUID * __nonnull)deviceNSUUID;

/// <h3>Return a RemoteBehavioralSerialDevice object by passing the method the device of interest's String name.  This object is optional and must be unwrapped upon receiving.</h3>
/// \param name The string object used to identify the RemoteBehavioralSerialDevice object.
- (RemoteBehavioralSerialDevice * __nullable)getDiscoveredRemoteDeviceByName:(NSString * __nonnull)name;

/// Returns number of discovered devices
///
/// <code>if(bbObject.getNumberOfDiscoveredDevices() > 0){
/// connectDevice()
/// }
/// 
/// </code>
- (NSInteger)getNumberOfDiscoveredDevices;

/// Provides the name of a particular discovered device as a String object.
///
/// <code>println(getDeviceName(myDeviceNSUUID))
/// 
/// </code>
/// <code>Output: myDevice
/// 
/// </code>
- (NSString * __nullable)getDeviceName:(NSUUID * __nonnull)deviceOfInterest;

/// Returns the local device's NSUUID as a String object.
///
/// <code>println(getDeviceUUIDAsString(myDeviceNSUUID)
/// 
/// </code>
/// <code>Output: BE5BA3D0-971C-4418-9ECF-E2D1ABCB66BE
/// 
/// </code>
- (NSString * __nullable)getDeviceUUIDAsString:(NSUUID * __nonnull)deviceOfInterest;

/// ###Sets whether the connected serial device should be dismissed when the app enters the background.
///
/// \param allow Bool
- (void)setBackgroundConnection:(BOOL)enabled;

/// ###Limits the local device as to how many remote devices can be connected at one time.
///
/// \param connectionLimit Integer representining the device connection limit.
- (void)setNumberOfConnectionsAllowed:(NSInteger)limit;

/// ###Controls automatic reconnect behavior.  If this option is set to true, the local device will attempt to automatically reconnect to all remote devices which lose connection.
///
/// \param enabled Should the reconnection be attempted.
///
/// \param tries An integer representing how many attempts should be made to reconnect before foreiting the connection.
///
/// \param timeBetweenTries Double representing how long of a delay is made before another attempt to reconnect is made.
- (void)reconnectOnDisconnectWithTries:(NSInteger)tries timeBetweenTries:(double)timeBetweenTries;

/// ###Controls automatic behavior for reconnecting to a remote device after failing to initially connect.  If this option is set to true, the local device will attempt to automatically reconnect to all remote devices which lose connection.
///
/// \param enabled Should the reconnection be attempted.
///
/// \param tries An integer representing how many attempts should be made to reconnect before foreiting the connection.
///
/// \param timeBetweenTries Double representing how long of a delay is made before another attempt to reconnect is made.
- (void)reconnectOnFailWithTries:(NSInteger)tries timeBetweenTries:(double)timeBetweenTries;

/// ###Attempts to connect to last connected device, without discovery.
- (void)connectToLastConnected;

/// ###Clears all received data for a particular device from its respective local buffer.  Each remote device has its own received buffer contained within the LocalDevice object.
///
/// \param deviceOfInterest NSUUID of device buffer which should be flushed.
- (void)clearRxBuffer:(NSUUID * __nonnull)deviceOfInterest;

/// ###Check to see if any serial data has arrived from device of interest.
///
/// \param deviceOfInterest The NSUUID of the device which you would like to obtain serial data.
- (void)serialDataAvailable:(NSUUID * __nonnull)deviceOfInterest;

/// Returns the device of interest's Radio Signal Strength Indicator (RSSI) as an integer.
///
/// <code>println(getDeviceRSSI(myDeviceNSUUID))
/// 
/// </code>
/// <code>Output: -56
/// 
/// </code>
/// This option is key for NFC imitation.  For example,
///
/// <a href="https://youtu.be/vcrPdhN9MJw"><img src="https://i.ytimg.com/vi/vcrPdhN9MJw/mqdefault.jpg" alt="iPhone Connects Based on Proximity"\></a>
- (NSInteger)getDeviceRSSI:(NSUUID * __nonnull)deviceOfInterest;
- (NSDictionary<NSUUID *, NSNumber *> * __nonnull)getDiscoveredDeviceByRSSIDictionary;
- (void)searchTimerExpire;

/// Returns true if already connected to the deviceOfInterest.
- (BOOL)alreadyConnected:(NSUUID * __nonnull)deviceNSUUID;
- (void)clearDiscoveredDevices;
- (void)clearConnectedDevices;
- (void)printDiscoveredDeviceListInfo;
- (void)printConnectedDevices;
@end


SWIFT_PROTOCOL("_TtP19behavioralBluetooth35LocalBehavioralSerialDeviceDelegate_")
@protocol LocalBehavioralSerialDeviceDelegate
@optional
- (void)searchTimerExpired;
- (void)localDeviceStateChange;
- (void)connectedToDevice;
@end


SWIFT_CLASS("_TtC19behavioralBluetooth15LocalPeripheral")
@interface LocalPeripheral : LocalBehavioralSerialDevice
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC19behavioralBluetooth21LocalBluetoothCentral")
@interface LocalBluetoothCentral : LocalPeripheral
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class CBCentralManager;
@class CBPeripheralManager;
@class RemoteBluetoothLEPeripheral;
@class CBPeripheral;
@class NSNumber;
@class NSError;
@class CBService;
@class CBCharacteristic;


/// ##The Local Bluetooth LE Object
SWIFT_CLASS("_TtC19behavioralBluetooth23LocalBluetoothLECentral")
@interface LocalBluetoothLECentral : LocalPeripheral <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong) CBCentralManager * __nonnull activeCentralManager;
@property (nonatomic, strong) CBPeripheralManager * __nonnull activePeripheralManager;
@property (nonatomic) BOOL discoverAdvertizingDataOnSearch;
@property (nonatomic) NSInteger unknownIndex;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (void)obtainAdvertizingDataOnConnect:(BOOL)enable;

/// <h3>Returns a discovered device's NSUUID.</h3>
/// \param name String representing the device's advertized name.
- (NSUUID * __nullable)getDeviceIdByName:(NSString * __nonnull)name;

/// <h3>Returns a string representing a discovered device's advertized name.</h3>
/// \param deviceOfInterest NSUUID
- (NSString * __nullable)getDeviceName:(NSUUID * __nonnull)deviceOfInterest;

/// <h3>Returns a RemoteBluetoothLEPeripheral object of interest.</h3>
/// \param deviceOfInterest NSUUID
- (RemoteBluetoothLEPeripheral * __nullable)getDiscoveredRemoteDeviceByID:(NSUUID * __nonnull)deviceNSUUID;

/// <h3>Returns a RemoteBluetoothLEPeripheral object of interest.</h3>
/// \param name String representing a RemoteBluetoothLEPeripheral object's advertized name.
- (RemoteBluetoothLEPeripheral * __nullable)getDiscoveredRemoteDeviceByName:(NSString * __nonnull)name;

/// <h3>Method called to initiate the CBCentralManager didScanForPeripherals.  The method is an NSTimeInterval representing how long the CBCentralManager should search before stopping.  The method SearchTimerExpired is called after the interval expires.</h3>
/// \param timeoutSecs An NSTimeInterval representing the search duration.
- (void)search:(NSTimeInterval)timeoutSecs;

/// Requests the Local Device connect to a Bluetooth LE Remote device of interest.  The call will assure a connection to the particular device doesn't exist.  If the connectionsLimit has not been reached.
- (BOOL)connectToDevice:(RemoteBluetoothLEPeripheral * __nonnull)remoteDevice;

/// ###Writes data to a particular RemoteDevice
- (void)writeToDevice:(NSUUID * __nonnull)deviceOfInterest data:(NSString * __nonnull)data;

/// <h3>The CBCentralManager will actively attempt to disconnect from a remote device.</h3>
/// \param deviceOfInterest The NSUUID of device needed to be disconnecting.
- (BOOL)disconnectFromPeripheral:(NSUUID * __nonnull)deviceOfInterest;

/// <h3>Method fired after lost connection with device.  The delay can be changed by calling either reconnectOnFail or reconnectOnDisconnect.</h3>
- (void)reconnectTimerExpired;

/// <h3>Method after search duration has expired.</h3>
- (void)searchTimerExpire;

/// <h3>Updates the the state of the Local Bluetooth LE device.</h3>
- (void)centralManagerDidUpdateState:(CBCentralManager * __nonnull)central;

/// <h3>CoreBluteooth method called when CBCentralManager when scan discovers peripherals.</h3>
- (void)centralManager:(CBCentralManager * __nonnull)central didDiscoverPeripheral:(CBPeripheral * __nonnull)peripheral advertisementData:(NSDictionary<NSString *, id> * __nonnull)advertisementData RSSI:(NSNumber * __nonnull)RSSI;

/// <h3>CoreBluetooth method called when CBCentralManager connects to peripheral.</h3>
- (void)centralManager:(CBCentralManager * __nonnull)central didConnectPeripheral:(CBPeripheral * __nonnull)peripheral;

/// <h3>CoreBluteooth method called when CBCentralManager fails to connect to a peripheral.</h3>
- (void)centralManager:(CBCentralManager * __nonnull)central didFailToConnectPeripheral:(CBPeripheral * __nonnull)peripheral error:(NSError * __nullable)error;

/// <h3>CoreBluteooth method called when CBCentralManager loses connection.</h3>
- (void)centralManager:(CBCentralManager * __nonnull)central didDisconnectPeripheral:(CBPeripheral * __nonnull)peripheral error:(NSError * __nullable)error;

/// <h3>CoreBluteooth method called when CBCentralManager discovers a peripheral's services.</h3>
- (void)peripheral:(CBPeripheral * __nonnull)peripheral didDiscoverServices:(NSError * __nullable)error;

/// <h3>CoreBluteooth method called when CBCentralManager discovers a service's characteristics.</h3>
- (void)peripheral:(CBPeripheral * __nonnull)peripheral didDiscoverCharacteristicsForService:(CBService * __nonnull)service error:(NSError * __nullable)error;

/// <h3>CoreBluteooth method called when CBCentralManager discovers a characteristic's descriptors.</h3>
- (void)peripheral:(CBPeripheral * __nonnull)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic * __nonnull)characteristic error:(NSError * __nullable)error;
@end


SWIFT_CLASS("_TtC19behavioralBluetooth26LocalBluetoothLEPeripheral")
@interface LocalBluetoothLEPeripheral : LocalPeripheral
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC19behavioralBluetooth24LocalBluetoothPeripheral")
@interface LocalBluetoothPeripheral : LocalPeripheral
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC19behavioralBluetooth12LocalCentral")
@interface LocalCentral : LocalBehavioralSerialDevice
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end




/// This hopefully provides some info
SWIFT_CLASS("_TtC19behavioralBluetooth28RemoteBehavioralSerialDevice")
@interface RemoteBehavioralSerialDevice : NSObject
@property (nonatomic, strong) NSUUID * __nullable ID;
- (NSString * __nonnull)idAsString;
- (void)serialDataAvailable:(NSUUID * __nonnull)deviceOfInterest data:(NSString * __nonnull)data;
- (void)setBackgroundConnection:(BOOL)allow;
- (void)getRxBufferChar:(NSUUID * __nonnull)deviceOfInterest;
- (void)clearRxBuffer:(NSUUID * __nonnull)deviceOfInterest;
- (NSString * __nullable)getDeviceName;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC19behavioralBluetooth16RemotePeripheral")
@interface RemotePeripheral : RemoteBehavioralSerialDevice
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC19behavioralBluetooth22RemoteBluetoothCentral")
@interface RemoteBluetoothCentral : RemotePeripheral
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC19behavioralBluetooth24RemoteBluetoothLECentral")
@interface RemoteBluetoothLECentral : RemotePeripheral
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class CBDescriptor;
@class CBUUID;

SWIFT_CLASS("_TtC19behavioralBluetooth27RemoteBluetoothLEPeripheral")
@interface RemoteBluetoothLEPeripheral : RemotePeripheral <CBPeripheralDelegate>
@property (nonatomic, copy) NSString * __nullable dataLocalNameString;
@property (nonatomic, strong) CBPeripheral * __nullable bbPeripheral;
@property (nonatomic, copy) NSArray<CBService *> * __nullable bbServices;
@property (nonatomic, copy) NSArray<NSString *> * __nullable serviceUUIDString;
@property (nonatomic, copy) NSArray<CBCharacteristic *> * __nullable bbCharacteristics;
@property (nonatomic, copy) NSString * __nullable characteristicsString;
@property (nonatomic, copy) NSArray<CBDescriptor *> * __nullable bbDescriptors;
@property (nonatomic, copy) NSString * __nullable advDataLocalName;
@property (nonatomic, copy) NSString * __nullable advDataManufacturerData;
@property (nonatomic, copy) NSString * __nullable advDataServiceData;
@property (nonatomic, copy) NSDictionary<CBUUID *, NSString *> * __nullable advDataServiceUUIDs;
@property (nonatomic, copy) NSArray<NSString *> * __nullable advDataOverflowServiceUUIDsKey;
@property (nonatomic, copy) NSString * __nullable advDataIsConnectable;
@property (nonatomic, copy) NSArray<NSString *> * __nullable advSolicitedServiceUUID;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC19behavioralBluetooth25RemoteBluetoothPeripheral")
@interface RemoteBluetoothPeripheral : RemotePeripheral
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC19behavioralBluetooth13RemoteCentral")
@interface RemoteCentral : RemoteBehavioralSerialDevice
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


@class NSBundle;
@class NSCoder;

SWIFT_CLASS("_TtC19behavioralBluetooth14ViewController")
@interface ViewController : UIViewController <LocalBehavioralSerialDeviceDelegate>
@property (nonatomic, strong) LocalBluetoothLECentral * __nonnull myLocal;
@property (nonatomic, strong) RemoteBluetoothLEPeripheral * __nonnull myRemote;
- (void)viewDidLoad;
- (void)didReceiveMemoryWarning;
- (void)searchTimerExpired;
- (void)localDeviceStateChange;
- (nonnull instancetype)initWithNibName:(NSString * __nullable)nibNameOrNil bundle:(NSBundle * __nullable)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * __nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

#pragma clang diagnostic pop

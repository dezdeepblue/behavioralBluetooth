//
//  deviceState.swift
//  behavioralBluetooth
//
//  Created by Casey Brittain on 1/20/16.
//  Copyright © 2016 Honeysuckle Hardware. All rights reserved.
//

import Foundation

public class DeviceState {
    
    public var hardware = hardwareStates.unknown
    public var connection = connectionStates.unknown
    public var search = searchStates.unknown
    
    public enum hardwareStates: Int {
        case unknown = 0,
        off,
        on,
        resetting,
        unsupported,
        unauthorized
    }
    
    public enum connectionStates: Int {
        case unknown = 0,
        connected,
        disconnected,
        failedToConnect,
        purposefulDisconnect,
        lostConnection,
        connecting
    }
    
    public enum searchStates: Int{
        case unknown = 0,
        scanning,
        idle,
        idleWithDiscoveredDevices
    }
}


//
//  deviceState.swift
//  behavioralBluetooth
//
//  Created by Casey Brittain on 1/20/16.
//  Copyright © 2016 Honeysuckle Hardware. All rights reserved.
//

import Foundation

public class DeviceState {
    
    var state = states.unknown
    
    public enum states: Int {
        case unknown = 0,
        off,
        on,
        resetting,
        unsupported,
        unauthorized,
        connected,
        disconnected,
        failedToConnect,
        purposefulDisconnect,
        lostConnection,
        connecting,
        scanning,
        idle,
        idleWithDiscoveredDevices
    }
}


//
//  deviceState.swift
//  behavioralBluetooth
//
//  Created by Casey Brittain on 1/20/16.
//  Copyright © 2016 Honeysuckle Hardware. All rights reserved.
//

import Foundation
import CoreBluetooth

class DeviceState {
    
    enum connectionStatuses: Int {
        case disconnected = 1
        
    }
    var connections: Int?
    var connectionStatus: connectionStatuses?
}
//
//  DeviceModel.swift
//  iCoin-Wallet
//
//  Created by Iottive on 02/05/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceModel: NSObject {
    
    public var deviceName : String!
    public var peripheral : CBPeripheral!
    public var RSSI : NSNumber!
    
    init(_ deviceName : String, _ peripheral : CBPeripheral, _ RSSI : NSNumber) {
        super.init()
        self.deviceName = deviceName.replacingOccurrences(of: ":)", with: "")
        self.peripheral = peripheral
        self.RSSI = RSSI
    }
    
    public func printObject() -> String {
        return "DeviceName   :\(deviceName) \nPeripheralName    :\(String(describing: peripheral.name))"
    }
}

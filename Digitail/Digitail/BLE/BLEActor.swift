//
//  BLEActor.swift
//  iCoin-Wallet
//
//  Created by Iottive on 02/05/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
import CoreBluetooth


// CBCenterManager Notification
let kBluetoothStateUpdate = "BluetoothStateUpdate"
let kScanResultPeripheralFound = "ScanResultPeripheralFound"
let kPeripheralStateChanged = "PeripheralStateChanged"
let kPeripheralFound = "PeripheralFound"
let kFailedToConnectPeripheral = "FailedToConnectPeripheral"
let kDeviceDisconnected = "DeviceDisconnected"

//BLE Actor
let kDeviceIsReady = "DeviceIsReady"
let kDeviceDidSendNotification = "DeviceDidSendNotification"
let kDeviceDidUpdateProperty = "DeviceDidUpdateProperty"
let kDeviceDidPerformCommand = "DeviceDidPerformCommand"
let kDeviceFailedToPerformCommand = "DeviceFailedToPerformCommand"
let kDeviceWillPerformCommand  = "DeviceWillPerformCommand"
let kNewDeviceFound = "NewDeviceFound"
let kAddingCommandInQueue = "AddingCommandInQueue"
let kDeviceModeRefreshNotification = "DeviceModeUpdateNotification"

// CBPeripheralManager Notification
let kPeripheralDidDiscoverServices = "PeripheralDidDiscoverServices"
let kPeripheralDidDiscoverCharacteristicsForService = "PeripheralDidDiscoverCharacteristicsForService"
let kPeripheralDidUpdateValueForCharacteristic = "PeripheralDidUpdateValueForCharacteristic"
let kPeripheralDidWriteValueForCharacteristic = "PeripheralDidWriteValueForCharacteristic"
let kPeripheralFailedToWriteValueForCharacteristic = "PeripheralFailedToWriteValueForCharacteristic"
let kPeripheralDidUpdateRSSI = "PeripheralDidUpdateRSSI"
let kPeripheralUpdateRSSI = "PeripheralUpdateRSSI"
let kPeripheralFailedToDiscoverCharacteristicsForService = "PeripheralFailedToDiscoverCharacteristicsForService"
let kPeripheralFailedToDiscoverServices = "PeripheralFailedToDiscoverServices"
let kPeripheralFailedToUpdateValueForCharacteristic = "PeripheralFailedToUpdateValueForCharacteristic"
let kCheckHeartRateDevice = "CheckHeartRateDevice"

let kDevicesStorageKey = "WalletDevicesStorage"
let kServiceMeta = "serviceMeta.plist"
let kCommandMeta = "commandMeta.plist"

let kServiceMetaEarGear = "serviceMetaEarGear.plist"
let kCommandMetaEarGear = "commandMetaEarGear.plist"

let kServiceMetaMitail = "serviceMetaMitail.plist"
let kServiceMetaFlutter = "serviceMetaFlutter.plist"

enum kValueTransformDirection : Int {
    case In = 0
    case Out
}

enum BLEDeviceType {
    case digitail
    case mitail
    case eg2
    case flutter
}

extension CBPeripheral {
    func characteristic(withPath path: String)  -> CBCharacteristic? {
        let pathUUIDs: [CBUUID] = CBUUIDsFromNSStrings(strings: path.components(separatedBy: Constants.kCBPathDelimiter))
        if (self.services != nil) {
            for findService : CBService in (self.services)! {
                if pathUUIDs.count == 2  && (findService.characteristics != nil) && findService.uuid == pathUUIDs[0] {
                    for findChar : CBCharacteristic in findService.characteristics! {
                        if findChar.uuid == pathUUIDs[1] {
                          //  print("characteristic :: \(findService.uuid.uuidString).\(findChar.uuid.uuidString)")
                          //  NSLog("characteristic :: \(findService.uuid.uuidString).\(findChar.uuid.uuidString)")
                            return findChar
                        }
                    }
                }
            }
        }
        return nil
    }
}

extension CBCharacteristic {
    func path() -> String {
        return  (NSStringsFromCBUUIDs(cbUUIDs: [service!.uuid, uuid]) as NSArray).componentsJoined(by: Constants.kCBPathDelimiter)
    }
    
    var stringValue: String? {
        return String.init(data: self.value!, encoding: String.Encoding.utf8)
    }
    
    var dataValue: Data? {
        return value!
    }
    
    func valueWithType(withType type: String) -> Any {
        let selectorStr: String = "\(type)Value"
        let selector: Selector = NSSelectorFromString(selectorStr)
        return perform(selector)
    }
}

// PeripheralActor responsible for discovering Services, Characteristics, Write, Read operations
class PeripheralActor: NSObject,CBPeripheralDelegate {
    var peripheral: CBPeripheral?
    
    init(peripheral aPeripheral: CBPeripheral) {
        super.init()
        self.peripheral = aPeripheral
        self.peripheral?.delegate = self
    }
    
    func discoverServices(_ services: [Any]) {
        NSLog("discovering services: \(services) of peripheral: \(String(describing: self.peripheral))")
        self.peripheral?.discoverServices(services as? [CBUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            NSLog("PeripheralFailedToDiscoverServices \(String(describing: error?.localizedDescription))")
            PostNoteWithInfo(kPeripheralFailedToDiscoverServices, peripheral, ["error": error!])
            return
        }
        NSLog("didDiscoverServices>> \(String(describing: self.peripheral?.services!))")
        NSLog("________________________DID DISCOVER SERVICES________________________")
        PostNoteWithInfo(kPeripheralDidDiscoverServices, peripheral, ["services": peripheral.services!])
    }
    
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {
        NSLog("discovering characteristics:\(String(describing: characteristicUUIDs)) of service: \(service) of peripheral: \(String(describing: peripheral))")
        self.peripheral?.discoverCharacteristics(characteristicUUIDs, for: service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            PostNoteWithInfo(kPeripheralFailedToDiscoverCharacteristicsForService, peripheral, ["error": error!, "service": service])
            return
        }
        PostNoteWithInfo(kPeripheralDidDiscoverCharacteristicsForService, peripheral, ["service": service, "characteristics": service.characteristics!])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            PostNoteWithInfo(kPeripheralFailedToUpdateValueForCharacteristic, peripheral, ["error": error!, "characteristic": characteristic])
            return
        }
        PostNoteWithInfo(kPeripheralDidUpdateValueForCharacteristic, peripheral, ["characteristic": characteristic, "service": characteristic.service, "value": characteristic.value!])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            PostNoteWithInfo(kPeripheralFailedToWriteValueForCharacteristic, peripheral, ["characteristic": characteristic, "error": error!])
            return
        }
        let userInfo: NSMutableDictionary
        if characteristic.value != nil {
            userInfo = ["characteristic": characteristic, "value": characteristic.value!]
        }else{
            userInfo = ["characteristic": characteristic]
        }
        PostNoteWithInfo(kPeripheralDidWriteValueForCharacteristic, peripheral, userInfo)
    }
    
    @objc func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        PostNoteBLE(kPeripheralUpdateRSSI, peripheral)
    }
    
    func readValue(forCharacteristicPath path: String) {
        let ch: CBCharacteristic? = self.peripheral?.characteristic(withPath: path.uppercased())
        if nil == ch {
            NSLog("WARN: could not find characteristic with path \(path) for peripheral \(String(describing: peripheral))")
            return
        }
        NSLog("characteristic \(path) properties: \(String(describing: ch?.properties))")
        if ((ch?.properties.rawValue)! & CBCharacteristicProperties.read.rawValue) == 0 {
            NSLog("characteristic \(path) properties: \(String(describing: ch?.properties))")
        }
        self.peripheral?.readValue(for: ch!)
    }
    
    func write(_ data: Data, forCharacteristicPath path: String) {
        let ch: CBCharacteristic? = self.peripheral?.characteristic(withPath: path.uppercased())
        if nil == ch {
            NSLog("WARN: could not find characteristic with path \(path) for peripheral \(String(describing: peripheral))")
            return
        }
        //print("characteristic: \(String(describing: ch?.uuid)), \(path), properties: \(String(describing: ch?.properties))")
       // NSLog("characteristic: \(ch?.uuid), \(path), properties: \(String(describing: ch?.properties))")
        
        if ((ch?.properties.rawValue)! & CBCharacteristicProperties.write.rawValue) != 0  || ((ch?.properties.rawValue)! & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0  {
            //print("writing value: \(data) into characteristic: \(String(describing: ch?.uuid))")
            NSLog("writing value: \(data.hexString) into characteristic: \(String(describing: ch?.description))")
            if ((ch?.properties.rawValue)! & CBCharacteristicProperties.write.rawValue) == 0 {
                NSLog("WARN: this characteristic does not support writes with response")
            }
            if ((ch?.properties.rawValue)! & CBCharacteristicProperties.write.rawValue) != 0 {
                self.peripheral?.writeValue(data, for: ch!, type: CBCharacteristicWriteType.withResponse)
            }else{
                self.peripheral?.writeValue(data, for: ch!, type: CBCharacteristicWriteType.withoutResponse)
            }
            return
        }
        else {
            //print("WARN: characteristic \(String(describing: ch?.uuid)) does not support writes")
          //  NSLog("WARN: characteristic \(String(describing: ch?.uuid)) does not support writes")
        }
    }
}

// CentralManager responsible for discovering devices, connection operations.
class CentralManagerActor: NSObject,CBCentralManagerDelegate {
    var centralManager: CBCentralManager?
    var serviceUUIDs = [CBUUID]()
    var peripherals = NSMutableArray()
    
    init(serviceUUIDs aServiceUUIDs:[CBUUID]) {
        super.init()
        self.serviceUUIDs = aServiceUUIDs
        self.peripherals = NSMutableArray()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.centralManager?.delegate = self
    }
    
    func add(_ peripheral: CBPeripheral) {
        let idx: Int = (peripherals as NSArray).index(of: peripheral)
        if NSNotFound == idx {
            PostNoteBLE(kPeripheralFound, peripheral)
            self.peripherals.insert(peripheral, at: 0)
        }
        if peripheral.state != .connected {
            NSLog("trying to connect to peripheral \(peripheral)")
            self.centralManager?.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,CBConnectPeripheralOptionNotifyOnConnectionKey:true])
        }
        else {
            NSLog("addPeripheral>>\(peripheral)")
            PostNoteBLE(kPeripheralStateChanged, peripheral)
        }
    }
    
    func retrievePeripherals() {
        NSLog("scanning for peripherals with service UUIDs \(serviceUUIDs)")
//        AppDelegate_.deviceActors.forEach { (bleActor) in
//            if bleActor.isConnected() {
//                self.centralManager?.cancelPeripheralConnection((bleActor.peripheralActor?.peripheral)!)
//            }
//        }
        
        let options: [String: Any] = [ CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber.init(value: false)]
        centralManager?.scanForPeripherals(withServices: self.serviceUUIDs, options: options)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        NSLog("BT Update state \(central.state.rawValue)")
        
        PostNoteBLE(kBluetoothStateUpdate, central)
        if #available(iOS 10.0, *) {
            if central.state == CBManagerState.poweredOn  {
                NSLog("bluetooth state on")
            }else if central.state == CBManagerState.poweredOff {
                NSLog("bluetooth state off")
            }
        } else {
        }
    }
    
    func centralManager(_ central: CBCentralManager, didRetrieveConnectedPeripherals peripherals: [CBPeripheral]) {
        NSLog("didRetrieveConnectedPeripherals \(peripherals)")
    }
    
    func centralManager(_ central: CBCentralManager, didRetrievePeripherals peripherals: [CBPeripheral]) {
        NSLog("didRetrievePeripherals \(peripherals)")
        self.peripherals .forEach { (peripheral) in
            add(peripheral as! CBPeripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if advertisementData["kCBAdvDataLocalName"] != nil {
            let deviceName = advertisementData["kCBAdvDataLocalName"] as! String
            if deviceName.contains("(!)Tail1") ||  deviceName.lowercased().contains("eargear") || deviceName.lowercased().contains("mitail") || deviceName.lowercased().contains("eg2") || deviceName.lowercased().contains("flutter") {
                NSLog(deviceName)
                NSLog("------------------------------------------------------------------")
                NSLog("\ndidDiscover {peripheral : \(peripheral) advertisementData: \(advertisementData), Rssi : \(RSSI)}")
                PostNoteBLE(kScanResultPeripheralFound, ["peripheral": peripheral, "advertisementData": advertisementData, "Rssi" : RSSI])
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NSLog("centralManager >> didConnectPeripheral : \(peripheral)")
        add(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NSLog("centralManager >> didFailToConnect : \(peripheral) Error : \(error.debugDescription)")
        PostNoteWithInfo(kFailedToConnectPeripheral, peripheral, ["error": error!])
    }
    
        func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
            NSLog("centralManager >> didFailToConnect : \(peripheral), Error: \(error.debugDescription)}")
            PostNoteBLE(kPeripheralStateChanged, peripheral)
            //reconnectionDevice()
        }
    
    func reconnectionDevice() {
        let deviceActor: BLEActor? = getDefaultActor()
        reconnectWithActor(deviceActor!)
    }
    
    func didEnterBackgroundNotification(_ notification: Notification) {
        NSLog("Entered background notification called.")
        centralManager?.stopScan()
    }
    func didEnterForegroundNotification(_ notification: Notification) {
        NSLog("Entered foreground notification called.")
        retrievePeripherals()
    }
    
}

// BLEActor responible for managing In/Out commands with hardware device, managing command Queues.
class BLEActor: NSObject {
    
    var peripheralActor: PeripheralActor!
    var state = NSMutableDictionary()
    var propertiesToCharacteristics = NSMutableDictionary()
    var servicesMeta = NSDictionary()
    var commandsMeta = NSDictionary()
    var commandInProgress = NSMutableDictionary()
    var commandTimeoutTimer: Timer?
    var disconnectTimer: Timer?
    var commandsQueue = NSMutableArray()
    var didReadCharacteristicsCounter: Int = 0
    var queue: OperationQueue?
    var isDeviceIsReady: Bool = false
    var bleDeviceType: BLEDeviceType = .digitail
//    var isMitail: Bool = false
//    var isEG2: Bool = false
//    var isFlutter: Bool = false
    var maxMTU: Int = 20
    
    init(deviceState aState:NSMutableDictionary, servicesMeta aServicesMeta:NSDictionary, operationsMeta aOperationsMeta:NSDictionary) {
        super.init()
        self.state = aState
        self.servicesMeta = aServicesMeta
        self.commandsMeta = aOperationsMeta
        self.commandsQueue = NSMutableArray()
        self.queue = OperationQueue()
    }
    
    
    func isActor(_ peripheral: CBPeripheral) -> Bool {
        if (self.peripheralActor?.peripheral != nil) {
            return self.peripheralActor?.peripheral == peripheral || self.peripheralActor?.peripheral!.identifier == peripheral.identifier
        }
        let peripheralUUID: String = peripheral.identifier.uuidString
        return ((state[Constants.kPeripheralUUIDKey] as? String) == peripheralUUID)
    }
    
    //To check BLE Actor is connected or not
    func isConnected() -> Bool {
        if (self.peripheralActor?.peripheral != nil) {
            return self.peripheralActor!.peripheral!.state == .connected
        } else {
            return false;
        }
        
    }
    
    func descriptionDetail() -> String {
        return "\(super.description). Peripheral Actor: \(String(describing: peripheralActor)), State: \(state)"
    }
    
    func setPeripheral(_ peripheral: CBPeripheral) {
        if (self.peripheralActor != nil) {
            if self.peripheralActor?.peripheral == peripheral {
                return
            }
            NSLog("setPeripheral")
            UnregisterFromNotesFromObject(self,peripheralActor!)
        }
        NSLog("________________________SET PERIPHERAL________________________")
        
        peripheralActor = PeripheralActor(peripheral: peripheral)
        RegisterForNoteWithObject(#selector(BLEActor.PeripheralStateChanged(_:)),kPeripheralStateChanged, self, self.peripheralActor?.peripheral! as Any)
        RegisterForNoteWithObject(#selector(BLEActor.PeripheralDidDiscoverServices(_:)),kPeripheralDidDiscoverServices, self, self.peripheralActor?.peripheral! as Any)
        RegisterForNoteWithObject(#selector(BLEActor.PeripheralDidDiscoverCharacteristicsForService(_:)),kPeripheralDidDiscoverCharacteristicsForService, self, self.peripheralActor?.peripheral! as Any)
        RegisterForNoteWithObject(#selector(BLEActor.PeripheralDidUpdateValue(forCharacteristic:)),kPeripheralDidUpdateValueForCharacteristic, self, self.peripheralActor?.peripheral! as Any)
        RegisterForNoteWithObject(#selector(BLEActor.PeripheralDidWriteValueForCharacteristic(_:)),kPeripheralDidWriteValueForCharacteristic, self, self.peripheralActor?.peripheral! as Any)
        //AppDelegate_.RegisterForNoteFromObject(Constants.kPeripheralFailedToWriteValueForCharacteristic, self, self.peripheralActor?.peripheral! as Any)
        //        RegisterForNoteFromObject(#selector(BLEActor.PeripheralDi),kPeripheralDidUpdateRSSI, self, self.peripheralActor?.peripheral! as Any)
        
        self.state[Constants.kPeripheralUUIDKey] =  peripheral.identifier.uuidString
        
        if (peripheral.name != nil) {
            
            if peripheral.name!.lowercased().contains("mitail") {
                state[Constants.kDeviceName] = "MITAIL"
            } else if peripheral.name!.contains("(!)Tail1") {
                state[Constants.kDeviceName] = "DIGITAIL"
            } else if peripheral.name!.lowercased().contains("eg2") {
                state[Constants.kDeviceName] = "EarGear v2"
            } else if peripheral.name!.lowercased().contains("eargear") {
                state[Constants.kDeviceName] = "EARGEAR"
            } else if peripheral.name!.lowercased().contains("flutter") {
                state[Constants.kDeviceName] = "FLUTTER"
            }
        }
        if peripheral.state == .connected {
            peripheralActor?.discoverServices(CBUUIDsFromNSStrings(strings:Array(self.servicesMeta.allKeys) as! [String]))
        }
    }
    
        @objc func PeripheralDidDiscoverServices(_ note: Notification) {
            NSLog("________________________DISCOVER SERVICES________________________")
            
            let services: [CBService] = NSMutableDictionary.init(dictionary: note.userInfo!)["services"] as! [CBService]
            self.didReadCharacteristicsCounter = 0
            NSLog("services array \(services)")
            
            services.forEach { (s) in
                var UUID: String = NSStringFromCBUUID(s.uuid)
                if (UUID.count) > 15 {
                    UUID = String(format:"%@-%@-%@-%@-%@",UUID.substring(from: 0, length: 8),UUID.substring(from: 8, length: 4),UUID.substring(from: 12, length: 4),UUID.substring(from: 16, length: 4),UUID.substring(from: 20, length: 12))
                    NSLog("service UUID 128bit \(UUID)")
                }
                let properties: [String: Any] = self.servicesMeta.value(forKey:UUID.lowercased()) as! [String : Any]
                if !properties.isEmpty {
                    self.peripheralActor?.discoverCharacteristics(CBUUIDsFromNSStrings(strings: Array(properties.keys)), for: s)
                    didReadCharacteristicsCounter += 1
                }
            }
        }
    
    @objc func PeripheralDidDiscoverCharacteristicsForService(_ note: Notification) {
        NSLog("________________________DISCOVER CHARACTERISTICS________________________")
        
        // MARK: make sure all characteristics are discovered for all peripheral services
        let service: CBService = NSMutableDictionary.init(dictionary: note.userInfo!)["service"] as! CBService
        let characteristics: [CBCharacteristic] = NSMutableDictionary.init(dictionary: note.userInfo!)["characteristics"] as! [CBCharacteristic]
        
        characteristics.forEach { (c) in
            //print("service UUID: \(service.uuid.uuidString) , characteristics: UUID:\(c.uuid.uuidString) properties: \(c.properties))")
          //  NSLog("service UUID: \(service.uuid.uuidString) , characteristics: UUID:\(c.uuid.uuidString) properties: \(c.properties))")
        }
        
        var serviceUUIDStr: String = NSStringFromCBUUID(service.uuid)
        if (serviceUUIDStr.count) > 15 {
            serviceUUIDStr = String(format:"%@-%@-%@-%@-%@",serviceUUIDStr.substring(from: 0, length: 8),serviceUUIDStr.substring(from: 8, length: 4),serviceUUIDStr.substring(from: 12, length: 4),serviceUUIDStr.substring(from: 16, length: 4),serviceUUIDStr.substring(from: 20, length: 12))
            NSLog("service UUID 128bit \(serviceUUIDStr)")
        }
        let serviceMeta: [String: NSMutableDictionary] = servicesMeta[serviceUUIDStr.lowercased()] as! [String : NSMutableDictionary]
        NSLog("service meta: %@",serviceMeta)
        
        if serviceMeta.keys.count == 0 {
            return;
        }
        serviceMeta.forEach { (_ characteristicUUIDStr:String, _ meta: NSDictionary) in
            let characteristicPath: String = CharacteristicPathWithArray([serviceUUIDStr, characteristicUUIDStr])
            if meta["isObservable"] != nil {
                // FIXME: move to peripheral actor
                let characteristic: CBCharacteristic? = peripheralActor?.peripheral?.characteristic(withPath: characteristicPath)
                if nil != characteristic {
                    NSLog("observing characteristic with path \(characteristicPath), properties: \(String(describing: characteristic?.properties))")
                    if (CBCharacteristicProperties.notify.rawValue & (characteristic?.properties.rawValue)!) != 0 {
                        peripheralActor?.peripheral?.setNotifyValue(true, for: characteristic!)
                    }
                    else {
                        NSLog("WARN: characteristic with path \(characteristicPath) does not support notifications")
                    }
                }
                else {
                    NSLog("WARN: could not find characteristic with path \(characteristicPath) to observe")
                }
            }
        }
        didReadCharacteristicsCounter -= 1
        if didReadCharacteristicsCounter == 0 {
            NSLog("________________________DID DISCOVER CHARACTERISTICS________________________")
            NSLog("________________________DEVICE IS READY_________________________")
            
            self.isDeviceIsReady = true
            PostNoteWithInfo(kDeviceIsReady, self, state)
            self.maxMTU = (self.peripheralActor.peripheral?.maximumWriteValueLength(for: .withResponse))!
            self.commandInProgress.removeAllObjects()
            processNextCommandInQueue()
        }
    }
    
    
    func propertyMeta(for characteristic: CBCharacteristic) -> [AnyHashable: Any]? {
        var characteristicPath: String = characteristic.path()
        let components: [String] = characteristicPath.components(separatedBy:Constants.kCBPathDelimiter)
        if components.count > 1 {
            var serviceUUIDStr: String = components[0]
            var charactStr: String = components[1]
            if (serviceUUIDStr.count) > 15 {
                serviceUUIDStr = "\((serviceUUIDStr as NSString).substring(with: NSRange(location: 0, length: 8)))-\((serviceUUIDStr as NSString).substring(with: NSRange(location: 8, length: 4)))-\((serviceUUIDStr as NSString).substring(with: NSRange(location: 12, length: 4)))-\((serviceUUIDStr as NSString).substring(with: NSRange(location: 16, length: 4)))-\((serviceUUIDStr as NSString).substring(with: NSRange(location: 20, length: 12)))"
                NSLog("service UUID 128bit \(serviceUUIDStr)")
            }
            if (charactStr.count) > 15 {
                charactStr = "\((charactStr as NSString).substring(with: NSRange(location: 0, length: 8)))-\((charactStr as NSString).substring(with: NSRange(location: 8, length: 4)))-\((charactStr as NSString).substring(with: NSRange(location: 12, length: 4)))-\((charactStr as NSString).substring(with: NSRange(location: 16, length: 4)))-\((charactStr as NSString).substring(with: NSRange(location: 20, length: 12)))"
                NSLog("service UUID 128bit \(charactStr)")
            }
            characteristicPath = "\(serviceUUIDStr).\(charactStr)"
        }
        let propertyMetaValue = servicesMeta.value(forKeyPath: characteristicPath.lowercased()) as! [String : Any]
        guard !propertyMetaValue.isEmpty else {
            NSLog("propertyMetaForCharacteristic>> WARN: no property with path \(characteristicPath) in services metadata: \(servicesMeta)")
            return nil
        }
        return propertyMetaValue
    }
    
    func propertyName(for characteristic: CBCharacteristic) -> String {
        return propertyMeta(for: characteristic)!["name"] as! String
    }
    
    func stopCommands() {
        NSLog("stopping all activity scheduled: \(commandsQueue) and in progress: \(commandInProgress)")
        
        self.commandTimeoutTimer?.invalidate()
        self.commandTimeoutTimer = nil
        self.commandInProgress .removeAllObjects()
        commandsQueue = NSMutableArray()
    }
    
    @objc func PeripheralStateChanged(_ note: Notification) {
        let peripheral: CBPeripheral? = (note.object as! CBPeripheral)
        if peripheral?.state == .connected {
            if self.state[Constants.kPeripheralUUIDKey] != nil && ((peripheral?.identifier) != nil) {
                state[Constants.kPeripheralUUIDKey] = peripheral?.identifier.uuidString
            }
            NSLog("peripheralStateChanged >> discoverServices")
            peripheralActor?.discoverServices(CBUUIDsFromNSStrings(strings: servicesMeta.allKeys as! [String]))
        }
        else {
            stopCommands()
            PostNoteBLE(kDeviceDisconnected, self)
        }
    }
    
    @objc func PropertyUpdated(_ note: Notification) {
        let userInfo = NSMutableDictionary.init(dictionary: note.userInfo!)
        let characteristic: CBCharacteristic? =  userInfo["characteristic"] as? CBCharacteristic
        var characteristicPath: String? = characteristic?.path()
        let components: [String] = (characteristicPath?.components(separatedBy: Constants.kCBPathDelimiter))!
        if (components.count) > 1 {
            
            var serviceUUIDStr: String = components[0]
            var charactStr: String = components[1]
            
            if (serviceUUIDStr.count) > 15 {
                serviceUUIDStr = "\((serviceUUIDStr as NSString).substring(with: NSRange(location: 0, length: 8)))-\((serviceUUIDStr as NSString).substring(with: NSRange(location: 8, length: 4)))-\((serviceUUIDStr as NSString).substring(with: NSRange(location: 12, length: 4)))-\((serviceUUIDStr as NSString).substring(with: NSRange(location: 16, length: 4)))-\((serviceUUIDStr as NSString).substring(with: NSRange(location: 20, length: 12)))"
                NSLog("service UUID 128bit \(serviceUUIDStr)")
            }
            if (charactStr.count) > 15 {
                charactStr = "\((charactStr as NSString).substring(with: NSRange(location: 0, length: 8)))-\((charactStr as NSString).substring(with: NSRange(location: 8, length: 4)))-\((charactStr as NSString).substring(with: NSRange(location: 12, length: 4)))-\((charactStr as NSString).substring(with: NSRange(location: 16, length: 4)))-\((charactStr as NSString).substring(with: NSRange(location: 20, length: 12)))"
                NSLog("service UUID 128bit \(charactStr)")
            }
            characteristicPath = "\(serviceUUIDStr).\(charactStr)"
        }
        let propertyMetaValue = servicesMeta.value(forKeyPath: characteristicPath!.lowercased()) as! NSDictionary
        if propertyMetaValue.allKeys.count == 0 {
            NSLog("propertyUpdated>> WARN: no property with path \(String(describing: characteristicPath)) in services metadata: \(servicesMeta)")
            return
        }
        
        let name = propertyMetaValue.value(forKey: "name") as! String
        var val: Any
        if (propertyMetaValue.value(forKey: "type") as! NSString).isEqual(to: "data") {
            val = userInfo["value"] as! Data
        }
        else if ((propertyMetaValue.value(forKey: "type") as! NSString).isEqual(to: "string")) {
            let stringData = NSString.init(data: userInfo.value(forKey: "value") as! Data, encoding:String.Encoding.utf8.rawValue)
            val = stringData!
        }
        else {
            val = characteristic?.valueWithType(withType: (propertyMetaValue.value(forKey:"type") as! String)) as Any
        }
        if (val == nil)  {
            val = NSNull()
        }
        var oldValue: Any? = state[name]
        if nil == oldValue {
            oldValue = NSNull()
        }
        NSLog("{propertyMeta: \(propertyMetaValue), value: \(val), oldValue: \(String(describing: oldValue))}")
        
        if val == nil {
            return
        }
        state[name] = val
        val = transformValue(val, ofProperty: name, direction: kValueTransformDirection.In)
        PostNoteWithInfo(kDeviceDidUpdateProperty, self, ["name": name, "value": val, "oldValue": oldValue!])
        NSLog("Property Updated -- name")
        
        if isCommand(inProgressPerformingOperation: Constants.kPropertyOperationRead, onProperty: name) {
            processReadCommandOperation(withValue: val)
        }
        else if isCommand(inProgressPerformingOperation: Constants.kPropertyOperationReadWait, onProperty: name) {
            NSLog("Property Updated -- \(name)")
            processReadWaitCommandOperation(withValue: val)
        }
        else {
            NSLog("DID GET NOTIFICATION FROM DEVICE")
            PostNoteWithInfo(kDeviceDidSendNotification, self, ["name": name, "value": val])
        }
    }
    
    func processReadCommandOperation(withValue val: Any) {
        let comm: NSMutableDictionary = self.commandInProgress
        let op: NSMutableDictionary = comm["propertyOperationInProgress"] as! NSMutableDictionary
        op["readValue"] = val
        continueCommandInProgress()
    }
    
    func processReadWaitCommandOperation(withValue val: Any) {
        
    }
    
    @objc func PeripheralDidUpdateValue(forCharacteristic note: Notification) {
        NSLog("*********property updated********* \(note)")
        perform(#selector(self.PropertyUpdated(_:)), with: note, afterDelay: 0.2)
    }
    
    func isCommand(inProgressPerformingOperation operation: String, onProperty property: String) -> Bool {
        if self.commandInProgress.allKeys.count == 0 {
            return false
        }
        let propertyOperationInProgress: NSDictionary = self.commandInProgress.value(forKey: "propertyOperationInProgress") as! NSDictionary
        if propertyOperationInProgress.value(forKey: "operation") != nil {
            if propertyOperationInProgress.value(forKey: "name") != nil {
                return true
            }
        }
        return false
    }
    
    func commandFailedWithError(_ err: Error?) {
        let command: NSDictionary = self.commandInProgress
        self.commandTimeoutTimer?.invalidate()
        self.commandTimeoutTimer = nil
        PostNoteWithInfo(kDeviceFailedToPerformCommand, self, ["name": command["name"]!, "command": command, "error": err!])
        self.commandInProgress.removeAllObjects()
        processNextCommandInQueue()
    }
    
    func processNextCommandInQueue() {
        NSLog("queue: \(commandsQueue)")
        
        if self.commandsQueue.count != 0 {
            let nextCommand = NSMutableDictionary.init(dictionary: self.commandsQueue.shift()! as! NSDictionary)
            NSLog("next command: \(nextCommand)")
            performCommand((nextCommand["command"] as? String)!, withParams: (nextCommand["params"] as! NSMutableDictionary), metaValue: nextCommand["meta"] as! NSDictionary)
        }
    }
    
    func continueCommandInProgress()
    {
        commandTimeoutTimer?.invalidate()
        let command = self.commandInProgress
        NSLog("Command :- \(command)")
        
        if let currentPropertyOperation = command.value(forKey: "propertyOperationInProgress") as? NSDictionary {
            let arrayOfCompletedOperations = command.value(forKey: "completedPropertyOperations") as! NSMutableArray
            arrayOfCompletedOperations.push(currentPropertyOperation)
            command.setValue(arrayOfCompletedOperations, forKey: "completedPropertyOperations")
        }
        let nextPropertyOperation = (self.commandInProgress["propertyOperations"] as! NSMutableArray).shift()
        if nextPropertyOperation == nil {
            // Command complete from client side
            self.commandTimeoutTimer?.invalidate()
            self.commandTimeoutTimer = nil
            command.setValue(NSMutableDictionary(), forKey:"propertyOperationInProgress")
            let completedCommand = NSMutableDictionary()
            completedCommand.addEntries(from: command as! [AnyHashable : Any])
            PostNoteWithInfo("DeviceDidPerformCommand", self, completedCommand)
            self.commandInProgress.removeAllObjects()
            processNextCommandInQueue()
            return
        }
        
        command .setValue(nextPropertyOperation, forKey: "propertyOperationInProgress")
        commandTimeoutTimer = Timer.scheduledTimer(timeInterval: Constants.kCommandPropertySetTimeout, target: self, selector: #selector(self.commandTimeout(_:)), userInfo: nil, repeats: false)
        
        guard (nextPropertyOperation as? NSMutableDictionary) != nil else {
            NSLog("NextOperation is null \(String(describing: nextPropertyOperation))")
            return
        }
        
        let nextOperation = NSMutableDictionary.init(dictionary: nextPropertyOperation as! NSDictionary)
        let strOperationType = nextOperation .value(forKey: "operation") as! NSString
        if (NSString.init(string:Constants.kPropertyOperationWrite).isEqual(to:strOperationType as String)) {
            self.writeProperty(nextOperation.value(forKey: "name") as! String, withValue: nextOperation.value(forKey: "value") as Any)
        }else if (NSString.init(string:Constants.kPropertyOperationReadWait).isEqual(to:strOperationType as String)) {
            NSLog("waiting for property \(String(describing: nextPropertyOperation))")
        }
        else {
            self.readProperty(nextOperation.value(forKey: "name") as! String)
        }
    }
    
    @objc func commandTimeout(_ timer: Timer) {
        NSLog("command timed out: \(commandInProgress)")
        
        commandTimeoutTimer = nil
        commandFailedWithError(MyError.init(msg: "command timed out"))
    }
    
    @objc func disconnectTimeout(_ timer: Timer) {
        if ((self.peripheralActor != nil) && (self.peripheralActor!.peripheral != nil)) {
            AppDelegate_.centralManagerActor.centralManager?.cancelPeripheralConnection(self.peripheralActor.peripheral!)
        }
        
    }
    
    func writeProperty(_ property: String, withValue value: Any) {
        let characteristicPath: String = PropertyCharacteristicPath(property: property, servicesMeta: servicesMeta, actor: self)!
        NSLog("characteristicPath \(characteristicPath)")
        
        let meta = servicesMeta.value(forKeyPath: characteristicPath.lowercased()) as! NSDictionary
        NSLog("writing property: \(property), characteristic path: \(characteristicPath), value: \(value), meta: \(meta)")
        
        let transformedValue = transformValue(value, ofProperty: property, direction: kValueTransformDirection.Out)
        NSLog("transformed value: \(String(describing: transformedValue))")
        var valueData: NSData = transformedValue as! NSData
        let propertyType: String = meta.value(forKey: "type") as! String
        if ("string" == propertyType) {
            if valueData.isKind(of: NSString.self)  {
                let stringValue: String = transformedValue as! String
                valueData = stringValue.data(using: String.Encoding.utf8)! as NSData
            }
        }
        else if ("integer" == propertyType) {
            if (transformedValue is NSNumber) {
                valueData = Data.init(from: transformedValue) as NSData
            }
        }
        NSLog("Value Data ", valueData)
        self.peripheralActor?.write(valueData as Data, forCharacteristicPath: characteristicPath)
    }
    
    func readProperty(_ property: String) {
        let characteristicPath: String = PropertyCharacteristicPath(property: property, servicesMeta: self.servicesMeta, actor: self)!
        NSLog("reading property: \(property), characteristic path: \(characteristicPath)")
        self.peripheralActor?.readValue(forCharacteristicPath: characteristicPath)
    }
    
    func performCommand(_ command: String, withParams params: NSMutableDictionary, metaValue: NSDictionary! = nil) {
        var meta = NSMutableDictionary.init(dictionary: metaValue)
        if meta.allKeys.count == 0 {
            meta = self.commandsMeta.value(forKey: command) as! NSMutableDictionary
        }
        if !isConnected() {
            PostNoteBLE(kAddingCommandInQueue, self)
            let commandToEnqueue = NSMutableDictionary.init(dictionary:["command": command, "params": params])
            if meta.allKeys.count != 0 {
                commandToEnqueue["meta"] = meta
            }
            commandsQueue.push(commandToEnqueue)
            return
        }
        if (self.commandInProgress.allKeys.count > 0) {
            let commandToEnqueue = NSMutableDictionary.init(dictionary:["command": command, "params": params])
            if meta.allKeys.count != 0 {
                commandToEnqueue["meta"] = meta
            }
            NSLog("command is in progress: commandInProgress, enqueueing commandToEnqueue")
            commandsQueue.push(commandToEnqueue)
            return
        }
        NSLog("command: \(command), meta: \(meta), params: \(params)", command, meta, params)
        
        let propertyOperations = NSMutableArray()
        
        let arrProperty:[NSDictionary] = meta.value(forKey:"properties") as! [NSDictionary]
        var values: Dictionary<String, Any>? = nil
        for obj in arrProperty {
            let propertyOperation = NSMutableDictionary.init(dictionary: obj)
            let strOperationType = propertyOperation.value(forKey: "operation") as! NSString
            if (NSString.init(string:Constants.kPropertyOperationWrite).isEqual(to:strOperationType as String) && !(propertyOperation.object(forKey: "value") != nil)) {
                let valueStr:String = propertyOperation.value(forKey: "name") as! String
                propertyOperation.setValue(params.value(forKey:valueStr), forKey: "value")
                values = params.value(forKey:valueStr) as? Dictionary<String, Any>
            }
            propertyOperations.add(propertyOperation)
        }
        NSLog("Property operations \(propertyOperations)")
        let completedOperations = NSMutableArray()
        if values != nil {
            self.commandInProgress = ["propertyOperations": propertyOperations, "name": command, "completedPropertyOperations":completedOperations, "values": values!]
        } else {
            self.commandInProgress = ["propertyOperations": propertyOperations, "name": command, "completedPropertyOperations":completedOperations]
        }
        PostNoteWithInfo(kDeviceWillPerformCommand, self, commandInProgress)
        continueCommandInProgress()
    }
    
    func performCommand(_ command: String, withParams params:NSMutableDictionary) {
        NSLog("Command - \(command)")
        performCommand(command, withParams: params, metaValue:[:])
    }
    
    @objc func PeripheralDidWriteValueForCharacteristic(_ note: Notification) {
        let userInfo = note.userInfo as NSDictionary?
        let property: String = self.propertyName(for: userInfo?.value(forKey: "characteristic") as! CBCharacteristic)
        if isCommand(inProgressPerformingOperation: Constants.kPropertyOperationWrite, onProperty: property) {
            continueCommandInProgress()
            return
        }
        //self.PropertyUpdated(note)
    }
    
    func transformValue(_ val: Any, ofProperty name: String, direction dir: kValueTransformDirection) -> Any {
        let commandName =  self.commandInProgress[Constants.kName] as? String
        if (commandName != nil) {
            switch commandName {
            case Constants.kCommand_SendData:
                return transformSendDataCommandValue(val, withDirection: dir)
            case .none: break
                
            case .some(_): break
                
            }
        }
        return val
    }
    
    func transformSendDataCommandValue(_ val: Any, withDirection direction: kValueTransformDirection) -> Any {
        if kValueTransformDirection.In == direction {
            return val
        }
        var payloadData = Data.init()
        let dictionary = val as! Dictionary<String, Any>
        let data = dictionary[Constants.kData] as! Data
        payloadData.append(data)
        return payloadData
    }
    
}

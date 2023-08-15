//
//  AppDelegate.swift
//  Digitail
//
//  Created by Iottive on 06/06/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
import CoreBluetooth
import SideMenu
import IQKeyboardManagerSwift
import SOMotionDetector

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var centralManagerActor = CentralManagerActor(serviceUUIDs: [])
    var deviceActors = [BLEActor]()
    var peripheralList = [DeviceModel]()
    var isScanning = false
    var digitailDeviceActor: BLEActor?
    var eargearDeviceActor: BLEActor?
    var digitailPeripheral: DeviceModel?
    var eargearPeripheral: DeviceModel?
    
    var tempDigitailDeviceActor = [BLEActor]()
    var tempEargearDeviceActor = [BLEActor]()
    var tempFlutterDeviceActor = [BLEActor]()

    
    var tempDigitailPeripheral = [DeviceModel]()
    var tempeargearPeripheral = [DeviceModel]()
    var tempFlutterPeripheral = [DeviceModel]()

    var casualONDigitail = false {
        didSet {
            if !casualONDigitail {
                casualWalkModeTimer?.invalidate()
                casualWalkModeTimer = nil
                duration = 0
            } else {
                // start timer
                casualWalkModeTimer?.invalidate()
                casualWalkModeTimer = nil
                duration = 0
                
                casualWalkModeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerCallback(_:)), userInfo: nil, repeats: true)
            }
        }
    }
    var casualONEarGear = false {
        didSet {
            if !casualONEarGear {
                casualWalkModeTimer?.invalidate()
                casualWalkModeTimer = nil
                duration = 0
            } else {
                // start timer
                casualWalkModeTimer?.invalidate()
                casualWalkModeTimer = nil
                duration = 0
                
                casualWalkModeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerCallback(_:)), userInfo: nil, repeats: true)
            }
        }
    }
    
    var walkModeOn = false {
        didSet {
            if !walkModeOn {
                casualWalkModeTimer?.invalidate()
                casualWalkModeTimer = nil
                duration = 0
            } else {
                // start timer
                casualWalkModeTimer?.invalidate()
                casualWalkModeTimer = nil
                duration = 0
                
                casualWalkModeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerCallback(_:)), userInfo: nil, repeats: true)
            }
        }
    }
    
    var moveOn = false
    
    var duration: Double = 0.0
    var casualWalkModeTimer: Timer?
    var lastStartDate = "last_start_date"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        setUpSideMenu()
        setRootViewController()
        setStatusColor()
        
//        // Load the objects for default store
//        let devices:NSArray = (LoadObjects(kDevicesStorageKey) as NSArray)
//        // Make BLEActor object from state and sericemeta and command(plist files)
//        for state in devices {
//            let meta: String = kServiceMeta
//            let commandMeta: String = kCommandMeta
//            self.deviceActors.append(BLEActor(deviceState: state as! NSMutableDictionary, servicesMeta: DictFromFile(meta), operationsMeta: DictFromFile(commandMeta)))
//        }
        
        RegisterForNote(#selector(self.scanResultPeripheralFound(_:)),kScanResultPeripheralFound, self)
        RegisterForNote(#selector(self.PeripheralFound(_:)), kPeripheralFound, self)
        
        return true
    }
    
    func setUpSideMenu() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        SideMenuManager.default.leftMenuNavigationController = storyboard.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
        
    }
    
    func setRootViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let isVideoPlayed = UserDefaults.standard.bool(forKey: Constants.kIsVideoPlayed)
        if isVideoPlayed == false {
            let viewController = storyboard.instantiateViewController(withIdentifier: "LaunchVC")
            let navigationController = UINavigationController(rootViewController: viewController)
            self.window?.rootViewController = navigationController
        } else {
            let digitailVc = storyboard.instantiateViewController(withIdentifier: "navDigitail") as! UINavigationController
            
            self.window?.rootViewController = digitailVc
        }
        self.window?.makeKeyAndVisible()
    }
    
    func setStatusColor() {
//        if let status = UIApplication.shared.value(forKey: "statusBar") as? UIView {
//            status.backgroundColor = UIColor.init(red: 33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1)
//        }
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    @objc func timerCallback(_ timer: Timer) {
        duration += 1.0
        
        if duration > 3600 {
            // stop casual or walkmode
            if self.casualONDigitail || self.casualONEarGear {
                for connectedDevice in AppDelegate_.tempEargearDeviceActor {
                    let deviceActor = connectedDevice
                    if ((deviceActor.isDeviceIsReady) && (deviceActor.isConnected())) {
                        let tailMoveString = kEndCasualCommand
                        let data = Data(tailMoveString.utf8)
                        deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
                    }
                }
                
                self.casualONDigitail = false
                self.casualONEarGear = false
                
                for connectedDevices in AppDelegate_.tempDigitailDeviceActor {
                    let deviceActor = connectedDevices
                    
                    if ((deviceActor.isDeviceIsReady) && (deviceActor.isConnected())) {
                        let tailMoveString = kAutoModeStopAutoCommand
                        let data = Data(tailMoveString.utf8)
                        deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
                    }
                }
                print("send refresh notification....")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDeviceModeRefreshNotification), object: nil)
                
            } else if self.walkModeOn {
                self.walkModeOn = false
                SOMotionDetector.sharedInstance()?.stopDetection()
                SOLocationManager.sharedInstance()?.stop()
                print("send refresh notification....")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDeviceModeRefreshNotification), object: nil)
            }
        }
    }
    
    @objc func PeripheralFound(_ note: Notification) {
        let peripheral = note.object as! CBPeripheral
        var deviceActor : BLEActor!
        
        if (deviceActor == nil) {
            for actor in self.deviceActors {
                if (actor.isActor(peripheral)){
                    deviceActor = actor;
                    break;
                }
            }
        }
        if (deviceActor == nil) {
            
            var type: BLEDeviceType = .digitail
            
            //            if peripheral.identifier.uuidString == self.digitailPeripheral?.peripheral.identifier.uuidString {
            //                isDigitail = true
            //            } else {
            //                isDigitail = false
            //            }
                        
            var deviceName = ""

            if self.tempDigitailPeripheral.count > 0 {
                for peripharals in self.tempDigitailPeripheral {
                    if peripheral.identifier.uuidString == peripharals.peripheral.identifier.uuidString {
                        deviceName = peripharals.deviceName
                        if deviceName.lowercased().contains("mitail") {
                            type = .mitail
                        }
                    }
                }
            }
            
            if self.tempeargearPeripheral.count > 0 {
                for peripharals in self.tempeargearPeripheral {
                    if peripheral.identifier.uuidString == peripharals.peripheral.identifier.uuidString {
                        deviceName = peripharals.deviceName
                        if deviceName.lowercased().contains("eargear v2") {
                            type = .eg2
                        }
                    }
                }
            }
            
            if self.tempFlutterPeripheral.count > 0 {
                for peripharals in self.tempFlutterPeripheral {
                    if peripheral.identifier.uuidString == peripharals.peripheral.identifier.uuidString {
                        deviceName = peripharals.deviceName
                        if deviceName.lowercased().contains("flutter") {
                            type = .flutter
                        }
                    }
                }
            }
            
            
            if type == .digitail {
                deviceActor = BLEActor(deviceState: [:], servicesMeta: DictFromFile(kServiceMeta), operationsMeta: DictFromFile(kCommandMeta))
                deviceActor.bleDeviceType = type
                deviceActor.state[Constants.kDeviceName] = deviceName
            } else if type == .mitail {
                deviceActor = BLEActor(deviceState: [:], servicesMeta: DictFromFile(kServiceMetaMitail), operationsMeta: DictFromFile(kCommandMeta))
                deviceActor.bleDeviceType = type
                deviceActor.state[Constants.kDeviceName] = deviceName
            } else if type == .eg2 {
                deviceActor = BLEActor(deviceState: [:], servicesMeta: DictFromFile(kServiceMetaEarGear), operationsMeta: DictFromFile(kCommandMetaEarGear))
                deviceActor.bleDeviceType = type
            } else if type == .flutter {
                deviceActor = BLEActor(deviceState: [:], servicesMeta: DictFromFile(kServiceMetaEarGear), operationsMeta: DictFromFile(kCommandMetaEarGear))
                deviceActor.bleDeviceType = type
            }
            
            
            deviceActor.setPeripheral(peripheral)
            self.deviceActors.append(deviceActor)
            if type == .digitail || type == .mitail {
                self.digitailDeviceActor = deviceActor
                self.tempDigitailDeviceActor.append(deviceActor)
            } else {
                self.eargearDeviceActor = deviceActor
                self.tempEargearDeviceActor.append(deviceActor)
            }
            PostNoteBLE(kNewDeviceFound, deviceActor)
        }
        else {
            deviceActor.setPeripheral(peripheral)
        }
    }
    
    
    func storeDeviceState() {
        var states = [Any]()
        for deviceActor in self.deviceActors {
            states.append(deviceActor.state)
        }
        StoreObjects(kDevicesStorageKey, states)
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    //Start Scan Method
    func startScan() {
        guard let isBluetootOnOfiPhone = AppDelegate_.centralManagerActor.centralManager?.state, isBluetootOnOfiPhone == .poweredOn  else {
            print("iOS device bluetooth is seem to be offline")
            // viewActivityIndicator.endRefreshing()
            showBluetoothAlert()
            return
        }
        AppDelegate_.tempDigitailPeripheral.removeAll()
        AppDelegate_.tempeargearPeripheral.removeAll()
        AppDelegate_.peripheralList.removeAll()
        AppDelegate_.centralManagerActor.centralManager?.stopScan()
        AppDelegate_.centralManagerActor.retrievePeripherals()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            AppDelegate_.isScanning = false
        }
    }
    
    func stopScan() {
        AppDelegate_.centralManagerActor.centralManager?.stopScan()
    }
    
    func showBluetoothAlert() {
        let alert = UIAlertController(title: kBlueoothOnTitle, message: kBlueoothOnMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString(kAlertActionOK, comment: "Default action"), style: .default, handler: { _ in
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString(kAlertActionSettings, comment: "Default action"), style: .default, handler: { _ in
            if let url = URL(string:UIApplication.openSettingsURLString)
            {
               UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- BLE Metods ---------------------------------------------------------
    //Scanning results hanlder. Peripheral objects will be returned
    @objc func scanResultPeripheralFound(_ note: Notification) {
        
        //   self.lblMsg.isHidden = true
        // self.tblViewDeviceList.isHidden = false
        let peripheralDict = note.object as! Dictionary<String, Any>
        let peripheral = peripheralDict["peripheral"] as! CBPeripheral
        let advertisementData = peripheralDict["advertisementData"] as! Dictionary<String,Any>
        let deviceName = advertisementData["kCBAdvDataLocalName"] as! String
        let RSSI = peripheralDict["Rssi"] as! NSNumber
        
        if deviceName.contains("(!)Tail1") ||  deviceName.lowercased().contains("mitail") || deviceName.contains("DIGITAIL"){
            var deviceNameToAssign = ""
            if deviceName.lowercased().contains("mitail") {
                deviceNameToAssign = "MITAIL"
            } else {
                deviceNameToAssign = "DIGITAIL"
            }
            let device = DeviceModel.init(deviceNameToAssign, peripheral, RSSI)
            AppDelegate_.digitailPeripheral = device
            
            let addedPeripharalsDevices = AppDelegate_.tempDigitailPeripheral.filter{ ($0.peripheral.identifier.uuidString.contains(device.peripheral.identifier.uuidString)) }
            print("added Digitail Peripharals Devices",addedPeripharalsDevices)
            
            if addedPeripharalsDevices.count > 0 {
                print("Digitail Device is already added or connected")
            } else {
                AppDelegate_.tempDigitailPeripheral.append(device)
                print("Multiple Digitail devices ::",AppDelegate_.tempDigitailPeripheral)
                print("Multiple Digitail devices Count::",AppDelegate_.tempDigitailPeripheral.count)
            }
            
//            AppDelegate_.tempDigitailPeripheral.append(device)
//            print("Multiple digitail devices ::",AppDelegate_.tempDigitailPeripheral)
//            print("Multiple digitail devices Count::",AppDelegate_.tempDigitailPeripheral.count)
        } else if deviceName.lowercased().contains("eargear") ||  deviceName.lowercased().contains("eg2") {
            var deviceNameToAssign = ""
            if deviceName.lowercased().contains("eg2") || deviceName.lowercased().contains("eargear v2"){
                deviceNameToAssign = "EarGear v2"
            } else if deviceName.lowercased().contains("eargear") {
                deviceNameToAssign = "EARGEAR"
            }
            
            let device = DeviceModel.init(deviceNameToAssign, peripheral, RSSI)
            AppDelegate_.eargearPeripheral = device
            
            let addedPeripharalsDevices = AppDelegate_.tempeargearPeripheral.filter{ ($0.peripheral.identifier.uuidString.contains(device.peripheral.identifier.uuidString)) }
            print("added EarGear Peripharals Devices",addedPeripharalsDevices)
            
            if addedPeripharalsDevices.count > 0 {
                print("EarGear Device is already added or connected")
            } else {
                AppDelegate_.tempeargearPeripheral.append(device)
                print("Multiple eargear devices ::",AppDelegate_.tempeargearPeripheral)
                print("Multiple eargear devices Count::",AppDelegate_.tempeargearPeripheral.count)
            }
            
            
//            AppDelegate_.tempeargearPeripheral.append(device)
//            print("Multiple eargear devices ::",AppDelegate_.tempeargearPeripheral)
//            print("Multiple eargear devices Count::",AppDelegate_.tempeargearPeripheral.count)
        }
    }
    
}


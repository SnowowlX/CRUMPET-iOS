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
    var tempDigitailPeripheral = [DeviceModel]()
    var tempeargearPeripheral = [DeviceModel]()
  
    var casualONDigitail = false
    var casualONEarGear = false
   
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
            var isDigitail = true
            //            if peripheral.identifier.uuidString == self.digitailPeripheral?.peripheral.identifier.uuidString {
            //                isDigitail = true
            //            } else {
            //                isDigitail = false
            //            }
                        
            var deviceName = ""
            var isMitail = false
            if self.tempDigitailPeripheral.count > 0 {
                for peripharals in self.tempDigitailPeripheral {
                    if peripheral.identifier.uuidString == peripharals.peripheral.identifier.uuidString {
                        deviceName = peripharals.deviceName
                        isDigitail = true
                        if deviceName.lowercased().contains("mitail") {
                            isMitail = true
                        } else {
                            isMitail = false
                        }
                    }
                }
            }
            
            if self.tempeargearPeripheral.count > 0 {
                for peripharals in self.tempeargearPeripheral {
                    if peripheral.identifier.uuidString == peripharals.peripheral.identifier.uuidString {
                        isDigitail = false
                    }
                }
            }
            

            if isDigitail {
                if isMitail {
                    deviceActor = BLEActor(deviceState: [:], servicesMeta: DictFromFile(kServiceMetaMitail), operationsMeta: DictFromFile(kCommandMeta))
                    deviceActor.isMitail = true
                } else {
                    deviceActor = BLEActor(deviceState: [:], servicesMeta: DictFromFile(kServiceMeta), operationsMeta: DictFromFile(kCommandMeta))
                    deviceActor.isMitail = false
                }
                deviceActor.state[Constants.kDeviceName] = deviceName
            } else {
                deviceActor = BLEActor(deviceState: [:], servicesMeta: DictFromFile(kServiceMetaEarGear), operationsMeta: DictFromFile(kCommandMetaEarGear))
            }
            
            deviceActor.setPeripheral(peripheral)
            self.deviceActors.append(deviceActor)
            if isDigitail {
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
        
        if deviceName.contains("(!)Tail1") ||  deviceName.lowercased().contains("mitail") {
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
        } else if deviceName.lowercased().contains("eargear") {
            let device = DeviceModel.init("EARGEAR", peripheral, RSSI)
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


//
//  DigitailVC.swift
//  Digitail
//
//  Created by Iottive on 07/06/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
import JTMaterialSpinner
import CoreBluetooth
import SideMenu
import AVFoundation
import AVKit
import RangeSeekSlider
import SOMotionDetector
import UserNotifications

let kBlueoothOnTitle = "Bluetooth"
let kBlueoothOnMsg = "Please turn ON Bluetooth & try again"
let kAlertActionOK = "OK"
let kAlertActionSettings = "Settings"
let kBatteryCommand = "BATT"
let kTitleConnect = "Connect Gear!"
let kMsgConnect = "Your gear is not connected"
let kListenModeON = "Listen Mode ON"
let kListenModeOFF = "Listen Mode OFF"
let kListenIOSCommand = "LISTEN IOS"
let kListenENDCommand = "ENDLISTEN"
let kCasualModeOff = "Casual Off"
let kCasualMode = "Casual Mode"
let kEndCasualCommand = "ENDCASUAL"
let kAutoModeStopAutoCommand = "AUTOMODE STOPAUTO"
let kWalkModeDate = "WalkModeDate"
let kWalkModeStart = "TAILS1"
let kWalkModeStop = "TAILHM"
let kWalkModeOff = "Walk Mode Off"
let kWalkMode = "Walk Mode"

class DigitailVC: UIViewController,RangeSeekSliderDelegate, UITableViewDelegate,UITableViewDataSource {
    
    //MARK: - Properties
    @IBOutlet weak var btnAlarm: UIButton!
    @IBOutlet weak var btnGlowTips: UIButton!
    @IBOutlet weak var btnTailMoves: UIButton!
    
    @IBOutlet weak var btnListenMode: UIButton!
    @IBOutlet weak var btnEarMoves: UIButton!
    
    @IBOutlet var btnCausualMode: UIButton!
    @IBOutlet var btnWalkMode: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet var viewTailBattery: UIView!
    
    @IBOutlet var imgViewBatteryStatus: UIImageView!
    @IBOutlet weak var btnConnectDigitail: UIButton!
    
    @IBOutlet weak var LayConsts_VwConnectedDeviceHeight: NSLayoutConstraint!
    @IBOutlet weak var vw_ConnectedDevices: UIView!
    @IBOutlet weak var LayConsts_VwConnectedDeviceTop: NSLayoutConstraint!
    @IBOutlet weak var tblVwConnectedDeviceList: UITableView!
    var isMoving = false
    var isWalkModeON = false
    var batteryTimer = Timer()
    var batteryTimerEarGear = Timer()
    var arrSections  = ["TAIL BATTERY","EARGEAR BATTERY"]
    var statusOfLocation = 0
    
    //MARK: - View Life Cycle -
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "CRUMPET"
        setUpMainUI()
        //Register for Bluetooth State Updates
        RegisterForNote(#selector(DigitailVC.DeviceIsReady(_:)),kDeviceIsReady, self)
        RegisterForNote(#selector(DigitailVC.DeviceDisconnected(_:)),kDeviceDisconnected, self)
        RegisterForNote(#selector(self.DeviceDidUpdateProperty(_:)), kDeviceDidUpdateProperty, self)
        RegisterForNote(#selector(DigitailVC.locationSettingsUpdated(note:)), LOCATION_AUTHORIZATION_STATUS_CHANGED_NOTIFICATION, self)
        setMotionCallBacks()
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.init(red: 96/255.0, green: 125/255.0, blue: 138/255.0, alpha: 1.0)
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        }
    }
    
    func sendNotification(string: String) {
        let content = UNMutableNotificationContent()
        content.title = string
        content.subtitle = "Activity"
        content.sound = UNNotificationSound.default

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // self.viewTailDesciption.isHidden = true
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        if AppDelegate_.casualONEarGear || AppDelegate_.casualONDigitail {
            self.btnCausualMode.setTitle(kCasualModeOff, for: .normal)
        }
        updateConnectionUI()
        setUpConnectedDevicesList()
        tblVwConnectedDeviceList.reloadData()

    }
    
    func setMotionCallBacks () {
        SOMotionDetector.sharedInstance()?.useM7IfAvailable = true
        SOLocationManager.sharedInstance()?.allowsBackgroundLocationUpdates = true
        SOLocationManager.sharedInstance()?.locationType = LocationManagerTypeNone
        SOMotionDetector.sharedInstance()?.motionTypeChangedBlock = { motionType in
            if motionType == MotionTypeWalking || motionType == MotionTypeRunning {
                print("Walking or Running")
                self.isMoving = true
            } else if motionType == MotionTypeNotMoving {
                print("Not moving")
                self.isMoving = false
            }
        }
        SOMotionDetector.sharedInstance()?.locationChangedBlock = { location in
            print("Locationn \(location)")
            if self.isWalkModeON {
                let commandSentDate = UserDefaults.standard.object(forKey: kWalkModeDate)
                if self.isMoving && commandSentDate == nil {
                    UserDefaults.standard.setValue(Date(), forKey: kWalkModeDate)
                    self.walkModeCommand(command: kWalkModeStart)
                } else if self.isMoving && (commandSentDate != nil) {
                    let dateOfLastCommand = commandSentDate as! Date
                    let elapsed = Date().timeIntervalSince(dateOfLastCommand)
                    if elapsed > 12 {
                        UserDefaults.standard.setValue(Date(), forKey: kWalkModeDate)
                        self.walkModeCommand(command: kWalkModeStart)
                    }
                } else if self.isMoving == false {
                    if (commandSentDate != nil) {
                        let dateOfLastCommand = commandSentDate as! Date
                        let elapsed = Date().timeIntervalSince(dateOfLastCommand)
                        if elapsed > 12 {
                            UserDefaults.standard.removeObject(forKey: kWalkModeDate)
                            self.walkModeCommand(command: kWalkModeStop)
                        }
                    }
                }
            }
        }
    }
    
    func updateConnectionUI() {
        if isDIGITAiLConnected() || isEARGEARConnected() {
            self.btnConnectDigitail.isHidden = true
        } else {
            self.btnConnectDigitail.isHidden = false
        }
        setUpConnectedDevicesList()
    }
    
    func isDIGITAiLConnected() -> Bool {
        var isConnected = Bool()
        for connectedDevices in AppDelegate_.tempDigitailDeviceActor {
            if (connectedDevices.peripheralActor != nil && (connectedDevices.isConnected())) {
                isConnected = true
                break
            } else {
                isConnected = false
            }
        }
    
        return isConnected
        
//        if AppDelegate_.digitailDeviceActor != nil && (AppDelegate_.digitailDeviceActor?.peripheralActor != nil && (AppDelegate_.digitailDeviceActor?.isConnected())!) {
//            return true
//        } else {
//            return false
//        }
    }
    
    func isEARGEARConnected() -> Bool {
//        if AppDelegate_.eargearDeviceActor != nil && (AppDelegate_.eargearDeviceActor?.peripheralActor != nil && (AppDelegate_.eargearDeviceActor?.isConnected())!) {
//            return true
//        } else {
//            return false
//        }
        
        var isConnected = Bool()
        for connectedDevices in AppDelegate_.tempEargearDeviceActor {
            if (connectedDevices.peripheralActor != nil && (connectedDevices.isConnected())) {
                isConnected = true
                break
            } else {
                isConnected = false
            }
        }
    
        return isConnected
    }
    
    
    func setUpConnectedDevicesList() {
        LayConsts_VwConnectedDeviceHeight.constant = 0
        LayConsts_VwConnectedDeviceTop.constant = 13
        
        if AppDelegate_.tempDigitailDeviceActor.count > 0 {
            LayConsts_VwConnectedDeviceHeight.constant = 50
            LayConsts_VwConnectedDeviceTop.constant = 13
        }
        if AppDelegate_.tempEargearDeviceActor.count > 0 {
            LayConsts_VwConnectedDeviceHeight.constant = 50
            LayConsts_VwConnectedDeviceTop.constant = 13
        }
        if AppDelegate_.tempDigitailDeviceActor.count > 0 && AppDelegate_.tempEargearDeviceActor.count > 0  {
            LayConsts_VwConnectedDeviceTop.constant = 13
            LayConsts_VwConnectedDeviceHeight.constant = 50
        }

        tblVwConnectedDeviceList.reloadData()
        checkConnectionStatusOfDevices()
    }
    
    func checkConnectionStatusOfDevices() {
        if AppDelegate_.tempDigitailDeviceActor.count > 0 {
            var status = Bool()
            for peripharals in AppDelegate_.tempDigitailDeviceActor {
                let objPeripharal:CBPeripheral = peripharals.peripheralActor.peripheral!
                if objPeripharal.state == .connected {
                    status = true
                    break
                } else {
                    status = false
                }
            }
            
            if status == false {
                if AppDelegate_.tempEargearDeviceActor.count > 0 {
                    LayConsts_VwConnectedDeviceHeight.constant = 50
                    LayConsts_VwConnectedDeviceTop.constant = 13
                } else {
                    LayConsts_VwConnectedDeviceHeight.constant = 0
                    LayConsts_VwConnectedDeviceTop.constant = 13
                }
            }
        }
        
        if AppDelegate_.tempEargearDeviceActor.count > 0 {
            var status = Bool()
            for peripharals in AppDelegate_.tempEargearDeviceActor {
                let objPeripharal:CBPeripheral = peripharals.peripheralActor.peripheral!
                if objPeripharal.state == .connected {
                    status = true
                    break
                } else {
                    status = false
                }
            }
            
            if status == false {
                if AppDelegate_.tempDigitailDeviceActor.count > 0 {
                    LayConsts_VwConnectedDeviceHeight.constant = 50
                    LayConsts_VwConnectedDeviceTop.constant = 13
                } else {
                    LayConsts_VwConnectedDeviceHeight.constant = 0
                    LayConsts_VwConnectedDeviceTop.constant = 13
                }
            }
        }
    }
    
    @IBAction func EarGearMoves_Clicked(_ sender: UIButton) {
        if self.isEARGEARConnected() {
            let eargearMovesVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EarGearMovesVC") as? EarGearMovesVC
            self.navigationController?.pushViewController(eargearMovesVC!, animated: true)
        } else {
            showAlert(title: kTitleConnect, msg: kMsgConnect)
        }
    }
    
    @IBAction func ListenMode_Clicked(_ sender: UIButton) {
        if self.isEARGEARConnected() {
            if btnListenMode.titleLabel?.text == kListenModeON {
                sendListenModeCommand(command: kListenIOSCommand)
                btnListenMode.setTitle(kListenModeOFF, for: .normal)
                btnEarMoves.isEnabled = false
                btnEarMoves.alpha = 0.5
                DispatchQueue.main.asyncAfter(deadline: .now() + 300) {
                    self.btnEarMoves.isEnabled = true
                    self.btnEarMoves.alpha = 1.0
                }
            } else {
               sendListenModeCommand(command: kListenENDCommand)
                btnListenMode.setTitle(kListenModeON, for: .normal)
                 btnEarMoves.isEnabled = true
                btnEarMoves.alpha = 1.0
            }
        } else {
            showAlert(title: kTitleConnect, msg: kMsgConnect)
        }
    }

    //MARK: - Custome Function
    func setUpMainUI(){
        btnAlarm.layer.shadowColor = UIColor.darkGray.cgColor
        btnAlarm.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        btnAlarm.layer.shadowRadius = 2.5
        btnAlarm.layer.shadowOpacity = 0.5
        
        /*
        btnMoveList.layer.shadowColor = UIColor.darkGray.cgColor
        btnMoveList.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        btnMoveList.layer.shadowRadius = 2.5
        btnMoveList.layer.shadowOpacity = 0.5
        
        btnTailPoses.layer.shadowColor = UIColor.darkGray.cgColor
        btnTailPoses.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        btnTailPoses.layer.shadowRadius = 2.5
        btnTailPoses.layer.shadowOpacity = 0.5
 */
        
        btnGlowTips.layer.shadowColor = UIColor.darkGray.cgColor
        btnGlowTips.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        btnGlowTips.layer.shadowRadius = 2.5
        btnGlowTips.layer.shadowOpacity = 0.5
        
        btnTailMoves.layer.shadowColor = UIColor.darkGray.cgColor
        btnTailMoves.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        btnTailMoves.layer.shadowRadius = 2.5
        btnTailMoves.layer.shadowOpacity = 0.5
        
        btnCausualMode.layer.shadowColor = UIColor.darkGray.cgColor
        btnCausualMode.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        btnCausualMode.layer.shadowRadius = 2.5
        btnCausualMode.layer.shadowOpacity = 0.5
        
        viewTailBattery.layer.shadowColor = UIColor.darkGray.cgColor
        viewTailBattery.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        viewTailBattery.layer.shadowRadius = 2.5
        viewTailBattery.layer.shadowOpacity = 0.5
        
        btnEarMoves.layer.shadowColor = UIColor.darkGray.cgColor
        btnEarMoves.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        btnEarMoves.layer.shadowRadius = 2.5
        btnEarMoves.layer.shadowOpacity = 0.5
        
        btnListenMode.layer.shadowColor = UIColor.darkGray.cgColor
        btnListenMode.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        btnListenMode.layer.shadowRadius = 2.5
        btnListenMode.layer.shadowOpacity = 0.5
        
        btnWalkMode.layer.shadowColor = UIColor.darkGray.cgColor
        btnWalkMode.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        btnWalkMode.layer.shadowRadius = 2.5
        btnWalkMode.layer.shadowOpacity = 0.5
        
        btnMenu.layer.cornerRadius = 5.0
    }
    
    @IBAction func actionConnectDigitail(_ sender: UIButton) {
//        let connectVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ConnectVC") as? ConnectVC
//        connectVC?.isForDigitail = true
//        self.navigationController?.pushViewController(connectVC!, animated: true)
        
        let DeviceListVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DeviceListVC") as? DeviceListVC
        self.navigationController?.pushViewController(DeviceListVC!, animated: true)
    }
    
    @IBAction func actionConnectEarGear(_ sender: UIButton) {
//        let connectVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ConnectVC") as? ConnectVC
//        connectVC?.isForDigitail = false
//        self.navigationController?.pushViewController(connectVC!, animated: true)
        
        let DeviceListVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DeviceListVC") as? DeviceListVC
        self.navigationController?.pushViewController(DeviceListVC!, animated: true)
    }
    
    func RemoveBatteryStatus(){
        
    }
    
    func AddBatteryStatus(){
        
    }
    
    //MARK: - Actions
    @IBAction func Alarm_Clicked(_ sender: UIButton) {
        let alarmsVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AlarmsVC") as? AlarmsVC
        self.navigationController?.pushViewController(alarmsVC!, animated: true)
    }
    @IBAction func MoveList_Clicked(_ sender: UIButton) {
        if self.isDIGITAiLConnected() {
            let moveListVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MoveListsVC") as? MoveListsVC
            self.navigationController?.pushViewController(moveListVC!, animated: true)
        } else {
            showAlert(title: kTitleConnect, msg: kMsgConnect)
        }
         
    }
    
   
    @IBAction func TailPoses_Clicked(_ sender: UIButton) {
        let alert = UIAlertController(title: "Tail Poses", message: "Coming Soon", preferredStyle: UIAlertController.Style.alert)
        //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: kAlertActionOK, style: .default, handler:{ (UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
            ///print("User click Ok button")
        }))
        self.present(alert, animated: true, completion: nil)
//        let tailPosesVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TailPosesVC") as? TailPosesVC
//        self.navigationController?.pushViewController(tailPosesVC!, animated: true)
    }
    
    @IBAction func GlowTips_Clicked(_ sender: UIButton) {
        let glowTipsVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "GlowTipsVC") as? GlowTipsVC
        if self.isDIGITAiLConnected() {
            self.navigationController?.pushViewController(glowTipsVC!, animated: true)
        } else {
            //showAlert(title: kTitleConnect, msg: kMsgConnect)
        }
        
    }
    
    @IBAction func Menu_Clicked(_ sender: UIButton) {
       // navigationController?.popToRootViewController(animated: true)

        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    
    @IBAction func CasualMode_Clicked(_ sender: UIButton) {
        if AppDelegate_.casualONDigitail || AppDelegate_.casualONEarGear {
            if self.isEARGEARConnected() && AppDelegate_.casualONEarGear {
                AppDelegate_.casualONEarGear = false
//                let deviceActor = AppDelegate_.eargearDeviceActor
                for connectedDevice in AppDelegate_.tempEargearDeviceActor {
                    let deviceActor = connectedDevice
                    if ((deviceActor.isDeviceIsReady) && (deviceActor.isConnected())) {
                        let tailMoveString = kEndCasualCommand
                        let data = Data(tailMoveString.utf8)
                        deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
                    }
                }
            }
            if self.isDIGITAiLConnected() && AppDelegate_.casualONDigitail {
                AppDelegate_.casualONDigitail = false
//                let deviceActor = AppDelegate_.digitailDeviceActor
                
                for connectedDevices in AppDelegate_.tempDigitailDeviceActor {
                    let deviceActor = connectedDevices
                    
                    if ((deviceActor.isDeviceIsReady) && (deviceActor.isConnected())) {
                        let tailMoveString = kAutoModeStopAutoCommand
                        let data = Data(tailMoveString.utf8)
                        deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
                    }
                }
            }
            self.btnCausualMode.setTitle(kCasualMode, for: .normal)
        } else {
            let casualModeSettingVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CasualModeSettingVC") as? CasualModeSettingVC
            self.navigationController?.pushViewController(casualModeSettingVC!, animated: true)
        }
       
    }
    
    @IBAction func actionWalkMode_Clicked(_ sender: UIButton) {
        if self.isDIGITAiLConnected() {
            if #available(iOS 14.0, *) {
                if statusOfLocation == 3 {
                    if (isWalkModeON) {
                        isWalkModeON = false
                        self.btnWalkMode.setTitle(kWalkMode, for: .normal)
                        stopMotionDetection()
                    } else {
                        isWalkModeON = true
                        self.btnWalkMode.setTitle(kWalkModeOff, for: .normal)
                        startMotionDetection()
                        showAlert(title: "Location Permission", msg: "Please make sure you have granted Always or Allow Once in order to work in background")
                    }
                } else {
                    askUserAlwaysPermission()
                }
            } else {
                if (isWalkModeON) {
                    isWalkModeON = false
                    self.btnWalkMode.setTitle(kWalkMode, for: .normal)
                    stopMotionDetection()
                } else {
                    isWalkModeON = true
                    self.btnWalkMode.setTitle(kWalkModeOff, for: .normal)
                    startMotionDetection()
                }
            }
           
        } else {
            isWalkModeON = true
            showAlert(title: kTitleConnect, msg: kMsgConnect)
        }
    }
    
    @objc func locationSettingsUpdated(note: Notification) {
        if let status = note.userInfo?["status"] {
            print("status \(status)")
            statusOfLocation = (status as AnyObject).integerValue
        }
    }
    func askUserAlwaysPermission() {
        let alertController = UIAlertController.init(title: "Location Permission", message: "Please allow location to Always", preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { action in
                //redirect to setting screen for enable bluetooth or location permision
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    func walkModeCommand(command: String) {
        if self.isDIGITAiLConnected() {
            for connectedDevices in AppDelegate_.tempDigitailDeviceActor {
                let deviceActor = connectedDevices
                if ((deviceActor.isDeviceIsReady) && (deviceActor.isConnected())) {
                    let tailMoveString = command
                    let data = Data(tailMoveString.utf8)
                    deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
                }
            }
        }
    }
    
    @IBAction func TailMoves_Clicked(_ sender: UIButton) {
        let tailMovesVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TailMovesVC") as? TailMovesVC
        
        if self.isDIGITAiLConnected() {
            self.navigationController?.pushViewController(tailMovesVC!, animated: true)
        } else {
            showAlert(title: kTitleConnect, msg: kMsgConnect)
        }
        
    }
    
    
    //MARK: - TableView Delegate Methods -
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            return AppDelegate_.tempDigitailDeviceActor.count
        case 1:
            return AppDelegate_.tempEargearDeviceActor.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         if indexPath.section == 0 {
            //DIGITAil DEVICE LISTS AND BATTERY STATUS --
            let cell = tableView.dequeueReusableCell(withIdentifier: "TblVw_ConnectedDeviceLIst_Cell") as! TblVw_ConnectedDeviceLIst_Cell
            
            if AppDelegate_.tempDigitailDeviceActor[indexPath.row].peripheralActor == nil {
               
            } else {
                cell.lblDeviceName.text = AppDelegate_.tempDigitailDeviceActor[indexPath.row].state[Constants.kDeviceName] as? String
                let batteryLevel = AppDelegate_.tempDigitailDeviceActor[indexPath.row].state["BatteryLevel"]

                if batteryLevel != nil {
                    let battery  = (batteryLevel as! NSString).integerValue
                    DispatchQueue.main.async {
                        cell.iv_BatteryStatus.stopAnimating()
                        if battery == 0 {
                            cell.iv_BatteryStatus.animationImages = [UIImage(named: "battery_0"),UIImage(named: "battery_1")] as? [UIImage]
                            cell.iv_BatteryStatus.animationDuration = 1.0
                            cell.iv_BatteryStatus.startAnimating()
                        } else if battery == 1 {
                            cell.iv_BatteryStatus.image = UIImage(named: "battery_1")
                        } else if battery == 2 {
                            cell.iv_BatteryStatus.image = UIImage(named: "battery_2")
                        } else if battery == 3 {
                            cell.iv_BatteryStatus.image = UIImage(named: "battery_3")
                        } else if battery == 4 {
                            cell.iv_BatteryStatus.image = UIImage(named: "battery_4")
                        }
                    }
                }
            }
            return cell
        } else {
            //EARGEAR DEVICE LISTS AND BATTERY STATUS --
            let cell = tableView.dequeueReusableCell(withIdentifier: "TblVw_ConnectedDeviceLIst_Cell") as! TblVw_ConnectedDeviceLIst_Cell
            if AppDelegate_.tempEargearDeviceActor[indexPath.row].peripheralActor == nil {
               
            } else {
                let objPeripharal:CBPeripheral = (AppDelegate_.tempEargearDeviceActor[indexPath.row].peripheralActor.peripheral!)
                cell.lblDeviceName.text = "EARGEAR"
                let batteryLevel = AppDelegate_.tempEargearDeviceActor[indexPath.row].state["BatteryLevel"]
                print("Eargear battery :: ",batteryLevel as Any)

                if batteryLevel != nil {
                    let battery  = (batteryLevel as! NSString).integerValue

                    DispatchQueue.main.async {
                        cell.iv_BatteryStatus.stopAnimating()
                        if battery == 0 {
                            cell.iv_BatteryStatus.animationImages = [UIImage(named: "battery_0"),UIImage(named: "battery_1")] as? [UIImage]
                            cell.iv_BatteryStatus.animationDuration = 1.0
                            cell.iv_BatteryStatus.startAnimating()
                        } else if battery == 1 {
                            cell.iv_BatteryStatus.image = UIImage(named: "battery_1")
                        } else if battery == 2 {
                            cell.iv_BatteryStatus.image = UIImage(named: "battery_2")
                        } else if battery == 3 {
                            cell.iv_BatteryStatus.image = UIImage(named: "battery_3")
                        } else if battery == 4 {
                            cell.iv_BatteryStatus.image = UIImage(named: "battery_4")
                        }
                    }
                }
            }
            return cell
        }
    }
    
    
    //MARK:- BLE METHODS -
    @objc func DeviceIsReady(_ note: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateConnectionUI()
            if (self.isDIGITAiLConnected()) {
                self.sendBatteryCommand()
                self.startBatteryTimer()
            }
            if (self.isEARGEARConnected()) {
                for connectedDevice in AppDelegate_.tempEargearDeviceActor {
                    let deviceActor = connectedDevice
                    deviceActor.readProperty(Constants.kCharacteristic_BatteryLevel)
                }
            }
        }
    }
    
    @objc func DeviceDidUpdateProperty(_ note: Notification) {
        let objActor : BLEActor = note.object as! BLEActor
        debugPrint(#function,"UpdateValue Data %@", note.userInfo!)
        let responseData = note.userInfo as! [String:Any]
        
        if responseData["name"] as? String == Constants.kCharacteristic_WriteData {
            if let data = responseData["value"] as? Data {
                let str = String(decoding: data, as: UTF8.self)
                if str.contains("BAT") {
                    let val = Int.init(String(str.last!))
                    if AppDelegate_.tempDigitailDeviceActor.contains(objActor) { //AppDelegate_.digitailDeviceActor {
                        objActor.state.setValue("\(val ?? 0)", forKey: "BatteryLevel")
                        AppDelegate_.storeDeviceState()
                        self.tblVwConnectedDeviceList.reloadData()
//                        updateBatteryUI(imgView: self.imgViewBatteryStatus, val: val!)
                    }
                }
                
            }
        } else if responseData["name"] as? String == Constants.kCharacteristic_BatteryLevel {
            if let data = responseData["value"] as? Data {
                var val: Int = data.withUnsafeBytes { $0.pointee }
                if AppDelegate_.tempEargearDeviceActor.contains(objActor) || AppDelegate_.tempDigitailDeviceActor.contains(objActor) {
                    if val < 25 {
                        val = 1
                    } else if val < 50 {
                        val = 2
                    } else if val < 75 {
                        val = 3
                    } else  {
                        val = 4
                    }
                    
                    objActor.state.setValue("\(val)", forKey: "BatteryLevel")
                    AppDelegate_.storeDeviceState()
                    self.tblVwConnectedDeviceList.reloadData()
                }
            }
        }
    }
    

    @objc func DeviceDisconnected(_ note: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let actor = note.object as? BLEActor

            self.updateConnectionUI()
            if !(self.isDIGITAiLConnected()) {
                self.batteryTimer.invalidate()
            }
        }
    }

    func startBatteryTimer() {
        self.batteryTimer.invalidate()
        let loopTime = 30
        self.batteryTimer = Timer.scheduledTimer(timeInterval: TimeInterval(loopTime), target: self, selector:#selector(self.sendBatteryCommand) , userInfo: nil, repeats: true)
    }
    
    func startBatteryTimerEarGear() {
        self.batteryTimerEarGear.invalidate()
        let loopTime = 30
        self.batteryTimerEarGear = Timer.scheduledTimer(timeInterval: TimeInterval(loopTime), target: self, selector:#selector(self.sendBatteryCommandEarGear) , userInfo: nil, repeats: true)
    }
    
    @objc func sendBatteryCommand() {
//        let deviceActor = AppDelegate_.digitailDeviceActor
//        if ((deviceActor!.isDeviceIsReady) && ((deviceActor?.isConnected())!)) {
        
        for connectedDevices in AppDelegate_.tempDigitailDeviceActor {
            let deviceActor = connectedDevices
            if ((deviceActor.isDeviceIsReady) && ((deviceActor.isConnected()))) {
                if (deviceActor.isMitail) {
                    deviceActor.readProperty(Constants.kCharacteristic_BatteryLevel)
                } else {
                    let tailMoveString = kBatteryCommand
                    let data = Data(tailMoveString.utf8)
                    deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
                }
            }
        }
    }
    
    func sendListenModeCommand(command: String) {
//        let deviceActor = AppDelegate_.eargearDeviceActor
        for connectedDevice in AppDelegate_.tempEargearDeviceActor {
            let deviceActor = connectedDevice
            if ((deviceActor.isDeviceIsReady) && ((deviceActor.isConnected()))) {
                let data = Data(command.utf8)
                deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
            }
        }
    }
    
    @objc func sendBatteryCommandEarGear() {
//        let deviceActor = AppDelegate_.eargearDeviceActor
        for connectedDevice in AppDelegate_.tempEargearDeviceActor {
            let deviceActor = connectedDevice
            if ((deviceActor.isDeviceIsReady) && (deviceActor.isConnected())) {
                let tailMoveString = kBatteryCommand
                let data = Data(tailMoveString.utf8)
                deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
            }
        }
    }
    
    func showAlert(title:String, msg:String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: kAlertActionOK, style: .default, handler:{ (UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
            ///print("User click Ok button")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func startMotionDetection() {
        SOMotionDetector.sharedInstance()?.startDetection()
        SOLocationManager.sharedInstance()?.start()
    }
    func stopMotionDetection() {
        SOMotionDetector.sharedInstance()?.stopDetection()
        SOLocationManager.sharedInstance()?.stop()
    }
}
extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

    
    
    



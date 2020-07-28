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

class DigitailVC: UIViewController,RangeSeekSliderDelegate{
    
    //MARK: - Properties
    @IBOutlet weak var btnAlarm: UIButton!
    @IBOutlet weak var btnMoveList: UIButton!
    @IBOutlet weak var btnTailPoses: UIButton!
    @IBOutlet weak var btnGlowTips: UIButton!
    @IBOutlet weak var btnTailMoves: UIButton!
    
    @IBOutlet weak var btnListenMode: UIButton!
    @IBOutlet weak var btnEarMoves: UIButton!
    
    @IBOutlet var btnCausualMode: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet var viewTailBattery: UIView!
    @IBOutlet var viewEarGearBattery: UIView!
    @IBOutlet var imgViewBatteryStatus: UIImageView!
    @IBOutlet var imgViewEarGearBatteryStatus: UIImageView!
    @IBOutlet weak var btnConnectDigitail: UIButton!
    @IBOutlet weak var btnConnectEarGear: UIButton!
    
    var batteryTimer = Timer()
    var batteryTimerEarGear = Timer()
    
    //MARK: - View Life Cycle
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "DIGITAIL"
        setUpMainUI()
        //Register for Bluetooth State Updates
        RegisterForNote(#selector(DigitailVC.DeviceIsReady(_:)),kDeviceIsReady, self)
        RegisterForNote(#selector(DigitailVC.DeviceDisconnected(_:)),kDeviceDisconnected, self)
        RegisterForNote(#selector(self.DeviceDidUpdateProperty(_:)), kDeviceDidUpdateProperty, self)
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
    }
    
    func updateConnectionUI() {
        if isDIGITAiLConnected() {
            self.btnConnectDigitail.isHidden = true
        } else {
            self.btnConnectDigitail.isHidden = false
        }
        
        if isEARGEARConnected() {
            self.btnConnectEarGear.isHidden = true
        } else {
            self.btnConnectEarGear.isHidden = false
        }
        
    }
    
    func isDIGITAiLConnected() -> Bool {
        if AppDelegate_.digitailDeviceActor != nil && (AppDelegate_.digitailDeviceActor?.peripheralActor != nil && (AppDelegate_.digitailDeviceActor?.isConnected())!) {
            return true
        } else {
            return false
        }
    }
    
    func isEARGEARConnected() -> Bool {
        if AppDelegate_.eargearDeviceActor != nil && (AppDelegate_.eargearDeviceActor?.peripheralActor != nil && (AppDelegate_.eargearDeviceActor?.isConnected())!) {
            return true
        } else {
            return false
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
        
        btnMoveList.layer.shadowColor = UIColor.darkGray.cgColor
        btnMoveList.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        btnMoveList.layer.shadowRadius = 2.5
        btnMoveList.layer.shadowOpacity = 0.5
        
        btnTailPoses.layer.shadowColor = UIColor.darkGray.cgColor
        btnTailPoses.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        btnTailPoses.layer.shadowRadius = 2.5
        btnTailPoses.layer.shadowOpacity = 0.5
        
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
        
        viewEarGearBattery.layer.shadowColor = UIColor.darkGray.cgColor
        viewEarGearBattery.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        viewEarGearBattery.layer.shadowRadius = 2.5
        viewEarGearBattery.layer.shadowOpacity = 0.5
        
        btnEarMoves.layer.shadowColor = UIColor.darkGray.cgColor
        btnEarMoves.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        btnEarMoves.layer.shadowRadius = 2.5
        btnEarMoves.layer.shadowOpacity = 0.5
        
        btnListenMode.layer.shadowColor = UIColor.darkGray.cgColor
        btnListenMode.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        btnListenMode.layer.shadowRadius = 2.5
        btnListenMode.layer.shadowOpacity = 0.5
        
        btnMenu.layer.cornerRadius = 5.0
    }
    
    @IBAction func actionConnectDigitail(_ sender: UIButton) {
        let connectVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ConnectVC") as? ConnectVC
        connectVC?.isForDigitail = true
        self.navigationController?.pushViewController(connectVC!, animated: true)
    }
    
    @IBAction func actionConnectEarGear(_ sender: UIButton) {
        let connectVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ConnectVC") as? ConnectVC
        connectVC?.isForDigitail = false
        self.navigationController?.pushViewController(connectVC!, animated: true)
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
        let moveListVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MoveListsVC") as? MoveListsVC
        self.navigationController?.pushViewController(moveListVC!, animated: true)
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
                let deviceActor = AppDelegate_.eargearDeviceActor
                if ((deviceActor!.isDeviceIsReady) && (deviceActor!.isConnected())) {
                    let tailMoveString = kEndCasualCommand
                    let data = Data(tailMoveString.utf8)
                    deviceActor!.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
                }
            }
            if self.isDIGITAiLConnected() && AppDelegate_.casualONDigitail {
                AppDelegate_.casualONDigitail = false
                let deviceActor = AppDelegate_.digitailDeviceActor
                if ((deviceActor!.isDeviceIsReady) && (deviceActor!.isConnected())) {
                    let tailMoveString = kAutoModeStopAutoCommand
                    let data = Data(tailMoveString.utf8)
                    deviceActor!.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
                }
            }
            self.btnCausualMode.setTitle(kCasualMode, for: .normal)
        } else {
            let casualModeSettingVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CasualModeSettingVC") as? CasualModeSettingVC
            self.navigationController?.pushViewController(casualModeSettingVC!, animated: true)
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
    
    @objc func DeviceIsReady(_ note: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateConnectionUI()
            if (self.isDIGITAiLConnected()) {
                self.sendBatteryCommand()
                self.startBatteryTimer()
            }
            if (self.isEARGEARConnected()) {
                AppDelegate_.eargearDeviceActor?.readProperty(Constants.kCharacteristic_BatteryLevel)
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
                    if objActor == AppDelegate_.digitailDeviceActor {
                        updateBatteryUI(imgView: self.imgViewBatteryStatus, val: val!)
                    }
                }
                
            }
        } else if responseData["name"] as? String == Constants.kCharacteristic_BatteryLevel {
            if let data = responseData["value"] as? Data {
                var val: Int = data.withUnsafeBytes { $0.pointee }
                if objActor == AppDelegate_.eargearDeviceActor {
                    if val < 25 {
                        val = 1
                    } else if val < 50 {
                        val = 2
                    } else if val < 75 {
                        val = 3
                    } else  {
                        val = 4
                    }
                    updateBatteryUI(imgView: self.imgViewEarGearBatteryStatus, val: val)
                }
            }
        }
    }
    
    func updateBatteryUI(imgView: UIImageView, val: Int) {
        DispatchQueue.main.async {
            imgView.stopAnimating()
            if val == 0 {
                imgView.animationImages = [UIImage(named: "battery_0"),UIImage(named: "battery_1")] as? [UIImage]
                imgView.animationDuration = 1.0
                imgView.startAnimating()
            } else if val == 1 {
                imgView.image = UIImage(named: "battery_1")
            } else if val == 2 {
                imgView.image = UIImage(named: "battery_2")
            } else if val == 3 {
                imgView.image = UIImage(named: "battery_3")
            } else if val == 4 {
                imgView.image = UIImage(named: "battery_4")
            }
        }
    }

    @objc func DeviceDisconnected(_ note: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
        let deviceActor = AppDelegate_.digitailDeviceActor
        if ((deviceActor!.isDeviceIsReady) && ((deviceActor?.isConnected())!)) {
            let tailMoveString = kBatteryCommand
            let data = Data(tailMoveString.utf8)
            deviceActor!.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
        }
    }
    
    func sendListenModeCommand(command: String) {
        let deviceActor = AppDelegate_.eargearDeviceActor
        if ((deviceActor!.isDeviceIsReady) && ((deviceActor?.isConnected())!)) {
            let data = Data(command.utf8)
            deviceActor!.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
        }
    }
    
    @objc func sendBatteryCommandEarGear() {
        let deviceActor = AppDelegate_.eargearDeviceActor
        if ((deviceActor!.isDeviceIsReady) && (deviceActor!.isConnected())) {
            let tailMoveString = kBatteryCommand
            let data = Data(tailMoveString.utf8)
            deviceActor!.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
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
}
extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

    
    
    



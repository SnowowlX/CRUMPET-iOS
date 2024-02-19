//
//  CasualModeSettingVC.swift
//  Digitail
//
//  Created by Iottive on 28/06/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
import SideMenu
import RangeSeekSlider

let kCalmAndRelaxed  = NSLocalizedString("kCalmAndRelaxed", comment: "")
let kFastAndExcited  = NSLocalizedString("kFastAndExcited", comment: "")
let kFrustratedAndTense  = NSLocalizedString("kFrustratedAndTense", comment: "")
let kLEDPatterns  = "LED Patterns"
let kEarGearMoves  = NSLocalizedString("kEarGearPoses", comment: "")

let kSendToEargear = NSLocalizedString("kSendToEargear", comment: "")
let kSendToTail = NSLocalizedString("kSendTail", comment: "")
let kStartCasualMode = NSLocalizedString("kStartCasualMode", comment: "")
let kStopCasualMode = NSLocalizedString("kStopCasualMode", comment: "")

let selectedKeys = "userdefault_selected_keys"

class CasualModeSettingVC: UIViewController,UITableViewDelegate,UITableViewDataSource,RangeSeekSliderDelegate{
    
    //MARK: - Outlets
    @IBOutlet var viewCasualModeCatDesc: UIView!
    @IBOutlet var tblViewCasualModeCategories: UITableView!
    @IBOutlet var btnValue1: UIButton!
    @IBOutlet var btnValue2: UIButton!
    @IBOutlet var btnValue3: UIButton!
    
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var btnSendToTail: UIButton!
    
    var arrSelectedIndex =  [Int]()
    let arrCasualMode = [kCalmAndRelaxed,kFastAndExcited,kFrustratedAndTense]

    var arrSelectedMode = [String]()
   
    var minRangeValue : Int? = nil
    var maxRangeValue : Int? = nil
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainUI()
        
        arrSelectedMode = UserDefaults.standard.stringArray(forKey: selectedKeys) ?? []
        if arrSelectedMode.count == 0 || minRangeValue == nil || maxRangeValue == nil {
            btnSendToTail.isUserInteractionEnabled = false
            btnSendToTail.alpha = 0.5
        } else {
            btnSendToTail.isUserInteractionEnabled = true
            btnSendToTail.alpha = 1.0
        }
        
        tblViewCasualModeCategories.reloadData()
        
        RegisterForNote(#selector(self.refreshHome(_:)), kDeviceModeRefreshNotification, self)
        
        if AppDelegate_.casualONDigitail || AppDelegate_.casualONEarGear {
            btnSendToTail.setTitle(kStopCasualMode, for: .normal)
        } else {
            btnSendToTail.setTitle(kStartCasualMode, for: .normal)
        }
    }
    
    @objc func refreshHome(_ note: Notification) {
        if AppDelegate_.casualONDigitail || AppDelegate_.casualONEarGear {
            btnSendToTail.setTitle(kStopCasualMode, for: .normal)
        } else {
            btnSendToTail.setTitle(kStartCasualMode, for: .normal)
        }
    }
    
    //MARK: - Custome Function
    func setUpMainUI(){
        btnSendToTail.layer.shadowColor = UIColor.darkGray.cgColor
        btnSendToTail.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        btnSendToTail.layer.shadowRadius = 2.5
        btnSendToTail.layer.shadowOpacity = 0.5
        btnSendToTail.setTitle(kSendToTail, for: .normal)
        btnMenu.layer.cornerRadius = 5.0

        btnValue1.layer.cornerRadius = 5.0
        btnValue2.layer.cornerRadius = 5.0
        btnValue3.layer.cornerRadius = 5.0
        
        tblViewCasualModeCategories.separatorInset = .zero
        tblViewCasualModeCategories.layoutMargins = .zero
        
        viewCasualModeCatDesc.layer.shadowColor = UIColor.darkGray.cgColor
        viewCasualModeCatDesc.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        viewCasualModeCatDesc.layer.shadowRadius = 2.5
        viewCasualModeCatDesc.layer.shadowOpacity = 0.5
        
      
        //viewRangeSlider.max
    
        /*
        viewRangeSlider.delegate = self
        viewRangeSlider.trackHighlightTintColor = UIColor(red: 96/255, green: 125/255, blue: 138/255, alpha: 1.0)
        viewRangeSlider.lowerValue = 20.0
        viewRangeSlider.upperValue = 80.0
        viewRangeSlider.lowerLabel?.isHidden = true
        viewRangeSlider.upperLabel?.isHidden = true
         */
    }
    
//    func openErrorMsg() {
//        let deviceActor = AppDelegate_.digitailDeviceActor
//        if deviceActor?.isConnected() == nil {
//              UIAlertController.alert(title:"Error", msg:"Please connect to device", target: self)
//        }
//        if arrSelectedIndex.count == 0 {
//           UIAlertController.alert(title:"Error", msg:"Please select group", target: self)
//        }
//    }
    
    func openErrorMsg(connectedDevice : BLEActor?) {
        let deviceActor = connectedDevice
        if deviceActor?.isConnected() == nil {
              UIAlertController.alert(title:"Error", msg:"Please connect to device", target: self)
        }
        if arrSelectedMode.count == 0 {
           UIAlertController.alert(title:"Error", msg:"Please select group", target: self)
        }
    }
    
    //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCasualMode.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TblCellCasualModeSetting", for: indexPath) as! TblCellCasualModeSetting
        cell.selectionStyle = .none
        cell.lblCasualCategoryName.text = arrCasualMode[indexPath.row]
        cell.btnCheckBox.tag = indexPath.row
        cell.btnCheckBox.addTarget(self, action: #selector(CheckBox_Clicked(sender:)), for: .touchUpInside)
        
        if arrSelectedMode.contains(arrCasualMode[indexPath.row]) {
            cell.btnCheckBox.setImage(UIImage(named: "check-mark (2)"), for: .normal)
            cell.btnCheckBox.backgroundColor = UIColor(red: 25/255, green: 157/255, blue: 8/255, alpha: 1.0)
        } else {
            cell.btnCheckBox.backgroundColor = UIColor(red: 25/255, green: 157/255, blue: 8/255, alpha: 1.0)
            cell.btnCheckBox.setImage(nil, for: .normal)
        }
        
        return cell
    }
    
     //MARK: - Actions
    @IBAction func value1Clicked(_ sender: UIButton) {
        btnValue1.backgroundColor = UIColor(red: 0.40, green: 0.49, blue: 0.54, alpha: 1.00)
        btnValue2.backgroundColor = UIColor.lightGray
        btnValue3.backgroundColor = UIColor.lightGray
        minRangeValue = 20
        maxRangeValue = 60
        
        if arrSelectedMode.count == 0 || minRangeValue == nil || maxRangeValue == nil {
            btnSendToTail.isUserInteractionEnabled = false
            btnSendToTail.alpha = 0.5
        } else {
            btnSendToTail.isUserInteractionEnabled = true
            btnSendToTail.alpha = 1.0
        }
    }
    
    @IBAction func value2Clicked(_ sender: UIButton) {
        btnValue2.backgroundColor = UIColor(red: 0.40, green: 0.49, blue: 0.54, alpha: 1.00)
        btnValue1.backgroundColor = UIColor.lightGray
        btnValue3.backgroundColor = UIColor.lightGray
        minRangeValue = 15
        maxRangeValue = 40
        
        if arrSelectedMode.count == 0 || minRangeValue == nil || maxRangeValue == nil {
            btnSendToTail.isUserInteractionEnabled = false
            btnSendToTail.alpha = 0.5
        } else {
            btnSendToTail.isUserInteractionEnabled = true
            btnSendToTail.alpha = 1.0
        }
    }
    
    @IBAction func value3Clicked(_ sender: UIButton) {
        btnValue3.backgroundColor = UIColor(red: 0.40, green: 0.49, blue: 0.54, alpha: 1.00)
        btnValue1.backgroundColor = UIColor.lightGray
        btnValue2.backgroundColor = UIColor.lightGray
        minRangeValue = 10
        maxRangeValue = 30
        
        if arrSelectedMode.count == 0 || minRangeValue == nil || maxRangeValue == nil {
            btnSendToTail.isUserInteractionEnabled = false
            btnSendToTail.alpha = 0.5
        } else {
            btnSendToTail.isUserInteractionEnabled = true
            btnSendToTail.alpha = 1.0
        }
    }
    
    @IBAction func Menu_Clicked(_ sender: UIButton) {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @objc func CheckBox_Clicked(sender: UIButton){
        let checkMode = arrCasualMode[sender.tag]
        
        if arrSelectedMode.contains(checkMode) {
            if let firstIndex = arrSelectedMode.firstIndex(of: checkMode) {
                arrSelectedMode.remove(at: firstIndex)
            }
        } else {
            arrSelectedMode.append(checkMode)
        }
        
//        if arrSelectedIndex.contains(sender.tag) {
//                    arrSelectedIndex.remove(at: arrSelectedIndex.index(of: sender.tag)!)
//                } else {
//                    if sender.tag == 3 {
//                        arrSelectedIndex.removeAll()
//                    }
//                    arrSelectedIndex.append(sender.tag)
//                    if sender.tag != 3 && arrSelectedIndex.contains(3) {
//                        arrSelectedIndex.remove(at: arrSelectedIndex.index(of: 3)!)
//                    }
//                }
        
        UserDefaults.standard.set(arrSelectedMode, forKey: selectedKeys)
        
        if arrSelectedMode.count == 0 || minRangeValue == nil || maxRangeValue == nil {
            btnSendToTail.isUserInteractionEnabled = false
            btnSendToTail.alpha = 0.5
        } else {
            btnSendToTail.isUserInteractionEnabled = true
            btnSendToTail.alpha = 1.0
        }
        
        tblViewCasualModeCategories.reloadData()
    }
    
    @IBAction func SendToTail_Clicked(_ sender: UIButton) {
      
        guard let minValue = minRangeValue, let maxValue = maxRangeValue else {
            return
        }
        
        if AppDelegate_.casualONDigitail || AppDelegate_.casualONEarGear || AppDelegate_.casualONFlutter || AppDelegate_.casualONMinitail { // already on
            
            if AppDelegate_.casualONDigitail {
                print("Maulik- Casual mode in digitail is on and need to off now")
                AppDelegate_.casualONDigitail = false
                for connectedDevices in AppDelegate_.tempDigitailDeviceActor {
                    let deviceActor = connectedDevices
                    
                    if ((deviceActor.isDeviceIsReady) && (deviceActor.isConnected())) {
                        let tailMoveString = kAutoModeStopAutoCommand
                        let data = Data(tailMoveString.utf8)
                        deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
                    }
                }
                
            }
            
            if AppDelegate_.casualONEarGear {
                print("Maulik- Casual mode in eargear is on and need to off now")
                AppDelegate_.casualONEarGear = false
                for connectedDevice in AppDelegate_.tempEargearDeviceActor {
                    let deviceActor = connectedDevice
                    if ((deviceActor.isDeviceIsReady) && (deviceActor.isConnected())) {
                        let tailMoveString = kEndCasualCommand
                        let data = Data(tailMoveString.utf8)
                        deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
                    }
                }
                
            }
            
            if AppDelegate_.casualONFlutter {
                print("Maulik- Casual mode in digitail is on and need to off now")
                AppDelegate_.casualONFlutter = false
                for connectedDevices in AppDelegate_.tempFlutterDeviceActor {
                    let deviceActor = connectedDevices
                    
                    if ((deviceActor.isDeviceIsReady) && (deviceActor.isConnected())) {
                        let tailMoveString = kAutoModeStopAutoCommand
                        let data = Data(tailMoveString.utf8)
                        deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
                    }
                }
                
            }
            
            if AppDelegate_.casualONMinitail {
                print("Maulik- Casual mode in digitail is on and need to off now")
                AppDelegate_.casualONMinitail = false
                for connectedDevices in AppDelegate_.tempFlutterDeviceActor {
                    let deviceActor = connectedDevices
                    
                    if ((deviceActor.isDeviceIsReady) && (deviceActor.isConnected())) {
                        let tailMoveString = kAutoModeStopAutoCommand
                        let data = Data(tailMoveString.utf8)
                        deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
                    }
                }
                
            }
            btnSendToTail.setTitle(kStartCasualMode, for: .normal)
            
        } else { // start
            
            for connectedDevice in AppDelegate_.tempEargearDeviceActor {
                let deviceActor = connectedDevice
                if ((deviceActor.isDeviceIsReady) && (deviceActor.isConnected())) {
                    btnSendToTail.setTitle(kSendToTail, for: .normal)
                    AppDelegate_.casualONEarGear = true
                    sender.tag = 2
                    let minTime = "T\(Int(minValue))"
                    let MaxTime = "T\(Int(maxValue))"
                    var eargearString = String()
                    var timeString : String?
                    eargearString = "CASUAL"
                    timeString = "\(eargearString) \(minTime)\(MaxTime)"
                    print(timeString!)
                    let data = Data(timeString!.utf8)
                    
                    deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]))
                }
            }
            
            for connectedDevices in AppDelegate_.tempDigitailDeviceActor {
                let deviceActor = connectedDevices
                
                if (deviceActor.isDeviceIsReady) && (deviceActor.isConnected()) {
                    btnSendToTail.setTitle(kSendToEargear, for: .normal)
                    sender.tag = 1
                    AppDelegate_.casualONDigitail = true
                    let minTime = "T\(Int(minValue)) "//T18
                    let MaxTime = "T\(Int(maxValue)) "//T200
                    //  let totalduration = "T\(Int((viewRangeSlider.selectedMaxValue)/60))"
                    let totalduration = "T240"
                    var tailMoveString : String!
                    var timeString : String!
                    tailMoveString = "AUTOMODE"
                    // tailMoveString = "AUTOMOVE \(minTime)\(MaxTime)\(totalduration)"
                    timeString = " \(minTime)\(MaxTime)\(totalduration)"

                    for selectedGroup in arrSelectedMode {
                        if let modeIndex = arrCasualMode.firstIndex(of: selectedGroup) {
                            tailMoveString.append(contentsOf:  "G\(modeIndex+1) ")
                        }
                    }
                    
                    tailMoveString.append(contentsOf: timeString)
                    print(tailMoveString!)
                    let data = Data(tailMoveString!.utf8)
                    deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
                    //                } while dataSendCount < (data.count)
//                    UIAlertController.alert(title:"", msg:"Casual mode on", target: self)
                }
                else{
                    openErrorMsg(connectedDevice: deviceActor)
                }
            }
            
            for connectedDevices in AppDelegate_.tempFlutterDeviceActor {
                let deviceActor = connectedDevices
                
                if (deviceActor.isDeviceIsReady) && (deviceActor.isConnected()) {
                    btnSendToTail.setTitle(kSendToEargear, for: .normal)
                    sender.tag = 1
                    AppDelegate_.casualONFlutter = true
                    let minTime = "T\(Int(minValue)) "//T18
                    let MaxTime = "T\(Int(maxValue)) "//T200
                    //  let totalduration = "T\(Int((viewRangeSlider.selectedMaxValue)/60))"
                    let totalduration = "T240"
                    var tailMoveString : String!
                    var timeString : String!
                    tailMoveString = "AUTOMODE"
                    // tailMoveString = "AUTOMOVE \(minTime)\(MaxTime)\(totalduration)"
                    timeString = " \(minTime)\(MaxTime)\(totalduration)"

                    for selectedGroup in arrSelectedMode {
                        if let modeIndex = arrCasualMode.firstIndex(of: selectedGroup) {
                            tailMoveString.append(contentsOf:  "G\(modeIndex+1) ")
                        }
                    }
                    
                    tailMoveString.append(contentsOf: timeString)
                    print(tailMoveString!)
                    let data = Data(tailMoveString!.utf8)
                    deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
                    //                } while dataSendCount < (data.count)
//                    UIAlertController.alert(title:"", msg:"Casual mode on", target: self)
                }
                else{
                    openErrorMsg(connectedDevice: deviceActor)
                }
            }
            
            for connectedDevices in AppDelegate_.tempMinitailDeviceActor {
                let deviceActor = connectedDevices
                
                if (deviceActor.isDeviceIsReady) && (deviceActor.isConnected()) {
                    btnSendToTail.setTitle(kSendToEargear, for: .normal)
                    sender.tag = 1
                    AppDelegate_.casualONMinitail = true
                    let minTime = "T\(Int(minValue)) "//T18
                    let MaxTime = "T\(Int(maxValue)) "//T200
                    //  let totalduration = "T\(Int((viewRangeSlider.selectedMaxValue)/60))"
                    let totalduration = "T240"
                    var tailMoveString : String!
                    var timeString : String!
                    tailMoveString = "AUTOMODE"
                    // tailMoveString = "AUTOMOVE \(minTime)\(MaxTime)\(totalduration)"
                    timeString = " \(minTime)\(MaxTime)\(totalduration)"

                    for selectedGroup in arrSelectedMode {
                        if let modeIndex = arrCasualMode.firstIndex(of: selectedGroup) {
                            tailMoveString.append(contentsOf:  "G\(modeIndex+1) ")
                        }
                    }
                    
                    tailMoveString.append(contentsOf: timeString)
                    print(tailMoveString!)
                    let data = Data(tailMoveString!.utf8)
                    deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
                    //                } while dataSendCount < (data.count)
//                    UIAlertController.alert(title:"", msg:"Casual mode on", target: self)
                }
                else{
                    openErrorMsg(connectedDevice: deviceActor)
                }
            }
            btnSendToTail.setTitle(kStopCasualMode, for: .normal)
        }
    }
    
    
    /*
    func sliderValueChanged(slider: NHRangeSlider?) {
        let sliderLowerValue = Int((slider?.lowerValue)!)
        let sliderUpperValue = Int((slider?.upperValue)!)
        lblRangeSliderLowVal.text = "\(sliderLowerValue)"
        lblRangeSliderUpperValue.text = "\(sliderUpperValue)"
       // let dblval = Double(i)
    }*/
    
    //Navigation hide Show according to  TableView scrolling
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        if targetContentOffset.pointee.y < scrollView.contentOffset.y {
//            // it's going up
//            self.navigationController?.setNavigationBarHidden(true, animated: true)
//        } else {
//            // it's going down
//            self.navigationController?.setNavigationBarHidden(false, animated: true)
//        }
//    }
}

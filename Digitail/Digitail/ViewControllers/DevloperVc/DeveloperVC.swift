//
//  DeveloperVC.swift
//  CRUMPET
//
//  Created by Admin on 5/21/20.
//  Copyright © 2020 Iottive. All rights reserved.
//

import UIKit
import SideMenu

let kMICBAL = "MICBAL"
let kMICSWAP = "MICSWAP"

class DeveloperVC: UIViewController {

    var strSelectedValue : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK:- CUSTOM METHODS -
    func sendDataToDevice(selectedValue : String) {
//        let deviceActor = AppDelegate_.eargearDeviceActor
        
        for connectedDevice in AppDelegate_.tempEargearDeviceActor {
            let deviceActor = connectedDevice
            if ((deviceActor.isDeviceIsReady) && (deviceActor.isConnected())) {
                let data = Data(selectedValue.utf8)
                deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]))
            } else {
                if deviceActor.isConnected() == false {
                    UIAlertController.alert(title:"Error", msg:"Please connect to device", target: self)
                }
            }
        }
    }
    
    //MARK:- BUTTON CLICKS -
    @IBAction func menu_Clicked(_ sender: UIButton) {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func switchLR_Clicked(_ sender: UIButton) {
        sendDataToDevice(selectedValue: kMICSWAP)
    }
    
    @IBAction func MicBal_Clicked(_ sender: UIButton) {
        sendDataToDevice(selectedValue: kMICBAL)
    }
}

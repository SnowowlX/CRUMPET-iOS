//
//  GlowTipsVC.swift
//  Digitail
//
//  Created by Iottive on 03/07/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
import JTMaterialSpinner
import SideMenu

let kCommandCalm = "SPEED SLOW"
let kCommandExcited = "SPEED FAST"
class EarGear2MovesVC: UIViewController{
    
    //MARK: - Properties
    
    
    @IBOutlet var lblTailDescription: UILabel!
    @IBOutlet var btnStop: UIButton!
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var btnLookForTails: UIButton!
    @IBOutlet var viewLEDPatternsDesc: UIView!
    @IBOutlet var viewLEDPatternsList: CardView!
    @IBOutlet var segmentCalmExcited: UISegmentedControl!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateConnectionUI()
    }
    
    //MARK: - Custom Function
    func setUpMainUI(){
      RegisterForNote(#selector(GlowTipsVC.DeviceIsReady(_:)),kDeviceIsReady, self)
      RegisterForNote(#selector(GlowTipsVC.DeviceDisconnected(_:)),kDeviceDisconnected, self)
        btnMenu.layer.cornerRadius = 5.0
        viewLEDPatternsDesc.layer.shadowColor = UIColor.darkGray.cgColor
        viewLEDPatternsDesc.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        viewLEDPatternsDesc.layer.shadowRadius = 4.5
        viewLEDPatternsDesc.layer.shadowOpacity = 0.5
        viewLEDPatternsDesc.isHidden = true
        
        btnStop.layer.cornerRadius = btnStop.frame.height/2.0
        btnStop.clipsToBounds = true
        self.sendDeviceCommand(command: kCommandCalm)
        
    }
    
    @IBAction func actionCalmExcited(_ sender: Any) {
        if segmentCalmExcited.selectedSegmentIndex == 1 {
            self.sendDeviceCommand(command: kCommandExcited)
        } else {
            self.sendDeviceCommand(command: kCommandCalm)
        }
    }
    
    func updateConnectionUI() {
        let deviceActor = AppDelegate_.eargearDeviceActor
        if (deviceActor?.peripheralActor != nil && (deviceActor?.isConnected())!) {
            self.viewLEDPatternsDesc.isHidden = false
            self.viewLEDPatternsList.isHidden = false
        }
    }
    
    @objc func DeviceIsReady(_ note: Notification) {
        
    }
    
    @objc func DeviceDisconnected(_ note: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func openAlertView() {
        let alert = UIAlertController(title: "Glow Tips", message: "Coming Soon", preferredStyle: UIAlertController.Style.alert)
        //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: kAlertActionOK, style: .default, handler:{ (UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
            ///print("User click Ok button")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func Menu_Clicked(_ sender: UIButton) {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func Stop_Clicked(_ sender: UIButton) {
        for connectedDevice in AppDelegate_.tempEargearDeviceActor {
            let deviceActor = connectedDevice
            AppDelegate_.centralManagerActor.centralManager?.cancelPeripheralConnection((deviceActor.peripheralActor.peripheral)!)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func LEDPatterns_Clicked(_ sender: UIButton) {
//        let deviceActor = AppDelegate_.eargearDeviceActor
        for connectedDevice in AppDelegate_.tempEargearDeviceActor {
            let deviceActor = connectedDevice
            if ((deviceActor.isDeviceIsReady) && (deviceActor.isConnected())) {
                switch sender.tag {
                case 0:
                    flickLeft()//flick left
                case 1:
                    flickRight()//flick right
                case 2:
                    earsWide() //ears wide
                case 3:
                    hewo()//hewo
                case 4:
                    leftListen()//left listen
                case 5:
                    rightListen()//right listen
                case 6:
                    doubleLeft()//double left
                case 7:
                    doubleRight()//double right
                default:
                    flickLeft()
                }
            }
        }
    }
    
    
    func flickLeft() {
        sendDeviceCommand(command: "LETWIST 30")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.sendDeviceCommand(command: "EARHOME")
        }
    }
    
    func flickRight() {
        sendDeviceCommand(command: "RITWIST 30")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.sendDeviceCommand(command: "EARHOME")
        }
    }
    
    func earsWide() {
        self.sendDeviceCommand(command: "BOTWIST 30")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.sendDeviceCommand(command: "EARHOME")
        }
    }
    func hewo() {
        sendDeviceCommand(command: "LETWIST 30")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.sendDeviceCommand(command: "RITWIST 30")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.sendDeviceCommand(command: "EARHOME")
            }
        }
    }
    
    func leftListen() {
        sendDeviceCommand(command: "LETWIST 20")
        self.sendDeviceCommand(command: "RITWIST 100")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.sendDeviceCommand(command: "EARHOME")
        }
    }
    
    func rightListen() {
        self.sendDeviceCommand(command: "RITWIST 20")
        sendDeviceCommand(command: "LETWIST 100")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.sendDeviceCommand(command: "EARHOME")
        }
    }
    
    func sendDeviceCommand(command: String) {
//        let deviceActor = AppDelegate_.eargearDeviceActor
        for connectedDevice in AppDelegate_.tempEargearDeviceActor {
            let deviceActor = connectedDevice
            if (deviceActor != nil && (deviceActor.isDeviceIsReady) && (deviceActor.isConnected())) {
                let data = Data(command.utf8)
                deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
            }
        }
    }
    
    func sendEarsHome() {
        self.sendDeviceCommand(command: "EARHOME")
    }
    
    func doubleLeft() {
        sendDeviceCommand(command: "LETWIST 20")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.sendDeviceCommand(command: "LETWIST 90")
            self.sendDeviceCommand(command: "LETWIST 20")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.sendDeviceCommand(command: "EARHOME")
            }
            
        }
    }
    
    func doubleRight() {
        sendDeviceCommand(command: "RITWIST 20")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.sendDeviceCommand(command: "RITWIST 90")
            self.sendDeviceCommand(command: "RITWIST 20")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.sendDeviceCommand(command: "EARHOME")
            }
            
        }
    }
    
    func sendRFlopper() {
        self.sendDeviceCommand(command: "RITILT 130")
        self.sendDeviceCommand(command: "RITWIST 30")
    }
    
    func sendLFlopper() {
        self.sendDeviceCommand(command: "LETILT 130")
        self.sendDeviceCommand(command: "LETWIST 30")
    }
    
}

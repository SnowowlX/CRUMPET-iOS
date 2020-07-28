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

class EarGearMovesVC: UIViewController{
    
    //MARK: - Properties
    
    
    @IBOutlet var lblTailDescription: UILabel!
    @IBOutlet var btnStop: UIButton!
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var btnLookForTails: UIButton!
    @IBOutlet var viewLEDPatternsDesc: UIView!
    @IBOutlet var viewLEDPatternsList: CardView!
    
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
        AppDelegate_.centralManagerActor.centralManager?.cancelPeripheralConnection((AppDelegate_.eargearDeviceActor?.peripheralActor.peripheral)!)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func LEDPatterns_Clicked(_ sender: UIButton) {
        let deviceActor = AppDelegate_.eargearDeviceActor
        if (deviceActor != nil && (deviceActor?.isDeviceIsReady)! && (deviceActor?.isConnected())!) {
            switch sender.tag {
            case 0:
                sendHewoL()
            case 1:
                sendHewoR()
            case 2:
                sendHewoTOO()
            case 3:
                sendConfused()
            case 4:
                sendZigZagL()
            case 5:
                sendZigZagR()
            case 6:
                sendEarsHome()
            case 7:
                sendEltwisto()
            case 8:
                sendRitwisto()
            case 9:
                sendRFlopper()
            case 10:
                sendLFlopper()
            default:
                sendHewoL()
            }
        }
    }
    
    func sendHewoL() {
        sendDeviceCommand(command: "LETILT 130")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.sendDeviceCommand(command: "LETILT 80")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.sendDeviceCommand(command: "EARHOME")
            }
        }
    }
    
    func sendHewoR() {
        sendDeviceCommand(command: "RITILT 130")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.sendDeviceCommand(command: "RITILT 80")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.sendDeviceCommand(command: "EARHOME")
            }
        }
    }
    
    func sendHewoTOO() {
        self.sendDeviceCommand(command: "BOTILT 130")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.sendDeviceCommand(command: "BOTILT 80")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.sendDeviceCommand(command: "EARHOME")
            }
        }
    }
    func sendConfused() {
        self.sendDeviceCommand(command: "BOTWIST 140")
    }
    
    func sendZigZagL() {
        self.sendDeviceCommand(command: "LETWIST 30")
        self.sendDeviceCommand(command: "LETILT 130")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.sendDeviceCommand(command: "RITWIST 130")
            self.sendDeviceCommand(command: "RITILT 130")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.sendDeviceCommand(command: "EARHOME")
                }
            }
        }
    }
    
    func sendZigZagR() {
        self.sendDeviceCommand(command: "LETWIST 130")
        self.sendDeviceCommand(command: "LETILT 130")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.sendDeviceCommand(command: "RITWIST 30")
            self.sendDeviceCommand(command: "RITILT 130")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.sendDeviceCommand(command: "EARHOME")
                }
            }
        }
    }
    
    func sendDeviceCommand(command: String) {
        let deviceActor = AppDelegate_.eargearDeviceActor
        if (deviceActor != nil && (deviceActor?.isDeviceIsReady)! && (deviceActor?.isConnected())!) {
            let data = Data(command.utf8)
            deviceActor?.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
        }
    }
    
    func sendEarsHome() {
        self.sendDeviceCommand(command: "EARHOME")
    }
    
    func sendEltwisto() {
        self.sendDeviceCommand(command: "LETWIST 30")
    }
    
    func sendRitwisto() {
        self.sendDeviceCommand(command: "RITWIST 30")
    }
    
    func sendRFlopper() {
        self.sendDeviceCommand(command: "RITILT 130")
        self.sendDeviceCommand(command: "RITWIST 30")
    }
    
    func sendLFlopper() {
        self.sendDeviceCommand(command: "LITILT 130")
        self.sendDeviceCommand(command: "LETWIST 30")
    }
    
}

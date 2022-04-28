//
//  SettingVC.swift
//  Digitail
//
//  Created by Iottive on 28/06/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
import SideMenu

class SettingVC: UIViewController {
    
    //MARK: - Properties
    @IBOutlet var viewInstruction: UIView!
    @IBOutlet var viewAutomaticReconnection: UIView!
    @IBOutlet var viewTailMoves: UIView!
    @IBOutlet var viewFailTails: UIView!
    @IBOutlet var viewFirmwareUpgrade: UIView!
    @IBOutlet var btnCheckBox: UIButton!
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet weak var lblInstuctionsTitle: UILabel!
    @IBOutlet weak var lblInstructionsDetails: UILabel!
    @IBOutlet weak var btnDigitalInstructions: UIButton!
    @IBOutlet weak var btnMiTailInstructions: UIButton!
    @IBOutlet weak var btnEarGearInstructions: UIButton!
    @IBOutlet weak var lblGearNames: UILabel!
    @IBOutlet weak var lblGearNameInstuctions: UILabel!
    
    @IBOutlet weak var lblFirmwareUpgrade: UILabel!
    @IBOutlet weak var btnForgetNames: UIButton!
    
    @IBOutlet weak var btnFirmwareUpgrade: UIButton!
    @IBOutlet weak var lblFirmwareUpgradeInstuctions: UILabel!
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainUI()
        setupLocalization()
    }
    
    //MARK: - Custom Function
    func setUpMainUI(){
        btnMenu.layer.cornerRadius = 5.0
        viewInstruction.layer.shadowColor = UIColor.darkGray.cgColor
        viewInstruction.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        viewInstruction.layer.shadowRadius = 2.5
        viewInstruction.layer.shadowOpacity = 0.5
        
        viewAutomaticReconnection.layer.shadowColor = UIColor.darkGray.cgColor
        viewAutomaticReconnection.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        viewAutomaticReconnection.layer.shadowRadius = 2.5
        viewAutomaticReconnection.layer.shadowOpacity = 0.5
        
        viewTailMoves.layer.shadowColor = UIColor.darkGray.cgColor
        viewTailMoves.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        viewTailMoves.layer.shadowRadius = 2.5
        viewTailMoves.layer.shadowOpacity = 0.5
        
        viewFailTails.layer.shadowColor = UIColor.darkGray.cgColor
        viewFailTails.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        viewFailTails.layer.shadowRadius = 2.5
        viewFailTails.layer.shadowOpacity = 0.5
        
        viewFirmwareUpgrade.layer.shadowColor = UIColor.darkGray.cgColor
        viewFirmwareUpgrade.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        viewFirmwareUpgrade.layer.shadowRadius = 2.5
        viewFirmwareUpgrade.layer.shadowOpacity = 0.5
    }
    
    func setupLocalization() {
        self.title = NSLocalizedString("kSettings", comment: "")
        lblInstuctionsTitle.text = NSLocalizedString("kInstructions", comment: "")
        lblInstructionsDetails.text = NSLocalizedString("KDownloadInstruction", comment: "")
        btnDigitalInstructions.setTitle(NSLocalizedString("kDigitalInstruction", comment: ""), for: .normal)
        btnMiTailInstructions.setTitle(NSLocalizedString("kMitailInstructions", comment: ""), for: .normal)
        btnEarGearInstructions.setTitle(NSLocalizedString("kEarGearInstructions", comment: ""), for: .normal)
        lblGearNames.text = NSLocalizedString("KGearNames", comment: "")
        lblGearNameInstuctions.text = NSLocalizedString("kGearStored", comment: "")
        lblFirmwareUpgrade.text = NSLocalizedString("kFirmwareUpgrade", comment: "")
        btnForgetNames.setTitle(NSLocalizedString("kForgetGearNames", comment: ""), for: .normal)
        btnFirmwareUpgrade.setTitle(NSLocalizedString("kFirmwareUpgrade", comment: ""), for: .normal)
        lblFirmwareUpgradeInstuctions.text = NSLocalizedString("kConnectedMiTail", comment: "")
    }
    
    //MARK: - Actions
    @IBAction func checkBox_Clicked(_ sender: UIButton) {
        if (btnCheckBox.isSelected == true)
        {
         btnCheckBox.setImage(nil, for: .normal)
         btnCheckBox.isSelected = false
        }
        else
        {
          btnCheckBox.setImage(UIImage(named: "check-mark (2)"), for: .normal)
            btnCheckBox.isSelected = true
        }
    }

    @IBAction func Menu_Clicked(_ sender: UIButton) {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func actionForget(_ sender: UIButton) {
        openAlertView()
    }
    
    @IBAction func actionFakeIt(_ sender: UIButton) {
        openAlertView()
    }
    
    @IBAction func actionDigitail(_ sender: UIButton) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WebKitViewVC") as! WebKitViewVC
        vc.urlToLoad = "https://thetailcompany.com/digitail.pdf"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionEarGear(_ sender: UIButton) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WebKitViewVC") as! WebKitViewVC
        vc.urlToLoad = "https://thetailcompany.com/eargear.pdf"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionMiTail(_ sender: UIButton) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WebKitViewVC") as! WebKitViewVC
        let locale = NSLocale.current.languageCode
        if locale == "ja" {
            vc.urlToLoad = "http://thetailcompany.com/mitailjp.pdf"
        } else {
            vc.urlToLoad = "https://thetailcompany.com/mitail.pdf"
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func openAlertView() {
        let alert = UIAlertController(title: NSLocalizedString("kSettings", comment: ""), message: NSLocalizedString("kComingSoon", comment: ""), preferredStyle: UIAlertController.Style.alert)
        //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: kAlertActionOK, style: .default, handler:{ (UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
            ///print("User click Ok button")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func actionFirmwareUpgrade(_ sender: UIButton) {
        var deviceActor:BLEActor?
        for connectedDevices in AppDelegate_.tempDigitailDeviceActor {
            if ((connectedDevices.isDeviceIsReady) && ((connectedDevices.isConnected()))) {
                if (connectedDevices.isMitail) {
                    deviceActor = connectedDevices
                }
            }
        }
        if (deviceActor != nil) {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "FirmwareUpdateVC") as! FirmwareUpdateVC
            vc.connectedDeviceActor = deviceActor
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            showAlert(alertTitle: kTitleConnect, message: kMsgConnect, vc: self)
        }
        
    }
    
}

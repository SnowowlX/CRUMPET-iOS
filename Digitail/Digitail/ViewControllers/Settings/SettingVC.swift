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
    @IBOutlet weak var viewEG2FirmwareUpgrade: UIView!
    @IBOutlet weak var viewFlutterFirmwareUpgrade: UIView!
    @IBOutlet var btnCheckBox: UIButton!
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet weak var lblInstuctionsTitle: UILabel!
    @IBOutlet weak var lblInstructionsDetails: UILabel!
    @IBOutlet weak var btnDigitalInstructions: UIButton!
    @IBOutlet weak var btnMiTailInstructions: UIButton!
    @IBOutlet weak var btnEarGearInstructions: UIButton!
    @IBOutlet weak var btnFlutterInstructions: UIButton!
    @IBOutlet weak var lblGearNames: UILabel!
    @IBOutlet weak var lblGearNameInstuctions: UILabel!
    
    @IBOutlet weak var lblFirmwareUpgrade: UILabel!
    @IBOutlet weak var lblEG2FirmwareUpgrade: UILabel!
    @IBOutlet weak var lblFlutterFirmwareUpgrade: UILabel!
    @IBOutlet weak var btnForgetNames: UIButton!
    
    @IBOutlet weak var btnFirmwareUpgrade: UIButton!
    
    @IBOutlet weak var lblFirmwareUpgradeInstuctions: UILabel!

    @IBOutlet weak var btnEG2FirmwareUpgrade: UIButton!
    @IBOutlet weak var lblEG2FirmwareUpgradeInstructions: UILabel!
    @IBOutlet weak var eg2FWViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnFlutterFirmwareUpgrade: UIButton!
    @IBOutlet weak var lblFlutterFirmwareUpgradeInstructions: UILabel!
    @IBOutlet weak var FlutterFWViewTopConstraint: NSLayoutConstraint!

    
    var latestTailFWVersion: Int = 0
    var latestEGFWVersion: Int = 0
    var latestEGFWVersionB: Int = 0
    
    var latestFlutterFWVersion: Int = 0

    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainUI()
        setupLocalization()
    }
    
    //MARK: - Custom Function
    func setUpMainUI(){
        
        btnDigitalInstructions.isHidden = true
        
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
        
        viewEG2FirmwareUpgrade.layer.shadowColor = UIColor.darkGray.cgColor
        viewEG2FirmwareUpgrade.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        viewEG2FirmwareUpgrade.layer.shadowRadius = 2.5
        viewEG2FirmwareUpgrade.layer.shadowOpacity = 0.5
        
        viewFlutterFirmwareUpgrade.layer.shadowColor = UIColor.darkGray.cgColor
        viewFlutterFirmwareUpgrade.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        viewFlutterFirmwareUpgrade.layer.shadowRadius = 2.5
        viewFlutterFirmwareUpgrade.layer.shadowOpacity = 0.5

        
        viewFirmwareUpgrade.isHidden = true
        viewEG2FirmwareUpgrade.isHidden = true
        viewFlutterFirmwareUpgrade.isHidden = true

        DispatchQueue.global().async {
            self.latestTailFWVersion = self.getFirmwareVersionFrom(text: self.getLatestTailFWVersionFromServer())
            self.latestEGFWVersion = self.getFirmwareVersionFrom(text: self.getLatestEarGearFWVersionFromServer())
            self.latestEGFWVersionB = self.getFirmwareVersionFrom(text: self.getLatestEarGearFWVersionBFromServer())
            self.latestFlutterFWVersion = self.getFirmwareVersionFrom(text: self.getLatestFlutterFWVersionFromServer())

            print("latest tail fw version = \(self.latestTailFWVersion), eg fw version = \(self.latestEGFWVersion), eg-b - \(self.latestEGFWVersionB), flutter fw version = \(self.latestFlutterFWVersion)")
            DispatchQueue.main.async {
                self.checkFWVersions()
            }
        }
    }
    
    func checkFWVersions() {
        // check if tail connected
        
        if let connectedMiTail = getConnectedMiTail() {
            // get current FW version
            if let currentFWVersion = connectedMiTail.state["FirmwareVersion"] as? String {
                viewFirmwareUpgrade.isHidden = false
                if getFirmwareVersionFrom(text: currentFWVersion.trimmingCharacters(in: .whitespaces)) == latestTailFWVersion {
                    // already have the latest FW
                    btnFirmwareUpgrade.isEnabled = false
                    btnFirmwareUpgrade.alpha = 0.5
                    lblFirmwareUpgradeInstuctions.text = NSLocalizedString("kLatestFirmware", comment: "")
                }
            } else {
                // can't get the current firmware version of connected MiTail device
                
            }
        } else {
            viewFirmwareUpgrade.isHidden = true
        }
        
        // check if EG has connected
        if let connectedEG = getConnectedEG() {
            
            if getConnectedMiTail() == nil{
                eg2FWViewTopConstraint.constant = -151.5
            }
            
            // get EG fw version
            if let currentFWVersion = connectedEG.state["FirmwareVersion"] as? String {
                if currentFWVersion.hasSuffix("b") {
                    self.latestEGFWVersion = self.latestEGFWVersionB
                }
                
                viewEG2FirmwareUpgrade.isHidden = false
                if getFirmwareVersionFrom(text: currentFWVersion.trimmingCharacters(in: .whitespaces)) == latestEGFWVersion {
                    // already have the latest FW
                    btnEG2FirmwareUpgrade.isEnabled = false
                    btnEG2FirmwareUpgrade.alpha = 0.5
                    lblEG2FirmwareUpgradeInstructions.text = NSLocalizedString("kLatestFirmware", comment: "")
                }
            } else {
                // can't get the current firmware version of connected EG device
                
            }
        } else {
            viewEG2FirmwareUpgrade.isHidden = true
        }
        
        // check if Flutter has connected
        if let connectedFlutter = getConnectedFlutter() {
            if getConnectedMiTail() == nil && getConnectedEG() == nil {
                FlutterFWViewTopConstraint.constant = -303
            }
            
            // get current FW version
            if let currentFWVersion = connectedFlutter.state["FirmwareVersion"] as? String {
                viewFlutterFirmwareUpgrade.isHidden = false
                if getFirmwareVersionFrom(text: currentFWVersion.trimmingCharacters(in: .whitespaces)) == latestFlutterFWVersion {
                    // already have the latest FW
                    btnFlutterFirmwareUpgrade.isEnabled = false
                    btnFlutterFirmwareUpgrade.alpha = 0.5
                    lblFlutterFirmwareUpgradeInstructions.text = NSLocalizedString("kLatestFirmware", comment: "")
                }
            } else {
                // can't get the current firmware version of connected MiTail device
                
            }
        } else {
            viewFlutterFirmwareUpgrade.isHidden = true
        }
    }
    
    func getConnectedMiTail() -> BLEActor? {
        var deviceActor:BLEActor?
        for connectedDevices in AppDelegate_.tempDigitailDeviceActor {
            if ((connectedDevices.isDeviceIsReady) && ((connectedDevices.isConnected()))) {
                if (connectedDevices.bleDeviceType == .mitail) {
                    deviceActor = connectedDevices
                    break
                }
            }
        }
        
        return deviceActor
    }
    
    func getConnectedEG() -> BLEActor? {
        var deviceActor:BLEActor?
        for connectedDevices in AppDelegate_.tempEargearDeviceActor {
            if ((connectedDevices.isDeviceIsReady) && ((connectedDevices.isConnected()))) {
                if (connectedDevices.bleDeviceType == .eg2) {
                    deviceActor = connectedDevices
                    break
                }
            }
        }
        
        return deviceActor
    }
    
    func getConnectedFlutter() -> BLEActor? {
        var deviceActor:BLEActor?
        for connectedDevices in AppDelegate_.tempFlutterDeviceActor {
            if ((connectedDevices.isDeviceIsReady) && ((connectedDevices.isConnected()))) {
                if (connectedDevices.bleDeviceType == .flutter) {
                    deviceActor = connectedDevices
                    break
                }
            }
        }
        
        return deviceActor
    }
    
    func setupLocalization() {
        self.title = NSLocalizedString("kSettings", comment: "")
        lblInstuctionsTitle.text = NSLocalizedString("kInstructions", comment: "")
        lblInstructionsDetails.text = NSLocalizedString("KDownloadInstruction", comment: "")
        btnDigitalInstructions.setTitle(NSLocalizedString("kDigitalInstruction", comment: ""), for: .normal)
        btnMiTailInstructions.setTitle(NSLocalizedString("kMitailInstructions", comment: ""), for: .normal)
        btnEarGearInstructions.setTitle(NSLocalizedString("kEarGearInstructions", comment: ""), for: .normal)
        btnFlutterInstructions.setTitle(NSLocalizedString("kFlutterInstructions", comment: ""), for: .normal)
        lblGearNames.text = NSLocalizedString("KGearNames", comment: "")
        lblGearNameInstuctions.text = NSLocalizedString("kGearStored", comment: "")
        lblFirmwareUpgrade.text = NSLocalizedString("kFirmwareUpgrade", comment: "")
        lblEG2FirmwareUpgrade.text = NSLocalizedString("kEG2FirmwareUpgrade", comment: "")
        lblFlutterFirmwareUpgrade.text = NSLocalizedString("kFlutterFirmwareUpgrade", comment: "")
        btnForgetNames.setTitle(NSLocalizedString("kForgetGearNames", comment: ""), for: .normal)
        btnFirmwareUpgrade.setTitle(NSLocalizedString("kFirmwareUpgrade", comment: ""), for: .normal)
        btnEG2FirmwareUpgrade.setTitle(NSLocalizedString("kEG2FirmwareUpgrade", comment: ""), for: .normal)
        btnFlutterFirmwareUpgrade.setTitle(NSLocalizedString("kFlutterFirmwareUpgrade", comment: ""), for: .normal)
        lblFirmwareUpgradeInstuctions.text = NSLocalizedString("kConnectedMiTail", comment: "")
        lblEG2FirmwareUpgradeInstructions.text = NSLocalizedString("kConnectedEG2", comment: "")
        lblFlutterFirmwareUpgradeInstructions.text = NSLocalizedString("kConnectedFlutter", comment: "")
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
    
    @IBAction func actionWagging(_ sender: Any) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WebKitViewVC") as! WebKitViewVC
        vc.urlToLoad = "https://thetailcompany.com/responsiblewagging.pdf"
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    @IBAction func actionFlutter(_ sender: UIButton) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WebKitViewVC") as! WebKitViewVC
        vc.urlToLoad = "https://thetailcompany.com/flutterwings.pdf"
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
    
    //MARK:- TO GET LATEST FIRMWARE VERSION FROM SERVER -
    func getLatestTailFWVersionFromServer() -> String {
        var latestFWVersion : String = ""
        let myURLString = "https://thetailcompany.com/fw/mitail"
        if let myURL = NSURL(string: myURLString) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                print("html \(myHTMLString)")
                let dictionary = convertStringToDictionary(text: myHTMLString as String)
                
                latestFWVersion = dictionary?["version"] as! String
                
            } catch {
                print(error)
            }
        }
        return latestFWVersion
    }
    
    func getLatestEarGearFWVersionBFromServer() -> String {
        var latestFWVersion : String = ""
        let myURLString = "https://thetailcompany.com/fw/eargear-b"
        if let myURL = NSURL(string: myURLString) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                print("html \(myHTMLString)")
                let dictionary = convertStringToDictionary(text: myHTMLString as String)
                
                latestFWVersion = dictionary?["version"] as! String
            } catch {
                print(error)
            }
        }
        return latestFWVersion
    }
    
    func getLatestEarGearFWVersionFromServer() -> String {
        var latestFWVersion : String = ""
        let myURLString = "https://thetailcompany.com/fw/eargear"
        if let myURL = NSURL(string: myURLString) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                print("html \(myHTMLString)")
                let dictionary = convertStringToDictionary(text: myHTMLString as String)
                
                latestFWVersion = dictionary?["version"] as! String
            } catch {
                print(error)
            }
        }
        return latestFWVersion
    }

    
    func getLatestFlutterFWVersionFromServer() -> String {
        var latestFWVersion : String = ""
        let myURLString = "https://thetailcompany.com/fw/flutter"
        if let myURL = NSURL(string: myURLString) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                print("html \(myHTMLString)")
                let dictionary = convertStringToDictionary(text: myHTMLString as String)
                
                latestFWVersion = dictionary?["version"] as! String
            } catch {
                print(error)
            }
        }
        return latestFWVersion
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    func getFirmwareVersionFrom(text: String) -> Int {
        let array = text.components(separatedBy: " ")
        if array.count > 1 {
            let arrayOfVer = array.last?.components(separatedBy: ".")
            if arrayOfVer?.count == 3 {
                let firstComponent = arrayOfVer?.first
                var lastComponent = arrayOfVer?.last
                
                if let last = lastComponent, last.hasSuffix("b") {
                    lastComponent = String(last.dropLast())
                }
                
                let middelComponent = arrayOfVer?[1]
                let stringOfVersion = "\(firstComponent ?? "0")\(middelComponent ?? "0")\(lastComponent ?? "0")"
                return Int(stringOfVersion) ?? 0
            }
        }
        return 0
    }
    
    @IBAction func actionEG2FirmwareUpgrade(_ sender: Any) {
        /*
        let alertController = UIAlertController(title: nil, message: "Coming soon", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
        
        return
        */
        var deviceActor:BLEActor?
        for connectedDevices in AppDelegate_.tempEargearDeviceActor {
            if ((connectedDevices.isDeviceIsReady) && ((connectedDevices.isConnected()))) {
                if (connectedDevices.bleDeviceType == .eg2) {
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
    
    @IBAction func actionFirmwareUpgrade(_ sender: UIButton) {
        var deviceActor:BLEActor?
        for connectedDevices in AppDelegate_.tempDigitailDeviceActor {
            if ((connectedDevices.isDeviceIsReady) && ((connectedDevices.isConnected()))) {
                if (connectedDevices.bleDeviceType == .mitail) {
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
    
    @IBAction func actionFlutterFirmwareUpgrade(_ sender: Any) {
        /*
        let alertController = UIAlertController(title: nil, message: "Coming soon", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
        
        return
        */
        var deviceActor:BLEActor?
        for connectedDevices in AppDelegate_.tempFlutterDeviceActor {
            if ((connectedDevices.isDeviceIsReady) && ((connectedDevices.isConnected()))) {
                if (connectedDevices.bleDeviceType == .flutter) {
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

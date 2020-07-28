//
//  TailMovesVC.swift
//  Digitail
//
//  Created by Iottive on 11/06/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
import JTMaterialSpinner
import CoreBluetooth
import SideMenu

let kSearchingForDigitail = "Searching for DIGITAiL..."
let kSearchingForEarGear = "Searching for EARGEAR..."
let kNoneFoundYet = "None found yet..."
let kOneTailFound = "One Tail Found"
let kOneEarGearFound = "Gear Found"
let kNotConnected = "You are not currently connected to your tail, but we know of one tail. Push \"Connect\" to connect to it."
let kNotConnectedEarGear = "You are not currently connected to your EARGEAR, but we know of one EARGEAR. Push \"Connect\" to connect to it."
let kConnected = "You are currently connected to your tail"
let kConnectedEARGEAR = "You are currently connected to your EARGEAR"
let kNoTailsFound = "No tails found"
let kNoEARGEARFound = "No EARGEAR found"
let kOneTailAvailble = "One tail available"
let kOneEARGEARAvailble = "One EARGEAR available"
let kDigitailTitle = "Connect DIGITAiL"
let kEarGearTitle = "Connect EARGEAR"
let kDigitailSearchButton = "LOOK FOR TAILS"
let kEarGearSearchButton = "LOOK FOR EARGEARS"
let kDigitailNotFound = "We were unable to find your Tail. Please ensure that it is nearby and switched on"
let kEarGearNotFound = "We were unable to find your EARGEAR. Please ensure that it is nearby and switched on"

class ConnectVC: UIViewController{
   
    //MARK: - Properties
    @IBOutlet weak var viewTailMovesDesc: UIView!
    @IBOutlet weak var viewFindGetTail: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var viewActivityIndicator: JTMaterialSpinner!
    @IBOutlet weak var lblSearchingForDigitail: UILabel!
    @IBOutlet weak var lblDigitailDesc: UILabel!
    @IBOutlet weak var btnCntOrLookForDigitail: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    var isForDigitail = true
    
    
     //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainUI()
        //Register for Bluetooth State Updates
        RegisterForNote(#selector(TailMovesVC.DeviceIsReady(_:)),kDeviceIsReady, self)
        RegisterForNote(#selector(TailMovesVC.DeviceDisconnected(_:)),kDeviceDisconnected, self)
        
        if isForDigitail {
            self.title = kDigitailTitle
        } else {
            self.title = kEarGearTitle
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewActivityIndicator.isHidden = false
        self.viewActivityIndicator.beginRefreshing()
        self.btnCntOrLookForDigitail.isHidden = true
        self.lblSearchingForDigitail.text = (isForDigitail) ? kSearchingForDigitail : kSearchingForEarGear
        self.lblDigitailDesc.text = kNoneFoundYet
        self.startScan()
    }

    
    //MARK: - Custome Function
    func setUpMainUI(){
        btnMenu.layer.cornerRadius = 5.0

        viewActivityIndicator.circleLayer.lineWidth = 3.0
        viewActivityIndicator.circleLayer.strokeColor = UIColor(red: 96/255, green: 125/255, blue: 138/255, alpha: 1.0).cgColor
        viewActivityIndicator.beginRefreshing()

        viewFindGetTail.layer.shadowColor = UIColor.darkGray.cgColor
        viewFindGetTail.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        viewFindGetTail.layer.shadowRadius = 2.5
        viewFindGetTail.layer.shadowOpacity = 0.5
        
        viewTailMovesDesc.layer.shadowColor = UIColor.darkGray.cgColor
        viewTailMovesDesc.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        viewTailMovesDesc.layer.shadowRadius = 1.7
        viewTailMovesDesc.layer.shadowOpacity = 0.5
        
        viewTailMovesDesc.isHidden = true
        btnCntOrLookForDigitail.isHidden = true
        
        btnStop.layer.cornerRadius = btnStop.frame.height/2.0
        btnStop.clipsToBounds = true
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
        self.present(alert, animated: true, completion: nil)
    }
    
    //Start Scan Method
    func startScan() {
        AppDelegate_.startScan()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if (self.isForDigitail && AppDelegate_.digitailPeripheral == nil) || (!self.isForDigitail && AppDelegate_.eargearPeripheral == nil){
                self.viewActivityIndicator.isHidden = true
                self.btnCntOrLookForDigitail.isHidden = false
                if self.isForDigitail {
                    self.btnCntOrLookForDigitail.setTitle(kDigitailSearchButton, for: .normal)
                } else {
                    self.btnCntOrLookForDigitail.setTitle(kEarGearSearchButton, for: .normal)
                }
                
                self.lblSearchingForDigitail.text = (self.isForDigitail) ? kNoTailsFound : kNoEARGEARFound
                self.lblDigitailDesc.text = (self.isForDigitail) ? kDigitailNotFound : kEarGearNotFound
                self.viewFindGetTail.isHidden = false
                self.viewTailMovesDesc.isHidden = true
            }
            else{
                self.viewActivityIndicator.isHidden = true
                self.btnCntOrLookForDigitail.isHidden = false
                if self.isForDigitail {
                    self.btnCntOrLookForDigitail.setTitle(kDigitailTitle, for: .normal)
                    self.lblSearchingForDigitail.text = kOneTailFound
                } else {
                    self.btnCntOrLookForDigitail.setTitle(kEarGearTitle, for: .normal)
                    self.lblSearchingForDigitail.text = kOneTailFound
                }
                
                self.lblDigitailDesc.text = kNotConnected
                self.viewFindGetTail.isHidden = false
            }
        }
    }
    
    //MARK: - Actions
    @IBAction func Menu_clicked(_ sender: UIButton) {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func ConnectLookForDigitail_Clicked(_ sender: UIButton) {
         if (self.isForDigitail && AppDelegate_.digitailPeripheral == nil) || (!self.isForDigitail && AppDelegate_.eargearPeripheral == nil) {
            self.viewActivityIndicator.isHidden = false
            self.viewActivityIndicator.beginRefreshing()
            btnCntOrLookForDigitail.isHidden = true
            self.lblSearchingForDigitail.text = (self.isForDigitail) ? kSearchingForDigitail : kSearchingForEarGear
            self.lblDigitailDesc.text = kNoneFoundYet
            AppDelegate_.isScanning = true
            self.startScan()
        }
        else {
            if (self.isForDigitail && AppDelegate_.digitailPeripheral != nil) {
                connectDevice(device: AppDelegate_.digitailPeripheral!)
            } else if (!self.isForDigitail && AppDelegate_.eargearPeripheral != nil) {
                connectDevice(device: AppDelegate_.eargearPeripheral!)
            }
            
            self.viewActivityIndicator.isHidden = false
            self.viewActivityIndicator.beginRefreshing()
            self.lblSearchingForDigitail.text = (self.isForDigitail) ? kOneTailAvailble : kOneEarGearFound
            self.lblDigitailDesc.text = kNotConnected
        }
    }
   
    @objc func DeviceIsReady(_ note: Notification) {
        self.viewActivityIndicator.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func DeviceDisconnected(_ note: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
        }
    }
    
    func connectDevice(device: DeviceModel) {
        self.view.bringSubviewToFront(viewActivityIndicator)
        self.viewActivityIndicator.isHidden = false
        AppDelegate_.centralManagerActor.add(device.peripheral)
    }
    
}

     

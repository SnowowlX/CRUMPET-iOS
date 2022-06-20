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

class GlowTipsVC: UIViewController{
    
    //MARK: - Properties
    @IBOutlet var lblSearchingDigitail: UILabel!
    @IBOutlet var viewActivityIndicator: JTMaterialSpinner!
    @IBOutlet var lblTailDescription: UILabel!
    @IBOutlet var viewFindGetTails: UIView!
    @IBOutlet var btnStop: UIButton!
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var btnLookForTails: UIButton!
    @IBOutlet var viewLEDPatternsDesc: UIView!
    @IBOutlet var viewLEDPatternsList: CardView!
    let arrLEDPatterns = ["LEDREC","LEDTRI","LEDSAW","LEDSES","LEDBEA","LEDFLA","LEDSTR"]
   //  let arrLEDPatterns = ["BLINK","TRIANGLE","SAWTOOTH","MORSE","BEACON","FLAME","STROBE"]
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewFindGetTails.isHidden = true
        self.viewLEDPatternsDesc.isHidden = false
        self.viewLEDPatternsList.isHidden = false
        
        if AppDelegate_.deviceActors.count > 0 {
            updateConnectionUI()
        } /*else if AppDelegate_.isScanning == true && AppDelegate_.peripheralList.count == 0 {
            self.viewActivityIndicator.isHidden = false
            self.viewActivityIndicator.beginRefreshing()
            self.btnLookForTails.isHidden = true
            self.lblSearchingDigitail.text = kSearchingForDigitail
            self.lblTailDescription.text = kNoneFoundYet
            self.startScan()
        } else if AppDelegate_.isScanning == false && AppDelegate_.peripheralList.count != 0 {
            self.btnLookForTails.isHidden = false
            self.btnLookForTails.setTitle("CONNECT", for: .normal)
            self.lblSearchingDigitail.text = kOneTailFound
            self.lblTailDescription.text = kNotConnected
            self.viewLEDPatternsDesc.isHidden = true
            self.viewFindGetTails.isHidden = false
            self.viewLEDPatternsList.isHidden = true
            self.viewActivityIndicator.isHidden = true
        } else if AppDelegate_.isScanning == false {
            self.btnLookForTails.setTitle("LOOK FOR TAILS", for: .normal)
            self.lblSearchingDigitail.text = kNoTailsFound
            self.lblTailDescription.text = "We were unable to find your Tail. Please ensure that it is nearby and switched on"
            self.viewActivityIndicator.isHidden = true
            self.btnLookForTails.isHidden = false
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.startScan()
            }
        }*/
    }
    
    //MARK: - Custom Function
    func setUpMainUI(){
      RegisterForNote(#selector(GlowTipsVC.DeviceIsReady(_:)),kDeviceIsReady, self)
      RegisterForNote(#selector(GlowTipsVC.DeviceDisconnected(_:)),kDeviceDisconnected, self)
        btnMenu.layer.cornerRadius = 5.0
        
        viewLEDPatternsList.isHidden = true
     
        viewFindGetTails.layer.shadowColor = UIColor.darkGray.cgColor
        viewFindGetTails.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        viewFindGetTails.layer.shadowRadius = 2.5
        viewFindGetTails.layer.shadowOpacity = 0.5
       // viewFindGetTails.isHidden = false
        
        viewLEDPatternsDesc.layer.shadowColor = UIColor.darkGray.cgColor
        viewLEDPatternsDesc.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        viewLEDPatternsDesc.layer.shadowRadius = 4.5
        viewLEDPatternsDesc.layer.shadowOpacity = 0.5
        viewLEDPatternsDesc.isHidden = true
        
        btnStop.layer.cornerRadius = btnStop.frame.height/2.0
        btnStop.clipsToBounds = true
        
        viewActivityIndicator.circleLayer.lineWidth = 3.0
        viewActivityIndicator.circleLayer.strokeColor = UIColor(red: 96/255, green: 125/255, blue: 138/255, alpha: 1.0).cgColor
        viewActivityIndicator.beginRefreshing()
    }
    
    //Start Scan Method
    func startScan() {
        AppDelegate_.startScan()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if AppDelegate_.peripheralList.count == 0 {
                self.viewActivityIndicator.isHidden = true
                self.btnLookForTails.isHidden = false
                self.btnLookForTails.setTitle("SEARCH", for: .normal)
                self.lblSearchingDigitail.text = kNoTailsFound
                self.lblTailDescription.text = "We were unable to find your Tail. Please ensure that it is nearby and switched on"
                self.viewFindGetTails.isHidden = false
                self.viewLEDPatternsDesc.isHidden = true
                self.viewLEDPatternsList.isHidden = true
            }
            else{
                self.viewActivityIndicator.isHidden = true
                self.btnLookForTails.isHidden = false
                self.btnLookForTails.setTitle("CONNECT", for: .normal)
                self.lblSearchingDigitail.text = kOneTailFound
                self.lblTailDescription.text = kNotConnected
                self.viewFindGetTails.isHidden = true
                self.viewLEDPatternsDesc.isHidden = false
                self.viewLEDPatternsList.isHidden = false
            }
        }
    }
    
    func updateConnectionUI() {
        let deviceActor = AppDelegate_.deviceActors.first
        if (deviceActor?.peripheralActor != nil && (deviceActor?.isConnected())!) {
            self.viewFindGetTails.isHidden = true
            self.viewLEDPatternsDesc.isHidden = false
            self.viewLEDPatternsList.isHidden = false
        } else {
            /*
            self.viewActivityIndicator.isHidden = true
            self.btnLookForTails.isHidden = false
            self.btnLookForTails.setTitle("CONNECT", for: .normal)
            self.lblSearchingDigitail.text = kOneTailFound
            self.lblTailDescription.text = kNotConnected
            self.viewFindGetTails.isHidden = false
            self.viewLEDPatternsDesc.isHidden = true
            self.viewLEDPatternsList.isHidden = true
             */
        }
    }
    
    func connectDevice(device: DeviceModel) {
        self.view.bringSubviewToFront(viewActivityIndicator)
        self.viewActivityIndicator.isHidden = false
        AppDelegate_.centralManagerActor.add(device.peripheral)
    }
    
    @objc func DeviceIsReady(_ note: Notification) {
        let actor = note.object as! BLEActor
        self.viewActivityIndicator.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateConnectionUI()
        }
    }
    
    @objc func DeviceDisconnected(_ note: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateConnectionUI()
        }
    }
    
    func openAlertView() {
        let alert = UIAlertController(title: NSLocalizedString("kGlowTipsTitle", comment: ""), message: NSLocalizedString("kComingSoon", comment: ""), preferredStyle: UIAlertController.Style.alert)
        //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: kAlertActionOK, style: .default, handler:{ (UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
            ///print("User click Ok button")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Actions
    @IBAction func LookForTails_Clicked(_ sender: UIButton) {
        if AppDelegate_.peripheralList.count == 0 {
            self.viewActivityIndicator.isHidden = false
            self.viewActivityIndicator.beginRefreshing()
            btnLookForTails.isHidden = true
            self.lblSearchingDigitail.text = kSearchingForDigitail
            self.lblTailDescription.text = kNoneFoundYet
            AppDelegate_.isScanning = true
            self.startScan()
        }
        else{
            connectDevice(device: AppDelegate_.peripheralList.first!)
            self.btnLookForTails.setTitle("CONNECT", for: .normal)
            self.lblSearchingDigitail.text = kOneTailAvailble
            self.lblTailDescription.text = kNotConnected
        }
    }
    
    @IBAction func Menu_Clicked(_ sender: UIButton) {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func Stop_Clicked(_ sender: UIButton) {
    }
    
    @IBAction func LEDPatterns_Clicked(_ sender: UIButton) {
//        let deviceActor = AppDelegate_.digitailDeviceActor
        
        for connectedDevices in AppDelegate_.tempDigitailDeviceActor {
            let deviceActor = connectedDevices
            if (deviceActor.isDeviceIsReady) && (deviceActor.isConnected()) {
                let ledPatternString = arrLEDPatterns[sender.tag]
                let data = Data(ledPatternString.utf8)
                deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]))
            }
        }
    }
}

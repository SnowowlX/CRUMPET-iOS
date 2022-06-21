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


class TailMovesVC: UIViewController{
   
    //MARK: - Properties
    @IBOutlet weak var viewTailMovesDesc: UIView!
    @IBOutlet weak var viewFindGetTail: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var viewActivityIndicator: JTMaterialSpinner!
    @IBOutlet weak var lblSearchingForDigitail: UILabel!
    @IBOutlet weak var lblDigitailDesc: UILabel!
    @IBOutlet weak var btnCntOrLookForDigitail: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var viewMoves: UIView!
    var indexPathForOpr : Int!

    @IBOutlet weak var lblCalmRelaxed: UILabel!
    @IBOutlet weak var btnSlowWag1: UIButton!
    @IBOutlet weak var btnSlowWag2: UIButton!
    @IBOutlet weak var btnSlowWag3: UIButton!
    @IBOutlet weak var lblFastExcited: UILabel!
    @IBOutlet weak var btnFastWag: UIButton!
    @IBOutlet weak var btnShortWag: UIButton!
    @IBOutlet weak var btnHappyWag: UIButton!
    @IBOutlet weak var btnStandUp: UIButton!
    @IBOutlet weak var lblFrustrated: UILabel!
    @IBOutlet weak var btnTremble1: UIButton!
    @IBOutlet weak var btnTremble2: UIButton!
    @IBOutlet weak var btnErect: UIButton!
    @IBOutlet weak var btnHighWag: UIButton!
    
    
    let arrTailMoves = ["TAILS1","TAILS2","TAILS3","TAILFA","TAILSH","TAILHA","TAILER","TAILT1","TAILT2","TAILET","TAILEP"]
    
    let arrHomePosition = ["Slow wag 1","Slow wag 2","Slow wag 3","Fast wag","Short wag","Happy wag","ERect","Erect Pulse","Tremble 1","Tremble 2","Erect Trem"]
    
    
     //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainUI()
        setupLocalization()
        //Register for Bluetooth State Updates
        RegisterForNote(#selector(TailMovesVC.DeviceIsReady(_:)),kDeviceIsReady, self)
        RegisterForNote(#selector(TailMovesVC.DeviceDisconnected(_:)),kDeviceDisconnected, self)
        RegisterForNote(#selector(self.DeviceDidUpdateProperty(_:)), kDeviceDidUpdateProperty, self)        
    }
    
    func checkCasualModeIsOn() {
        if AppDelegate_.casualONDigitail || AppDelegate_.walkModeOn || AppDelegate_.moveOn {
            // already started
            [btnSlowWag1, btnSlowWag2, btnSlowWag3, btnFastWag, btnShortWag, btnHappyWag, btnStandUp, btnTremble1, btnTremble2, btnErect, btnHighWag].forEach({
                $0?.isEnabled = false
                $0?.alpha = 0.5
            })
        } else {
            [btnSlowWag1, btnSlowWag2, btnSlowWag3, btnFastWag, btnShortWag, btnHappyWag, btnStandUp, btnTremble1, btnTremble2, btnErect, btnHighWag].forEach({
                $0?.isEnabled = true
                $0?.alpha = 1.0
            })
        }
    }
    
    func setupLocalization()  {
        self.title = NSLocalizedString("kTail Moves", comment: "")
        lblCalmRelaxed.text = NSLocalizedString("kCalmAndRelaxed", comment: "")
        btnSlowWag1.setTitle(NSLocalizedString("kSlowwag1", comment: ""), for: .normal)
        btnSlowWag2.setTitle(NSLocalizedString("kSlowwag2", comment: ""), for: .normal)
        btnSlowWag3.setTitle(NSLocalizedString("kSlowwag3", comment: ""), for: .normal)
        lblFastExcited.text = NSLocalizedString("kFastAndExcited", comment: "")
        btnFastWag.setTitle(NSLocalizedString("kFastWag", comment: ""), for: .normal)
        btnShortWag.setTitle(NSLocalizedString("kShortWag", comment: ""), for: .normal)
        btnHappyWag.setTitle(NSLocalizedString("kHappyWag", comment: ""), for: .normal)
        btnStandUp.setTitle(NSLocalizedString("kStandUp!", comment: ""), for: .normal)
        lblFrustrated.text = NSLocalizedString("kFrustratedAndTense", comment: "")
        btnTremble1.setTitle(NSLocalizedString("kTremble1", comment: ""), for: .normal)
        btnTremble2.setTitle(NSLocalizedString("kTremble2", comment: ""), for: .normal)
        btnErect.setTitle(NSLocalizedString("kTrembleErect", comment: ""), for: .normal)
        btnHighWag.setTitle(NSLocalizedString("kHighWag", comment: ""), for: .normal)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateConnectionUI()
        checkCasualModeIsOn()
    }

    func updateConnectionUI() {
//        let deviceActor = AppDelegate_.digitailDeviceActor

        for connectedDevices in AppDelegate_.tempDigitailDeviceActor {
            let deviceActor = connectedDevices
            if (deviceActor.peripheralActor != nil && (deviceActor.isConnected())) {
                self.viewFindGetTail.isHidden = true
                self.viewTailMovesDesc.isHidden = false
                self.viewMoves.isHidden = false
            } else {
                self.viewActivityIndicator.isHidden = true
                self.btnCntOrLookForDigitail.isHidden = false
                self.btnCntOrLookForDigitail.setTitle("CONNECT", for: .normal)
                self.lblSearchingForDigitail.text = kOneTailFound
                self.lblDigitailDesc.text = kNotConnected
                self.viewFindGetTail.isHidden = true
                self.viewTailMovesDesc.isHidden = false
                self.viewMoves.isHidden = false
            }
        }
    }
    
    //MARK: - Custome Function
    func setUpMainUI(){
        btnMenu.layer.cornerRadius = 5.0

        viewActivityIndicator.circleLayer.lineWidth = 3.0
        viewActivityIndicator.circleLayer.strokeColor = UIColor(red: 96/255, green: 125/255, blue: 138/255, alpha: 1.0).cgColor
        viewActivityIndicator.beginRefreshing()

        viewMoves.isHidden = true
        
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
        
        if AppDelegate_.isScanning == true {
            self.viewActivityIndicator.isHidden = false
            self.viewActivityIndicator.beginRefreshing()
            self.btnCntOrLookForDigitail.isHidden = true
            self.lblSearchingForDigitail.text = kSearchingForDigitail
            self.lblDigitailDesc.text = kNoneFoundYet
        }
        else{
            self.btnCntOrLookForDigitail.setTitle("SEARCH", for: .normal)
            self.lblSearchingForDigitail.text = kNoTailsFound
          //  self.lblDigitailDesc.text = "We were unable to find any tails.Please ensure that it is nearby and Switched on."
             self.lblDigitailDesc.text = "We were unable to find your Tail. Please ensure that it is nearby and switched on"
            btnCntOrLookForDigitail.isHidden = false
            self.viewActivityIndicator.isHidden = true
        }
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
            if AppDelegate_.peripheralList.count == 0 {
                self.viewActivityIndicator.isHidden = true
                self.btnCntOrLookForDigitail.isHidden = false
                self.btnCntOrLookForDigitail.setTitle("SEARCH", for: .normal)
                self.lblSearchingForDigitail.text = kNoTailsFound
                self.lblDigitailDesc.text = "We were unable to find your Tail. Please ensure that it is nearby and switched on"
                self.viewFindGetTail.isHidden = false
                self.viewTailMovesDesc.isHidden = true
                self.viewMoves.isHidden = true
            }
            else{
                self.viewActivityIndicator.isHidden = true
                self.btnCntOrLookForDigitail.isHidden = false
                self.btnCntOrLookForDigitail.setTitle("CONNECT", for: .normal)
                self.lblSearchingForDigitail.text = kOneTailFound
                self.lblDigitailDesc.text = kNotConnected
                self.viewFindGetTail.isHidden = true
                self.viewTailMovesDesc.isHidden = false
                self.viewMoves.isHidden = false
            }
        }
    }
    
    
    //MARK: - Actions
    @IBAction func Menu_clicked(_ sender: UIButton) {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func moveClicked(_ sender: UIButton) {
//        let deviceActor = AppDelegate_.digitailDeviceActor
        
        for connectedDevices in AppDelegate_.tempDigitailDeviceActor {
            let deviceActor = connectedDevices
            if (deviceActor.isDeviceIsReady) && (deviceActor.isConnected()) {
                let tailMoveString = arrTailMoves[sender.tag]
                let data = Data(tailMoveString.utf8)
                AppDelegate_.moveOn = true
                deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
                checkCasualModeIsOn()
            }
        }
    }
    

    @IBAction func ConnectLookForDigitail_Clicked(_ sender: UIButton) {
        if AppDelegate_.peripheralList.count == 0 {
            self.viewActivityIndicator.isHidden = false
            self.viewActivityIndicator.beginRefreshing()
            btnCntOrLookForDigitail.isHidden = true
            self.lblSearchingForDigitail.text = kSearchingForDigitail
            self.lblDigitailDesc.text = kNoneFoundYet
            AppDelegate_.isScanning = true
            self.startScan()
        }
        else {
            connectDevice(device: AppDelegate_.peripheralList.first!)
            self.viewActivityIndicator.isHidden = false
            self.viewActivityIndicator.beginRefreshing()
            self.lblSearchingForDigitail.text = kOneTailAvailble
            self.lblDigitailDesc.text = kNotConnected
        }
    }
   
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @objc func DeviceDidUpdateProperty(_ note: Notification) {
        let responseData = note.userInfo as! [String:Any]
        if let data = responseData["value"] as? Data {
            let str = String(decoding: data, as: UTF8.self)
            print("---- \n\n\n\n ***** \(str) ***** \n\n\n\n")
            
            // check if move end command
            if str.lowercased().hasSuffix("end") {
                var ismoveEndCommand = false
                for tailMove in arrTailMoves {
                    if str.lowercased().hasPrefix(tailMove.lowercased()) {
                        ismoveEndCommand = true
                        break
                    }
                }
                
                if ismoveEndCommand { //received a move end command from the device
                    AppDelegate_.moveOn = false
                    checkCasualModeIsOn()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDeviceModeRefreshNotification), object: nil)
                }
            }
        }
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
    
    func connectDevice(device: DeviceModel) {
        self.view.bringSubviewToFront(viewActivityIndicator)
        self.viewActivityIndicator.isHidden = false
        AppDelegate_.centralManagerActor.add(device.peripheral)
    }
    
}

     

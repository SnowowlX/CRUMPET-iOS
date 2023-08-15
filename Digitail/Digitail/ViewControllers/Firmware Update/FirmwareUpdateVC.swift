//
//  FirmwareUpdateVC.swift
//  CRUMPET
//
//  Created by Bhavik Patel on 05/03/21.
//  Copyright © 2021 Iottive. All rights reserved.

import UIKit
import CoreBluetooth
import MBProgressHUD


class FirmwareUpdateVC: UIViewController {

    @IBOutlet weak var vw_UpdateSuccess: UIView!
    @IBOutlet weak var vw_FWVersions: UIView!
    @IBOutlet weak var lblScreenTitle: UILabel!
    @IBOutlet weak var lblCurrentFwVersionNumber: UILabel!
    @IBOutlet weak var lblNewVersionNumber: UILabel!
    @IBOutlet weak var vw_NewFWVersion: UIView!
    @IBOutlet weak var lblFWUptodate: UILabel!
    @IBOutlet weak var lblUpdatedFwVersionNo: UILabel!
    @IBOutlet weak var LayConstsNewVersionHeight: NSLayoutConstraint!
    @IBOutlet weak var btnFirmwareUpdate: UIButton!

    @IBOutlet weak var lblProcessStatus: UILabel!
    @IBOutlet weak var lblUpdatingFW: UILabel!
    @IBOutlet weak var fw_Update_ProgressVw_: UIProgressView!
    @IBOutlet weak var vw_FW_Update_Progress: UIView!
  
    var connectedDeviceActor : BLEActor!
    var hud = MBProgressHUD()

    private var dfuPeripheral    : CBPeripheral!
    private var peripheralName   : String?
    var firmwareDocURL : URL!
    var md5 = ""
    var firmwareDownloadURL = ""
    var indexOfDataSent = 0
    var fileData: Data!
    var totalFileData = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainUIAndView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    //MARK:- CUSTOM METHODS -
    func setUpMainUIAndView() {
        RegisterForNote(#selector(self.PeripheralStateChanged(_:)), kPeripheralStateChanged, self)
        RegisterForNote(#selector(self.DeviceDidUpdateProperty(_:)),kDeviceDidUpdateProperty, self)
        RegisterForNote(#selector(self.BluetoothStateUpdate(_:)),kBluetoothStateUpdate, self)
        RegisterForNote(#selector(self.DeviceDisconnected(_:)),kDeviceDisconnected, self)
        RegisterForNote(#selector(self.deviceDidPerformCommand(_:)),kDeviceDidPerformCommand, self)
//        RegisterForNote(#selector(self.DeviceIsReady(_:)),kDeviceIsReady, self)
        
        
        vw_UpdateSuccess.isHidden = true
        vw_FW_Update_Progress.isHidden = true
        vw_FWVersions.isHidden = false
        btnFirmwareUpdate.setTitle(NSLocalizedString("kUpdateFirmware", comment: ""), for: .normal)
        btnFirmwareUpdate.tag = 1
        lblProcessStatus.text = "0%"
        fw_Update_ProgressVw_.progress = 0.0

        let CurrentFirmwareVersion : String = connectedDeviceActor?.state["FirmwareVersion"] as! String
        lblCurrentFwVersionNumber.text = CurrentFirmwareVersion
      
        var strLatestFW = ""
        if Reachability.isAvailable() {
            strLatestFW = getLatestFWVersionFromServer()
            print("Available FW Verison on server is ::",strLatestFW)
        }
        
        let intCurrentFirmwareVersion = getFirmwareVersionFrom(text: CurrentFirmwareVersion)
        let intLatestFirmwareVersion = getFirmwareVersionFrom(text: strLatestFW)
        if intCurrentFirmwareVersion < intLatestFirmwareVersion {
            vw_NewFWVersion.isHidden = false
            LayConstsNewVersionHeight.constant = 90
            lblFWUptodate.isHidden = true
            btnFirmwareUpdate.alpha = 1
            lblNewVersionNumber.text = strLatestFW
        } else {
            vw_NewFWVersion.isHidden = true
            lblFWUptodate.isHidden = false
            LayConstsNewVersionHeight.constant = 0
            btnFirmwareUpdate.alpha = 0.5
        }
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
    
    func showLoader() {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        hud.bezelView.color = .white
        hud.label.text = NSLocalizedString("kLoading", comment: "")
        hud.show(animated: true)
    }

    func startFWUpdateProcess() {
        if (connectedDeviceActor.isDeviceIsReady && connectedDeviceActor.isConnected()) {
            do {
                fileData = try Data(contentsOf: firmwareDocURL)
                totalFileData = fileData.count
                var dataOTA = Data("OTA ".utf8)
                let lengthData = Data(String(totalFileData).utf8)
                dataOTA.append(lengthData)
                dataOTA.append(Data(" ".utf8))
                let data = Data(md5.utf8)
                dataOTA.append(data)
                connectedDeviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:dataOTA]]));
                updateFirmwareProgressUI()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateFirmwareProgressUI(){
        DispatchQueue.main.async {
            let progress = self.indexOfDataSent*100/self.totalFileData
            self.lblProcessStatus.text = "\(Int(progress))%"
            let progressVal = Float(progress)/Float(100)
            self.fw_Update_ProgressVw_.progress = Float(progressVal)
        }
    }
    
    //MARK:- DFU Progress Delegate METHODS -
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        lblProcessStatus.text = "\(Int(progress))%"
        let progressVal = Float(progress)/Float(100)
        fw_Update_ProgressVw_.progress = Float(progressVal)
    }

    /*
    //MARK:- DFU State Change -
    func dfuStateDidChange(to state: DFUState) {
        switch state {
        case .completed, .disconnecting:
            print("Completed")
        case .aborted:
            print("aborted")
            dfuController = nil
            AppDelegate_.isDeviceInDFUMode = false
            self.navigationController?.popViewController(animated: true)
        case .connecting:
            print("connecting")
        default:
            print("default")
        }
        
        print("State changed to: \(state.description())")
        
        // Forget the controller when DFU is done
        if state == .completed {
            dfuController = nil
            AppDelegate_.isDeviceInDFUMode = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.vw_FW_Update_Progress.isHidden = true
                self.vw_FWVersions.isHidden = true
                self.vw_UpdateSuccess.isHidden = false
                self.btnFirmwareUpdate.setTitle("Ok", for: .normal)
                self.lblUpdatedFwVersionNo.text = self.getLatestFWVersionFromServer()
                self.btnFirmwareUpdate.tag = 3
            }
        }
    }*/
    
   
    
    //MARK: - DFU Methods -
    func startDFUProcess() {
        guard let dfuPeripheral = dfuPeripheral else {
            print("No DFU peripheral was set")
            return
        }
        
    
        
//        dfuController = dfuInitiator.with(firmware: DFUFirmware.init(urlToZipFile: firmwareDocURL)!).start(target: dfuPeripheral)
        
    }
    
    //MARK:- TO GET LATEST FIRMWARE VERSION FROM SERVER -
    func getLatestFWVersionFromServer() -> String {
        
        var strFirmwareUpgrade = "https://thetailcompany.com/fw/eargear" // default eargear url
        if lblCurrentFwVersionNumber.text?.hasSuffix("b") == true {
            strFirmwareUpgrade = "https://thetailcompany.com/fw/eargear-b"
        }
        if connectedDeviceActor.bleDeviceType == .mitail {
            strFirmwareUpgrade = "https://thetailcompany.com/fw/mitail"
        }
        
        var latestFWVersion : String = ""
        let myURLString = strFirmwareUpgrade
        if let myURL = NSURL(string: myURLString) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                print("html \(myHTMLString)")
                let dictionary = convertStringToDictionary(text: myHTMLString as String)
                
                latestFWVersion = dictionary?["version"] as! String
                md5 = dictionary?["md5sum"] as! String
                firmwareDownloadURL = dictionary?["url"] as! String
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
    
    //MARK:- DOWNLOAD LATEST FIRMWARE FROM SERVER -
    func downloadLatestFWFromServer() {
        self.lblUpdatingFW.text = NSLocalizedString("kDownloadingFirmware", comment: "")
        self.vw_FW_Update_Progress.isHidden = false
        self.vw_UpdateSuccess.isHidden = true
        self.vw_FWVersions.isHidden = true
        let firmwareFileUrl = URL(string: firmwareDownloadURL)!

        do {
            try firmwareFileUrl.download(to: .documentDirectory, using: "LatestFirmware.bin", overwrite: true, completion: { url, error in
                guard let url = url else {
                    print("Error Saving and Downloading Firmware zip file")
                    return
                }
                print("Firmware .zip file downloaded and save to this location ::",url)
                self.firmwareDocURL = url

                DispatchQueue.main.async {
                    self.lblUpdatingFW.text = NSLocalizedString("kUpdatingFirmware", comment: "")
                    self.vw_FW_Update_Progress.isHidden = false
                    self.vw_UpdateSuccess.isHidden = true
                    self.vw_FWVersions.isHidden = true
                    self.btnFirmwareUpdate.tag = 2
                    self.btnFirmwareUpdate.setTitle(NSLocalizedString("kCancel", comment: ""), for: .normal)
                    self.startFWUpdateProcess()
                }
            })
        } catch {
            self.vw_FW_Update_Progress.isHidden = true
            self.vw_UpdateSuccess.isHidden = false
            self.vw_FWVersions.isHidden = false
            print(error)
            print("Error Saving and Downloading Firmware .zip file")
        }
    }
    
    
    @IBAction func OkUpdateFirmware_Clicked(_ sender: UIButton) {
        if sender.tag == 1 {
            //TITLE IS UPFDATE FIRMWARE
            //DOWNLOAD FIRMWARE FROM SERVER
            if connectedDeviceActor.bleDeviceType == .eg2 {
                openAlert(title: NSLocalizedString("kEG2FirmwareUpgrade", comment: ""), message: NSLocalizedString("kEG2FirmwareUpgradeDecription", comment: ""), alertStyle: .alert, actionTitles: [NSLocalizedString("kStart", comment: ""),NSLocalizedString("kCancel", comment: "")], actionStyles: [.default,.cancel], actions:[{action in
                                self.downloadLatestFWFromServer()
                            },{cancel in
                                
                            }])
            } else {
                openAlert(title: NSLocalizedString("kFirmwareUpgrade", comment: ""), message: NSLocalizedString("kFirmwareUpgradeDecription", comment: ""), alertStyle: .alert, actionTitles: [NSLocalizedString("kStart", comment: ""),NSLocalizedString("kCancel", comment: "")], actionStyles: [.default,.cancel], actions:[{action in
                                self.downloadLatestFWFromServer()
                            },{cancel in
                                
                            }])
            }
        } else if sender.tag == 2 {
            //TITLE IS CANCEL
            self.navigationController?.popViewController(animated: true)
        } else if sender.tag == 3 {
            //TITLE IS OK
            self.navigationController?.popViewController(animated: true)
        } else { }
    }
    
    
    //MARK:- BLE METHODS -
    @objc func BluetoothStateUpdate(_ note: Notification) {
        DispatchQueue.main.async {
            let central = note.object as! CBCentralManager
            if central.state == .poweredOn {
                
            } else if central.state == .poweredOff {
                showAlert(alertTitle: kError, message: kPlease_enable_bluetooth, vc: self)
            } else if central.state == .unauthorized {
               
            }
            
        }
    }
    
    @objc func PeripheralStateChanged(_ note: Notification) {
        DispatchQueue.main.async {
            let peripheral: CBPeripheral? = (note.object as! CBPeripheral)
            if peripheral?.state == .connected {
                print("*********** connected Firmware update")
            } else {
                print("disconnected")
            }
        }
    }
    
//    @objc
//    func DeviceIsReady(_ note: Notification) {
//        DispatchQueue.main.async {
//            print("DeviceIsReady")
//        }
//    }
    
    @objc func DeviceDisconnected(_ note: Notification) {
//        self.tblVw_DeviceDetailsVc.reloadData()
    }
    
    @objc func DeviceDidUpdateProperty(_ note: Notification) {
        debugPrint(#function,"UpdateValue Data %@", note.userInfo!)
        let responseData = note.userInfo as! [String:Any]
        let actor = note.object as? BLEActor
    }
    
    @objc func deviceDidPerformCommand (_ note: Notification) {
        updateFirmwareProgressUI()
        if indexOfDataSent == totalFileData {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.vw_FW_Update_Progress.isHidden = true
                self.vw_FWVersions.isHidden = true
                self.vw_UpdateSuccess.isHidden = false
                self.btnFirmwareUpdate.setTitle("Ok", for: .normal)
                self.lblUpdatedFwVersionNo.text = self.getLatestFWVersionFromServer()
                self.btnFirmwareUpdate.tag = 3
            }
        } else if indexOfDataSent + 185 < totalFileData {
            let data = fileData.subdata(in: indexOfDataSent..<indexOfDataSent+185)
            indexOfDataSent += 185
            connectedDeviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
        } else {
            let data = fileData.subdata(in: indexOfDataSent..<fileData.count)
            indexOfDataSent += fileData.count-indexOfDataSent
            connectedDeviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
        }
    }
}

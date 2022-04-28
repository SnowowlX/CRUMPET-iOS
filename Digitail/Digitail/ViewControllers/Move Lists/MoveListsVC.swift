//
//  MoveListsVC.swift
//  Digitail
//
//  Created by Iottive on 03/07/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import SideMenu


class MoveListsVC: UIViewController,UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate,UITextFieldDelegate,MoveListDelegate{
    
    //MARK: - Properties
    @IBOutlet var tblViewMoveLists: UITableView!
    @IBOutlet var viewDeletePopUp: UIView!
    @IBOutlet var btnAdd: UIButton!
    @IBOutlet var txtMoveListName: UITextField!
    @IBOutlet var lblDeletePopUpDesc: UILabel!
    @IBOutlet var viewPopUpBackground: UIView!
    @IBOutlet var viewPopUp: UIView!
    @IBOutlet var viewMoveListDesc: UIView!
    var indexPathForOpr : Int!
    var arrdictMoveListData = [[String:Any]]()
    var currentTimerInterval : Float = 0
    var currentMoveList: [String] = [String]()
    var currentIndex = 0
    @IBOutlet var btnMenu: UIButton!
    var moveTimer = Timer()
    let dictHomePosition = [NSLocalizedString("kSlowwag1", comment: ""):"TAILS1",NSLocalizedString("kSlowwag2", comment: ""):"TAILS2",NSLocalizedString("kSlowwag3", comment: ""):"TAILS3",NSLocalizedString("kFastWag", comment: ""):"TAILFA",NSLocalizedString("kShortWag", comment: ""):"TAILSH",NSLocalizedString("kHappyWag", comment: ""):"TAILHA",NSLocalizedString("kErect", comment: ""):"TAILER",NSLocalizedString("kErectPulse", comment: ""):"TAILEP",NSLocalizedString("kTremble1", comment: ""):"TAILT1",NSLocalizedString("kTremble2", comment: ""):"TAILT2",NSLocalizedString("kErectTrem", comment: ""):"TAILET"]
    
    @IBOutlet var btnCreate: UIButton!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tblViewMoveLists.reloadData()
        setUpMainUI()
        RegisterForNote(#selector(self.DeviceDidUpdateProperty(_:)), kDeviceDidUpdateProperty, self)
    }
    
    //MARK: - Custome Function -
    func setUpMainUI(){
        let tapRegister: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MoveListsVC.dismissKeyboard))
        viewPopUpBackground.addGestureRecognizer(tapRegister)
        
        
        btnMenu.layer.cornerRadius = 5.0
        btnCreate.layer.cornerRadius = 2.0
        
        btnCreate.isUserInteractionEnabled = false
        btnCreate.alpha = 0.5

        viewPopUpBackground.isHidden = true
        viewPopUp.isHidden = true
        viewDeletePopUp.isHidden = true
        tblViewMoveLists.isHidden = false
        btnAdd.layer.cornerRadius = btnAdd.frame.height/2.0
        
        
        viewMoveListDesc.layer.shadowColor = UIColor.darkGray.cgColor
        viewMoveListDesc.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        viewMoveListDesc.layer.shadowRadius = 1.7
        viewMoveListDesc.layer.shadowOpacity = 0.5
        
        if let arrDictMoveListDetail = UserDefaults.standard.array(forKey: kArrDictMoveList ) as? [[String: Any]] {
            arrdictMoveListData = arrDictMoveListDetail
        }
        
        viewDeletePopUp.layer.shadowColor = UIColor.black.cgColor
        viewDeletePopUp.layer.shadowOpacity = 1
        viewDeletePopUp.layer.shadowOffset = .zero
        viewDeletePopUp.layer.shadowRadius = 10
        
        //For Add PopUp
        viewPopUp.layer.shadowColor = UIColor.black.cgColor
        viewPopUp.layer.shadowOpacity = 1
        viewPopUp.layer.shadowOffset = .zero
        viewPopUp.layer.shadowRadius = 10
        
        tblViewMoveLists.separatorInset = .zero
        tblViewMoveLists.layoutMargins = .zero
        txtMoveListName.delegate = self

    }
    
    func openAlertView() {
        let alert = UIAlertController(title: kError, message: kMsgAlarmName, preferredStyle: UIAlertController.Style.alert)
        //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: kAlertActionOK, style: .default, handler:{ (UIAlertAction) in
            ///print("User click Ok button")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc override func dismissKeyboard() {
        view.endEditing(true)
        viewPopUpBackground.isHidden = true
        viewDeletePopUp.isHidden = true
        viewPopUp.isHidden = true
    }
    
    func moveToCreateMoveListScreen(isfromEdit : Bool, strMoveListName : String) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let objTailMovesListVC = storyboard.instantiateViewController(withIdentifier: "TailMovesListVC") as! TailMovesListVC
        objTailMovesListVC.delegate = self
        objTailMovesListVC.isFromEdit = isfromEdit
        objTailMovesListVC.savedMoveListName = strMoveListName
        self.navigationController?.pushViewController(objTailMovesListVC, animated: true)
    }
    
    //DELEGATE METHOD -
    func fetchSavedData(strMoveName : String) {
        var dictMoveListData = [String:Any]()
        dictMoveListData[kMoveName] = strMoveName
        arrdictMoveListData.append(dictMoveListData)
        UserDefaults.standard.set(arrdictMoveListData, forKey: kArrDictMoveList)
        self.tblViewMoveLists.reloadData()
    }
    
     //MARK: - Actions -
    @objc func Swipable_Menu_Clicked(sender: UIButton){
        let section = 0
        let row = sender.tag
        let indexPath = IndexPath(row: row, section: section)
        let cell: MGSwipeTableCell = self.tblViewMoveLists.cellForRow(at: indexPath) as! MGSwipeTableCell
        cell.showSwipe(.rightToLeft, animated: true)
    }
    
    @objc func Run_Clicked(sender: UIButton) {
        print("Run Commands from here")
         if self.isDIGITAiLConnected() {
             let row = sender.tag
             let indexPath = IndexPath(row: row, section: 0)
             let cell: TblCellMoveLists = self.tblViewMoveLists.cellForRow(at: indexPath) as! TblCellMoveLists
            if sender.titleLabel?.text == NSLocalizedString("kRun", comment: "") {
                let movelistName = arrdictMoveListData[sender.tag][kMoveName] as! String
                    if let pravSavedData = UserDefaults.standard.value(forKey: "\(movelistName) MoveList") as? [String : AnyObject] {
                        print(pravSavedData)
                        let sliderValue = pravSavedData["SliderValue"] as! String
                        let checkedIndexes = pravSavedData["SelectedData"] as! [String]
                        self.currentMoveList = checkedIndexes
                        self.currentTimerInterval = Float(sliderValue)!
                        self.currentIndex = 0
                        sendMoveCommand()
                    }
            }
         } else {
             showAlert(title: kTitleConnect, msg: kMsgConnect)
         }
    }
    
    func stopMoveList() {
        self.moveTimer.invalidate()
    }
    
    
    func runMoveList() {
        self.moveTimer.invalidate()
        self.moveTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.currentTimerInterval), target: self, selector:#selector(self.sendMoveCommand) , userInfo: nil, repeats: false)
    }
    
    @objc func sendMoveCommand() {
//        let deviceActor = AppDelegate_.digitailDeviceActor
        
        for connectedDevices in AppDelegate_.tempDigitailDeviceActor {
            let deviceActor = connectedDevices
            if ((deviceActor.isDeviceIsReady) && ((deviceActor.isConnected()))) {
                let tailMoveString = self.dictHomePosition[self.currentMoveList[self.currentIndex]]
//                if tailMoveString != nil {
                    let data = Data(tailMoveString!.utf8)
                    deviceActor.performCommand(Constants.kCommand_SendData, withParams:NSMutableDictionary.init(dictionary: [Constants.kCharacteristic_WriteData : [Constants.kData:data]]));
                    self.currentIndex += 1
                    if self.currentIndex == self.currentMoveList.count {
                        self.currentIndex = 0
                        stopMoveList()
                    } else {
                        runMoveList()
                    }
//                }
            }
        }
    }
    
    @IBAction func Create_Clicked(_ sender: UIButton) {
        if txtMoveListName.text == ""{
            openAlertView()
        }
        else {
            var dictMoveListData = [String:Any]()
            dictMoveListData[kMoveName] = txtMoveListName.text
            arrdictMoveListData.append(dictMoveListData)
            UserDefaults.standard.set(arrdictMoveListData, forKey: kArrDictMoveList)
            viewPopUpBackground.isHidden = true
            viewPopUp.isHidden = true
            tblViewMoveLists.reloadData()
        }
    }
    
    @IBAction func Add_Clicked(_ sender: UIButton) {
        moveToCreateMoveListScreen(isfromEdit: false, strMoveListName: "")
    }
    
    @IBAction func OK_Clicked_PopUp(_ sender: UIButton) {
        self.arrdictMoveListData.remove(at: indexPathForOpr)
        UserDefaults.standard.set(self.arrdictMoveListData, forKey: kArrDictMoveList)
        viewPopUpBackground.isHidden = true
        viewDeletePopUp.isHidden = true
        tblViewMoveLists.reloadData()
    }
    
    @IBAction func Cancel_Clicked_PopUp(_ sender: UIButton) {
        viewDeletePopUp.isHidden = true
        viewPopUpBackground.isHidden = true
    }
    
    @IBAction func Menu_Clicked(_ sender: UIButton) {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
       // navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrdictMoveListData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TblCellMoveLists") as! TblCellMoveLists
        
        cell.lblMoveName.text = arrdictMoveListData[indexPath.row][kMoveName] as? String
        cell.selectionStyle = .none
        cell.btnSwipeMenu.tag = indexPath.row
        cell.btn_Run_Clicked.tag = indexPath.row
        cell.btn_Run_Clicked.addTarget(self, action: #selector(Run_Clicked), for: .touchUpInside)
        cell.btnSwipeMenu.addTarget(self, action: #selector(Swipable_Menu_Clicked), for: .touchUpInside)
        cell.delegate = self
        cell.rightButtons = [MGSwipeButton(title: "", icon: UIImage(named:"delete"), backgroundColor: .clear, padding: 30, callback: { (MGSwipeTableCell) -> Bool in
            self.indexPathForOpr = indexPath.row
            self.viewDeletePopUp.isHidden = false
            self.viewPopUpBackground.isHidden = false
            let moveName = self.arrdictMoveListData[indexPath.row][kMoveName] as? String
            self.lblDeletePopUpDesc.text = "\(NSLocalizedString("kRemoveItemMessage", comment: "")) '\(moveName ?? "")'?"
            
            if isKeyPresentInUserDefaults(key: "\(self.arrdictMoveListData[indexPath.row][kMoveName] ?? "") MoveList") {
                UserDefaults.standard.removeObject(forKey: "\(self.arrdictMoveListData[indexPath.row][kMoveName] ?? "") MoveList")
            }
            self.tblViewMoveLists.reloadData()
            return true
        }),MGSwipeButton(title: "", icon: UIImage(named: "edit"), backgroundColor: .clear, padding: 30, callback: { (MGSwipeTableCell) -> Bool in
            self.moveToCreateMoveListScreen(isfromEdit: true, strMoveListName: self.arrdictMoveListData[indexPath.row][kMoveName] as! String)
            return true
        })]
        
        cell.swipeBackgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        cell.leftSwipeSettings.transition = .drag
        return cell
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        btnCreate.isUserInteractionEnabled = true
        btnCreate.alpha = 1.0
    }
    
    func isDIGITAiLConnected() -> Bool {
//        if AppDelegate_.digitailDeviceActor != nil && (AppDelegate_.digitailDeviceActor?.peripheralActor != nil && (AppDelegate_.digitailDeviceActor?.isConnected())!) {
//            return true
//        } else {
//            return false
//        }
        
        var isConnected = Bool()
        for connectedDevices in AppDelegate_.tempDigitailDeviceActor {
            if (connectedDevices.peripheralActor != nil && (connectedDevices.isConnected())) {
                isConnected = true
                break
            } else {
                isConnected = false
            }
        }
    
        return isConnected
        
    }
    
    func showAlert(title:String, msg:String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: kAlertActionOK, style: .default, handler:{ (UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
            ///print("User click Ok button")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func DeviceDidUpdateProperty(_ note: Notification) {
        let objActor : BLEActor = note.object as! BLEActor
        debugPrint(#function,"UpdateValue Data %@", note.userInfo!)
        let responseData = note.userInfo as! [String:Any]
        
        if responseData["name"] as? String == Constants.kCharacteristic_WriteData || responseData["name"] as? String == Constants.kCharacteristic_ReadData {
            if let data = responseData["value"] as? Data {
                let str = String(decoding: data, as: UTF8.self)
                if str.lowercased().contains("end") {
                    if self.currentIndex == 0 {
                        //stopMoveList()
                    } else {
                        //runMoveList()
                    }
                }
                
            }
        }
    }
    
}


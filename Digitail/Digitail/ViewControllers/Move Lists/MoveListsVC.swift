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

class MoveListsVC: UIViewController,UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate,UITextFieldDelegate{
    
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
    @IBOutlet var btnMenu: UIButton!
    
    @IBOutlet var btnCreate: UIButton!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tblViewMoveLists.reloadData()
        setUpMainUI()
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        viewPopUpBackground.isHidden = true
        viewDeletePopUp.isHidden = true
        viewPopUp.isHidden = true
    }
    
     //MARK: - Actions -
    @objc func Swipable_Menu_Clicked(sender: UIButton){
        let section = 0
        let row = sender.tag
        let indexPath = IndexPath(row: row, section: section)
        let cell: MGSwipeTableCell = self.tblViewMoveLists.cellForRow(at: indexPath) as! MGSwipeTableCell
        cell.showSwipe(.rightToLeft, animated: true)
    }
    
    @IBAction func Create_Clicked(_ sender: UIButton) {
        if txtMoveListName.text == ""{
            openAlertView()
        }
        else{
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
        viewPopUpBackground.isHidden = false
        viewPopUp.isHidden = false
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
        cell.btnSwipeMenu.addTarget(self, action: #selector(Swipable_Menu_Clicked), for: .touchUpInside)
        cell.delegate = self
        cell.rightButtons = [MGSwipeButton(title: "", icon: UIImage(named:"delete"), backgroundColor: .clear, padding: 30, callback: { (MGSwipeTableCell) -> Bool in
            self.indexPathForOpr = indexPath.row
            self.viewDeletePopUp.isHidden = false
            self.viewPopUpBackground.isHidden = false
            let moveName = self.arrdictMoveListData[indexPath.row][kMoveName] as? String
            self.lblDeletePopUpDesc.text = "Are you sure that you want to remove the alarm '\(moveName ?? "")'?"
            self.tblViewMoveLists.reloadData()
            return true
        }),MGSwipeButton(title: "", icon: UIImage(named: "edit"), backgroundColor: .clear, padding: 30, callback: { (MGSwipeTableCell) -> Bool in
             let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let moveListUpdateVC = storyboard.instantiateViewController(withIdentifier: "MoveListUpdateVC") as! MoveListUpdateVC
            self.navigationController?.pushViewController(moveListUpdateVC, animated: true)
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
    
    
}


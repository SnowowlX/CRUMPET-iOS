//
//  MoveListUpdateVC.swift
//  Digitail
//
//  Created by Iottive on 09/07/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import SideMenu
import JTMaterialSpinner

class MoveListUpdateVC: UIViewController,UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate{
    
    //MARK: - Properties
    var indexPathForOpr : Int!
    @IBOutlet var tblView: UITableView!
    @IBOutlet var viewPopUpBackground: UIView!
    @IBOutlet var viewMoveListDesc: UIView!
    @IBOutlet var viewPickCommandPopUp: UIView!
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var viewPickDurationPopUp: UIView!
    @IBOutlet var btnAdd: UIButton!
    @IBOutlet var btnTimer: UIButton!
    @IBOutlet var viewActivityIndicator: JTMaterialSpinner!
    @IBOutlet var viewPickCmdDesc: UIView!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewPopUpBackground.isHidden = true
        viewPickCommandPopUp.isHidden = true
        viewPickDurationPopUp.isHidden = true
        
        let tapRegister: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AlarmsVC.dismissKeyboard))
        viewPopUpBackground.addGestureRecognizer(tapRegister)
        
        viewMoveListDesc.layer.shadowColor = UIColor.darkGray.cgColor
        viewMoveListDesc.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        viewMoveListDesc.layer.shadowRadius = 1.7
        viewMoveListDesc.layer.shadowOpacity = 0.5
        
        viewActivityIndicator.circleLayer.lineWidth = 3.0
        viewActivityIndicator.circleLayer.strokeColor = UIColor(red: 96/255, green: 125/255, blue: 138/255, alpha: 1.0).cgColor
        viewActivityIndicator.beginRefreshing()
        
        viewPickCmdDesc.layer.shadowColor = UIColor.darkGray.cgColor
        viewPickCmdDesc.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        viewPickCmdDesc.layer.shadowRadius = 1.7
        viewPickCmdDesc.layer.shadowOpacity = 0.5
        
        tblView.separatorInset = .zero
        tblView.layoutMargins = .zero
        
        btnAdd.layer.cornerRadius = btnAdd.frame.height/2.0
        btnAdd.clipsToBounds = true
        
    }
    
    //MARK: - Actions -
    @objc func Swipable_Menu_Clicked(sender: UIButton){
        let section = 0
        let row = sender.tag
        let indexPath = IndexPath(row: row, section: section)
        let cell: MGSwipeTableCell = self.tblView.cellForRow(at: indexPath) as! MGSwipeTableCell
        cell.showSwipe(.rightToLeft, animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        viewPickDurationPopUp.isHidden = true
        viewPickCommandPopUp.isHidden = true
        viewPopUpBackground.isHidden = true
    }
    
    @IBAction func Menu_Clicked(_ sender: UIButton) {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func Add_Clicked(_ sender: UIButton) {
    }
    
    @IBAction func Timer_Clicked(_ sender: UIButton) {
    }
    
    
  //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "TblCellMoveListUpdate") as! TblCellMoveListUpdate
        
        cell.selectionStyle = .none
        cell.btnMenu.tag = indexPath.row
        cell.btnMenu.addTarget(self, action: #selector(Swipable_Menu_Clicked), for: .touchUpInside)
        cell.delegate = self
        cell.rightButtons = [MGSwipeButton(title: "", icon: UIImage(named:"delete"), backgroundColor: .clear, padding: 30, callback: { (MGSwipeTableCell) -> Bool in
//            self.indexPathForOpr = indexPath.row
//            self.viewPopUpBackground.isHidden = false
//            self.viewPickCommandPopUp.isHidden = false
//            self.viewPickDurationPopUp.isHidden = true
            return true
            
        }),MGSwipeButton(title: "", icon: UIImage(named: "clock"), backgroundColor: .clear, padding: 30, callback: { (MGSwipeTableCell) -> Bool in
            self.indexPathForOpr = indexPath.row
            self.viewPopUpBackground.isHidden = false
            self.viewPickCommandPopUp.isHidden = true
            self.viewPickDurationPopUp.isHidden = false
            return true
        }),MGSwipeButton(title: "", icon: UIImage(named: "Plus"), backgroundColor: .clear, padding: 30, callback: { (MGSwipeTableCell) -> Bool in
            self.indexPathForOpr = indexPath.row
            self.viewPopUpBackground.isHidden = false
            self.viewPickCommandPopUp.isHidden = false
            self.viewPickDurationPopUp.isHidden = true
            return true
        })]
        
        cell.swipeBackgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        cell.leftSwipeSettings.transition = .drag
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // indexPathForOpr = indexPath.row
    }

}

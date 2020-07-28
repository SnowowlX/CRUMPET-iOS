//
//  UpDateAlarmVC.swift
//  Digitail
//
//  Created by Iottive on 08/07/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
import JTMaterialSpinner
import SideMenu

class UpDateAlarmVC: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    //MARK: - Properties
    @IBOutlet var viewUpdateAlrmDesc: UIView!
    @IBOutlet var tblViewCommandList: UITableView!
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var viewPopUpBackground: UIView!
    @IBOutlet var viewPickCmdDesc: UIView!
    @IBOutlet var viewActivityIndicator: JTMaterialSpinner!
    @IBOutlet var lblSearchingForDigitail: UILabel!
    @IBOutlet var lblNoneFound: UILabel!
    @IBOutlet var viewPopUpPickCommand: UIView!
    @IBOutlet var btnAdd: UIButton!
    @IBOutlet var btnDuration: UIButton!
    @IBOutlet var lblSeconds: UILabel!
    @IBOutlet var viewPopUpDuration: UIView!
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainUI()
    }
    
    //MARK: - Custome Function -
    func setUpMainUI(){
        
        tblViewCommandList.separatorInset = .zero
        tblViewCommandList.layoutMargins = .zero
        let tapRegister: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UpDateAlarmVC.dismissKeyboard))
        viewPopUpBackground.addGestureRecognizer(tapRegister)

        
        viewPopUpBackground.isHidden = true
        viewPopUpPickCommand.isHidden = true
        viewPopUpDuration.isHidden = true

        
        viewUpdateAlrmDesc.layer.shadowColor = UIColor.darkGray.cgColor
        viewUpdateAlrmDesc.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        viewUpdateAlrmDesc.layer.shadowRadius = 1.7
        viewUpdateAlrmDesc.layer.shadowOpacity = 0.5
        
        viewPickCmdDesc.layer.shadowColor = UIColor.darkGray.cgColor
        viewPickCmdDesc.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        viewPickCmdDesc.layer.shadowRadius = 1.7
        viewPickCmdDesc.layer.shadowOpacity = 0.5
        btnAdd.layer.cornerRadius = btnAdd.frame.height/2.0
        btnMenu.layer.cornerRadius = 5.0
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        viewPopUpBackground.isHidden = true
        viewPopUpPickCommand.isHidden = true
        viewPopUpDuration.isHidden = true
    }
    
    //MARK: - Actions -
    @IBAction func Add_Clicked(_ sender: UIButton) {
        viewActivityIndicator.circleLayer.lineWidth = 3.0
        viewActivityIndicator.circleLayer.strokeColor = UIColor(red: 96/255, green: 125/255, blue: 138/255, alpha: 1.0).cgColor
        viewActivityIndicator.beginRefreshing()
        viewPopUpBackground.isHidden = false
        viewPopUpPickCommand.isHidden = false
        viewPopUpDuration.isHidden = true
    }
    
    @IBAction func Menu_Clicked(_ sender: UIButton) {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func AddThisPause_Clicked(_ sender: UIButton) {
    }
    
    @IBAction func Duration_Clicked(_ sender: UIButton) {
        viewPopUpPickCommand.isHidden = true
        viewPopUpBackground.isHidden = false
        viewPopUpDuration.isHidden = false
    }
    
    @IBAction func slider(_ sender: UISlider) {
    }
    
    //MARK: - Tableview Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblViewCommandList.dequeueReusableCell(withIdentifier: "TblCellUpdateAlarm", for: indexPath) as! TblCellUpdateAlarm
      //  cell.lblTailMovesName.text = arrTailMoves[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
}

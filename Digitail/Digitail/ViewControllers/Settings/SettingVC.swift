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
    @IBOutlet var btnCheckBox: UIButton!
    @IBOutlet var btnMenu: UIButton!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainUI()
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

    func openAlertView() {
        let alert = UIAlertController(title: "Settings", message: "Coming Soon", preferredStyle: UIAlertController.Style.alert)
        //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: kAlertActionOK, style: .default, handler:{ (UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
            ///print("User click Ok button")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

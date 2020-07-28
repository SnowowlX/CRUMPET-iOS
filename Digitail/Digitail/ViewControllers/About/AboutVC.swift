//
//  AboutVC.swift
//  Digitail
//
//  Created by Iottive on 24/07/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
import SideMenu

class AboutVC: UIViewController {
    
    //MARK: - Properties
    @IBOutlet var btnProfile: UIButton!
    @IBOutlet var lblCompnyLink: UILabel!
    @IBOutlet var lblLicense: UILabel!
    @IBOutlet var viewAutherOne: UIView!
    @IBOutlet var viewAutherTwo: UIView!
    @IBOutlet var btnMenu: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainUI()
    }
    
    //MARK: - Custome Function
    func setUpMainUI(){
        btnMenu.layer.cornerRadius = 5.0

        lblCompnyLink.isUserInteractionEnabled = true
        btnProfile.layer.cornerRadius = btnProfile.frame.height/2.0
      let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AboutVC.CompanyLink_Clicked))
        lblCompnyLink.addGestureRecognizer(tap)
        
        viewAutherOne.layer.shadowColor = UIColor.darkGray.cgColor
        viewAutherOne.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        viewAutherOne.layer.shadowRadius = 1.7
        viewAutherOne.layer.shadowOpacity = 0.5
        
        viewAutherTwo.layer.shadowColor = UIColor.darkGray.cgColor
        viewAutherTwo.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        viewAutherTwo.layer.shadowRadius = 1.7
        viewAutherTwo.layer.shadowOpacity = 0.5
    }
    
    //MARK: - Actions
    @objc func CompanyLink_Clicked(Gesture:UITapGestureRecognizer) {
        print("tap working")
        let loadCompanyDetailVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoadCompanyDetail") as?
        LoadCompanyDetail
        self.navigationController?.pushViewController(loadCompanyDetailVC!, animated: true)
    }
    
    @IBAction func Menu_Clicked(_ sender: UIButton){
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
}

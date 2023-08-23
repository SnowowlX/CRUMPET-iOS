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
    @IBOutlet var lblCompnyLink: UILabel!
    @IBOutlet var lblLicense: UITextView!
    @IBOutlet var btnMenu: UIButton!
    
    @IBOutlet weak var lblCreatedTitle: UILabel!
    
//    @IBOutlet weak var lblCopyright: UILabel!
    @IBOutlet weak var lblCopyrightDetails: UILabel!
    
    let telegramURL = URL(string: "https://t.me/+SYMOR3svXHfby-mo")!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainUI()
        setupLocalization()
    }
    
    //MARK: - Custome Function
    func setUpMainUI(){
        btnMenu.layer.cornerRadius = 5.0

        lblCompnyLink.isUserInteractionEnabled = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AboutVC.CompanyLink_Clicked))
        lblCompnyLink.addGestureRecognizer(tap)
    }
    
    func setupLocalization() {
        self.title = NSLocalizedString("kAbout", comment: "")
//        lblCopyright.text = NSLocalizedString("kCopyright", comment: "")
        lblCopyrightDetails.text = NSLocalizedString("kComanyInfo", comment: "")
        
        let licenseAttributeText = NSMutableAttributedString(string: "This app is open source. If you would like to get involved please visit our ", attributes: [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 16)])
        let telegram = NSMutableAttributedString(string: "Telegram group.", attributes: [.foregroundColor: UIColor.systemBlue, .font: UIFont.systemFont(ofSize: 16), .underlineStyle: NSUnderlineStyle.single.rawValue, .underlineColor: UIColor.systemBlue])
        telegram.addAttribute(.link, value: "telegram", range: NSRange(location: 0, length: telegram.length))
        licenseAttributeText.append(telegram)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        licenseAttributeText.addAttributes([.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: licenseAttributeText.length))
        
        lblLicense.linkTextAttributes = [.foregroundColor: UIColor.systemBlue, .font: UIFont.systemFont(ofSize: 16)]
        lblLicense.attributedText = licenseAttributeText
        
        lblLicense.delegate = self
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

extension AboutVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(telegramURL, options: [:], completionHandler: nil)
        return true
    }
}

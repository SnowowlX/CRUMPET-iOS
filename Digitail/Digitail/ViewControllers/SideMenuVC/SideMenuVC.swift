//
//  SideMenuVC.swift
//  Digitail
//
//  Created by Iottive on 21/06/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit

//let k = "DIGITAIL"

let kSettings = NSLocalizedString("kSettings", comment: "")
let kAbout = NSLocalizedString("kAbout", comment: "")

class SideMenuVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    //MARK: - Properties
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var tblViewMenuList: UITableView!
    var indexPathForTextColor : Int!
    
//    var arrMenuList = ["Crumpet","Alarm","Move Lists","Tail Moves","Glow Tips","Casual Mode Settings","Connect Gear","Settings","MiTail Instructions","About"]
    var arrMenuList = ["Crumpet",kSettings,kAbout, "Visit our website"]
    var arrMenuImages = ["Home","Settings","About", "browser"]
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tblViewMenuList.separatorStyle = .none
        tblViewMenuList.reloadData()
        // bottomTabs.drawBehind = true
        self.navigationController?.isNavigationBarHidden = true
      
//        let tapGestureForDeveloper = UITapGestureRecognizer(target: self, action: #selector (addDeveloper_Clcked))
//        tapGestureForDeveloper.numberOfTapsRequired = 5
//        imgView.isUserInteractionEnabled = true
//        imgView.addGestureRecognizer(tapGestureForDeveloper)
    }
    
    @objc func addDeveloper_Clcked() {
        print("Tap happend")
        if !arrMenuList.contains("Developer") {
            arrMenuList.append("Developer")
            arrMenuImages.append("Settings")
            tblViewMenuList.reloadData()
        }
    }

    
    //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMenuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblViewMenuList.dequeueReusableCell(withIdentifier: "TblCellSideMenu", for: indexPath) as! TblCellSideMenu
        cell.lblMenuName.text = arrMenuList[indexPath.row]
        cell.imgView.image = UIImage(named: arrMenuImages[indexPath.row])
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 96/255, green: 126/255, blue: 139/255, alpha: 1.0)
        cell.selectedBackgroundView = backgroundView
        //cell.lblMenuName.highlightedTextColor = UIColor.white
        cell.lblMenuName.textColor = UIColor.black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let indexTitel = arrMenuList[indexPath.row]
        let section = 0
        let row = indexPath.row
        let indexPath = IndexPath(row: row, section: section)
        let cell: TblCellSideMenu = self.tblViewMenuList.cellForRow(at: indexPath) as! TblCellSideMenu
        //.imgView.tintColor = UIColor.white
//        cell.imgView.image = cell.imgView.image?.withRenderingMode(.alwaysTemplate)
        
        let navigationController = AppDelegate_.window?.rootViewController as! UINavigationController
        dismiss(animated: true, completion: nil)
        navigationController.popToRootViewController(animated: false)
        switch indexTitel {
        case "Alarm" :
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let alarmVc = self.storyboard?.instantiateViewController(withIdentifier: "AlarmsVC") as! AlarmsVC
            navigationController.pushViewController(alarmVc, animated: true)
            break
        case "Move Lists" :
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let moveListVC = storyboard.instantiateViewController(withIdentifier: "MoveListsVC") as! MoveListsVC
            navigationController.pushViewController(moveListVC, animated: true)
            break
        case "Tail Moves" :
            if (self.isDIGITAiLConnected()) {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let tailsMoveVC = storyboard.instantiateViewController(withIdentifier: "TailMovesVC") as! TailMovesVC
                navigationController.pushViewController(tailsMoveVC, animated: true)
            } else {
                
            }
            break
        case "Casual Mode Settings" :
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let casualModeSettingVC = storyboard.instantiateViewController(withIdentifier: "CasualModeSettingVC") as! CasualModeSettingVC
            navigationController.pushViewController(casualModeSettingVC, animated: true)
            break
        case "Connect Gear" :
            let DeviceListVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DeviceListVC") as? DeviceListVC
            self.navigationController?.pushViewController(DeviceListVC!, animated: true)
            break
        case kSettings :
            let rootViewController = AppDelegate_.window!.rootViewController
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let setViewController = mainStoryboard.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
            
            navigationController.pushViewController(setViewController, animated: true)
            break
        case "Glow Tips" :
            if (self.isDIGITAiLConnected()) {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let objGlowTipsVC = storyboard.instantiateViewController(withIdentifier: "GlowTipsVC") as! GlowTipsVC
                self.navigationController?.pushViewController(objGlowTipsVC, animated: true)
            } else {
                
            }
            break
        case "MiTail Instructions" :
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let webViewVC = storyboard.instantiateViewController(withIdentifier: "WebKitViewVC") as! WebKitViewVC
            webViewVC.urlToLoad = "https://thetailcompany.com/mitail.pdf"
            navigationController.pushViewController(webViewVC, animated: true)
            break
        case kAbout :
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let objAboutVC = storyboard.instantiateViewController(withIdentifier: "AboutVC") as! AboutVC
            navigationController.pushViewController(objAboutVC, animated: true)
            break
        case "Developer" :
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let objDeveloperVC = storyboard.instantiateViewController(withIdentifier: "DeveloperVC") as! DeveloperVC
            navigationController.pushViewController(objDeveloperVC, animated: true)
            break
        case "Visit our website" :
            if let url = URL(string: "https://thetailcompany.com") {
                UIApplication.shared.open(url)
            }
            break
        default:
            break
        }
    }
    
    func isDIGITAiLConnected() -> Bool {
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
        
//        if AppDelegate_.digitailDeviceActor != nil && (AppDelegate_.digitailDeviceActor?.peripheralActor != nil && (AppDelegate_.digitailDeviceActor?.isConnected())!) {
//            return true
//        } else {
//            return false
//        }
    }
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 55
    //    }
    
    //    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    //       // return 15.0
    //    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        indexPathForTextColor = indexPath.row
        tblViewMenuList.reloadData()
    }
    
}

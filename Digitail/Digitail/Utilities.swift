//
//  Utilities.swift
//  Digitail
//
//  Created by Iottive on 05/11/19.
//  Copyright © 2019 Iottive. All rights reserved.
//


import UIKit
import Foundation

extension UIAlertController {
    class func alert(title:String, msg:String, target: UIViewController) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
            (result: UIAlertAction) -> Void in
        })
        target.present(alert, animated: true, completion: nil)
    }
}

func addShadow(sender : UIButton) {
    sender.layer.shadowColor = UIColor.darkGray.cgColor
    sender.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    sender.layer.shadowRadius = 2.5
    sender.layer.shadowOpacity = 0.5
}

func showToast(controller: UIViewController, message : String, seconds: Double) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    alert.view.backgroundColor = UIColor.black
    alert.view.alpha = 0.6
    alert.view.layer.cornerRadius = 15
    
    controller.present(alert, animated: true)
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
        alert.dismiss(animated: true)
    }
}

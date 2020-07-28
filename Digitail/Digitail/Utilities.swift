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

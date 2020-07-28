//
//  TailPosesVC.swift
//  Digitail
//
//  Created by Iottive on 12/07/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit

class TailPosesVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        openAlertView()
    }
    
    func openAlertView() {
        let alert = UIAlertController(title: "Tail Poses", message: "Coming Soon", preferredStyle: UIAlertController.Style.alert)
        //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: kAlertActionOK, style: .default, handler:{ (UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
            ///print("User click Ok button")
        }))
        self.present(alert, animated: true, completion: nil)
    }

  

}

//
//  WebKitViewVC.swift
//  CRUMPET
//
//  Created by Admin on 9/1/20.
//  Copyright © 2020 Iottive. All rights reserved.
//

import UIKit
import WebKit

class WebKitViewVC: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var isDigitail : Bool = false
    var urlToLoad: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
            let url=URL(string: urlToLoad)
            webView.load(URLRequest(url: url!))
    }
   
}

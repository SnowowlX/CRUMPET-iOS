//
//  LoadCompanyDetail.swift
//  Digitail
//
//  Created by Iottive on 24/07/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit

class LoadCompanyDetail: UIViewController,UIWebViewDelegate{
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var webViewCompanyDetail: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://thetailcompany.com/")
        let requestObj = URLRequest(url: url! as URL)
        webViewCompanyDetail.loadRequest(requestObj)
    }
    
    func webViewDidStartLoad(_ : UIWebView) {
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ : UIWebView) {
        activityIndicator.stopAnimating()
    }
    

}

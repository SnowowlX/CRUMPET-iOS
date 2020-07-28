//
//  LaunchVC.swift
//  Digitail
//
//  Created by Iottive on 08/07/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
import AVFoundation

class LaunchVC: UIViewController {

    //MARK: - Properties
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        UserDefaults.standard.set(true, forKey: Constants.kIsVideoPlayed)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupAVPlayer()
      //  let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: YourViewController)
    }
    
    //MARK: - Custom Function
    func setupAVPlayer() {
            let videoURL = Bundle.main.url(forResource: "splash", withExtension: "mp4")
            let avAssets = AVAsset(url: videoURL!)
            let avPlayer = AVPlayer(url: videoURL!)
            let avPlayerLayer = AVPlayerLayer(player: avPlayer)
            avPlayerLayer.frame = self.view.frame
           self.view.layer.addSublayer(avPlayerLayer)
            avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            avPlayer.play()
            avPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1) , queue: .main) { [weak self] time in
                
                if time == avAssets.duration {
                    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                    let digitailVc = mainStoryBoard.instantiateViewController(withIdentifier: "navDigitail") as! UINavigationController
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = digitailVc
                }
            }
        }
    }
   


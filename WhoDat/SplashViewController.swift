//
//  SplashViewController.swift
//  WhoDat
//
//  Created by Alan Lau on 09/06/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//

import UIKit
import Lottie

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let animationView = LAAnimationView.animationNamed("splash_animation")
        animationView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        animationView?.contentMode = .scaleAspectFill
        animationView?.center = self.view.center
        self.view.addSubview(animationView!)
        animationView?.play(completion: { (true) in
            
            // If the user has not logged out, then automatically switch to MessageViewController
            let currentUser = Api.user.CURRENT_USER
            if currentUser != nil {
                self.performSegue(withIdentifier: "messageVCSegue", sender: nil)
            }else {
                self.performSegue(withIdentifier: "mapVCSegue", sender: nil)
            }
            
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//
//  SplashViewController.swift
//  WhoDat
//
//  Created by Alan Lau on 09/06/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//

import UIKit
import Lottie
import FirebaseAuth
import SVProgressHUD

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Play splash animation
        let animationView = LAAnimationView.animationNamed("splash_animation")
        animationView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        animationView?.contentMode = .scaleAspectFill
        animationView?.center = self.view.center
        self.view.addSubview(animationView!)
        animationView?.animationSpeed = 1.2
        
        animationView?.play(completion: { (bool) in
            
            // If the user has not logged out, then automatically switch to MessageViewController, otherwise sign the user in as an anonymous user
            let currentUser = Api.user.CURRENT_USER
            if currentUser != nil {
                self.performSegue(withIdentifier: "mapVCSegue", sender: nil)
            } else {
                AuthService.loginAnonymously(onSuccess: {
                    self.performSegue(withIdentifier: "mapVCSegue", sender: nil)
                }) { (error) in
                    // Show progress indicator error
                    SVProgressHUD.showError(withStatus: error!)
                }
            }
            
        })

    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = true
    }

}

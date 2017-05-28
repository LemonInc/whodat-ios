//
//  LoginViewController.swift
//  WhoDat
//
//  Created by Alan Lau on 01/05/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {

    @IBOutlet weak var anonymousButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // If the user has not logged out, then automatically switch to MessageViewController
        let currentUser = Api.user.CURRENT_USER
        if currentUser != nil {
            self.performSegue(withIdentifier: "messageVCSegue", sender: nil)
        }
    }
    
    @IBAction func anonymousButton_TouchUpInside(_ sender: Any) {
        AuthService.loginAnonymously(onSuccess: {
            
            // Add to the number active users
            Api.numberOfActiveUsers = Api.numberOfActiveUsers + 1
            
            self.performSegue(withIdentifier: "messageVCSegue", sender: nil)
        }) { (error) in
            print(error!)
        }
    }
    
}

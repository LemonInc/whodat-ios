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
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var anonymousButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
        
        // Show progress indicator
        SVProgressHUD.show(withStatus: "Loading...")
        
        AuthService.loginAnonymously(onSuccess: {
            
            // Update and increment user count by adding to database
            let groupId = "Group 1"
            
            Api.group.addUserToGroup(groupId: groupId, onSuccess: {
                // Show progress indicator success
                SVProgressHUD.showSuccess(withStatus: "Success!")
                
                self.performSegue(withIdentifier: "messageVCSegue", sender: nil)
            }, onError: { (error) in
                // Show progress indicator error
                SVProgressHUD.showError(withStatus: error!)
            })
            
        }) { (error) in
            // Show progress indicator error
            SVProgressHUD.showError(withStatus: error!)
        }
    }
    
}

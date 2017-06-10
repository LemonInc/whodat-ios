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
            //self.performSegue(withIdentifier: "messageVCSegue", sender: nil)
        }
    }
    
    @IBAction func anonymousButton_TouchUpInside(_ sender: Any) {
        
        // Show progress indicator
        SVProgressHUD.show(withStatus: "Loading...")
        
        AuthService.loginAnonymously(onSuccess: {
            
            // Update and increment user count by adding to database
            let groupId = "Group 1"
            Api.group.setUserCount(groupId: groupId, onSuccess: { (group) in
                
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
    
    
    
//    func addUserToGroup() {
//        
//        // Check for current User ID
//        guard let currentUser = Api.user.CURRENT_USER else {
//            return
//        }
//        let currentUserId = currentUser.uid
//        
//        // Add user ID to group ID reference in "user-group" table for us to get the number of active users
//        let groupId = "Group 1"
//        let groupIdRef = Api.group.GROUP_REF.child(groupId)
//        let data = ["userId": currentUserId]
//        
//        groupIdRef.setValue(data) { (error, reference) in
//            if error != nil {
//                print(error)
//            } else {
//                
//            }
//        }
//    }
    
}

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

class MapViewController: UIViewController {
    
    @IBOutlet weak var startChatButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleChatButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Show status bar and hide navigation bar
        UIApplication.shared.isStatusBarHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func styleChatButton() {
        let background = CAGradientLayer().backgroundGradientColor()
        background.frame = startChatButton.bounds
        startChatButton.clipsToBounds = true
        startChatButton.layer.addSublayer(background)
    }
    
    @IBAction func startChatButton_TouchUpInside(_ sender: Any) {
        
        // Show progress indicator
        SVProgressHUD.show(withStatus: "Loading...")
        
        // Update and increment user count by adding to database
        let groupId = "Group 1"
        
        Api.group.addUserToGroup(groupId: groupId, onSuccess: {
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: "messageVCSegue", sender: nil)
        }, onError: { (error) in
            // Show progress indicator error
            SVProgressHUD.showError(withStatus: error!)
        })
        
    }
    
}

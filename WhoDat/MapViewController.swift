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
    var groupId = "Group 1"
    
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
    
    @IBAction func loginButton_TouchUpInside(_ sender: Any) {
        AuthService.loginAnonymously(onSuccess: {
            print("logged in")
        }) { (error) in
            print(error)
        }
    }
    
    @IBAction func logoutButton_TouchUpInside(_ sender: Any) {
        AuthService.logout(onSuccess: {
            print("logged out")
        }) { (error) in
            print(error)
        }
    }
    
    // Pass groupId to MessageViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "messageVCSegue" {
            print("Segue")
            let messageVC = segue.destination as! MessageViewController
            messageVC.groupId = self.groupId
        }
    }
    
    @IBAction func startChatButton_TouchUpInside(_ sender: Any) {
        // Update and increment user count by adding to database
        let groupId = "Group 1"
        self.performSegue(withIdentifier: "messageVCSegue", sender: nil)
    }
    
}

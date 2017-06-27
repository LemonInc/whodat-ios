//
//  LoginViewController.swift
//  WhoDat
//
//  Created by Alan Lau on 27/06/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
 
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButton_TouchUpInside(_ sender: Any) {
        AuthService.loginAnonymously(onSuccess: {
            print("logged in")
            self.performSegue(withIdentifier: "mapVCSegue", sender: nil)
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
    
}

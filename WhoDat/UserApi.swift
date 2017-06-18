//
//  UserApi.swift
//  WhoDat
//
//  Created by Alan Lau on 20/05/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class UserApi {
    
    var USER_REF = FIRDatabase.database().reference().child("users")
    
    // Grab user based on user ID
    func observeUser(userId: String, onSuccess: @escaping (User) -> Void) {
        USER_REF.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            // Grab the user data snapshot from Firebase
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict)
                onSuccess(user)
            }
        })
    }
    
    var CURRENT_USER: FIRUser? {
        if let currentUser = FIRAuth.auth()?.currentUser {
            return currentUser
        } else {
            return nil
        }
    }
    
}

//
//  AuthService.swift
//  WhoDat
//
//  Created by Alan Lau on 20/05/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class AuthService {
    
    static func loginAnonymously (onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        FIRAuth.auth()?.signInAnonymously(completion: { (anonymousUser, error) in
            if error == nil {
                // Store anonymous user information on Firebase database under 'users' entity
                let newUser = FIRDatabase.database().reference().child("users").child(anonymousUser!.uid)
                
                // Generate a random hexcode and store in user database
                let helper = Helper()
                let avatarColour = helper.generateRandomUIColor()
                let userData = ["userId": anonymousUser!.uid, "avatar": avatarColour.toHexString()]
                print(avatarColour.toHexString())
                newUser.setValue(userData)
                
                onSuccess()
            } else {
                onError(error!.localizedDescription)
                return
            }
        })
    }
    
    static func logout(onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        do {
            try FIRAuth.auth()?.signOut()
            onSuccess()
        } catch let logoutError {
            onError(logoutError.localizedDescription)
            return
        }
    }
    
}

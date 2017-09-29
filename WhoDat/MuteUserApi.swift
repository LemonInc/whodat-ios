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

class MuteUserApi {
    
    var MUTE_USER_REF = FIRDatabase.database().reference().child("muteUser")
    
    func observeMutedUsers(userId: String, onSuccess: @escaping (String) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        
        MUTE_USER_REF.child(userId).observe(.childAdded, with: { (snapshot) in
            onSuccess(snapshot.key)
        }) { (error) in
            onError(error.localizedDescription)
            return
        }
        
    }
    
}

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
    
}

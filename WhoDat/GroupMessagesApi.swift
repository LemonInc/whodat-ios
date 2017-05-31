//
//  GroupCommentApi.swift
//  WhoDat
//
//  Created by Alan Lau on 31/05/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//

import Foundation
import FirebaseDatabase

class GroupMessagesApi {
    
    var GROUP_MESSAGES_REF = FIRDatabase.database().reference().child("group-messages")
    
    // Grab all messages based on groupId passed in
    func observeGroupMessages(groupId: String, onSuccess: @escaping (String) -> Void) {
        GROUP_MESSAGES_REF.child(groupId).observe(FIRDataEventType.childAdded, with: { (messageId) in
            
            onSuccess(messageId.key)
            
        })
    }
    
}

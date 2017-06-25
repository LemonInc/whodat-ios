//
//  MessageApi.swift
//  WhoDat
//
//  Created by Alan Lau on 20/05/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//

import Foundation
import FirebaseDatabase

class MessageApi {
    
    var MESSAGE_REF = FIRDatabase.database().reference().child("messages")
    
    // Grab the message details based on messageId passed in
    func observeMessages(groupId: String, onSuccess: @escaping (Message) -> Void) {
        MESSAGE_REF.child(groupId).observe(.childAdded, with: { (snapshot) in
            // Grab the newly added message data snapshot from Firebase and add to local 'messages' JSQ array
            if let dict = snapshot.value as? [String: Any] {
                let message = Message.transformMessage(dict: dict)
                onSuccess(message)
            }
        })
    }

}

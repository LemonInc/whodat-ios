//
//  Message.swift
//  WhoDat
//
//  Created by Alan Lau on 20/05/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//

import Foundation

class Message {
    var senderId: String?
    var messageText: String?
}

extension Message {
    static func transformMessage(dict: [String: Any]) -> Message {
        let message = Message()
        message.messageText = dict["messageText"] as? String
        message.senderId = dict["senderId"] as? String
        return message
    }
}

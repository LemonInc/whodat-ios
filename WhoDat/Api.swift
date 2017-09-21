//
//  Api.swift
//  WhoDat
//
//  Created by Alan Lau on 20/05/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//

import Foundation

struct Api {
    static var message = MessageApi()
    static var user = UserApi()
    static var group = GroupApi()
    static var groupMessages = GroupMessagesApi()
    static var muteUser = MuteUserApi()
}

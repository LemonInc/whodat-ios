//
//  User.swift
//  WhoDat
//
//  Created by Alan Lau on 20/05/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//

import Foundation

class User {
    var userId: String?
    var avatar: String?
}

extension User {
    static func transformUser(dict: [String: Any]) -> User {
        let user = User()
        user.userId = dict["userId"] as? String
        user.avatar = dict["avatar"] as? String
        return user
    }
}

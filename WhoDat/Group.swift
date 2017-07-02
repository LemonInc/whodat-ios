//
//  Group.swift
//  WhoDat
//
//  Created by Alan Lau on 28/05/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//

import Foundation

class Group {
    var location: String?
    var longitude: Double?
    var latitude: Double?
    var userCount: Int?
    var users: Dictionary<String, Any>?
}

extension Group {
    static func transformGroup(dict: [String: Any]) -> Group {
        let group = Group()
        group.location = dict["location"] as? String
        group.longitude = dict["longitude"] as? Double
        group.latitude = dict["latitude"] as? Double
        group.userCount = dict["userCount"] as? Int
        group.users = dict["users"] as? Dictionary<String, Any>
        return group
    }
}

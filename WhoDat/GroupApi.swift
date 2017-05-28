//
//  User_GroupApi.swift
//  WhoDat
//
//  Created by Alan Lau on 28/05/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//

import Foundation
import FirebaseDatabase

class GroupApi {
    
    var GROUP_REF = FIRDatabase.database().reference().child("groups")
    
    func observeGroup(groupId id: String, onSuccess: @escaping (Group) -> Void) {
        GROUP_REF.child(id).observe(FIRDataEventType.value, with: { (snapshot) in
            
            // Grab the newly added group data snapshot from Firebase
            if let dict = snapshot.value as? [String: Any] {
                let group = Group.transformGroup(dict: dict)
                onSuccess(group)
            }
            
        })
    }
    
    // Method used if many people interact with the same function at the same time (I.e. likes, user counts) - this method reads the current number of users from database, increments it then pushes the value back to the database so we have a more accurate reading of the count.
    func setUserCount(groupId: String, onSuccess: @escaping (Group) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let groupRef = Api.group.GROUP_REF.child(groupId)
        groupRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var group = currentData.value as? [String : AnyObject], let uid = Api.user.CURRENT_USER?.uid {
                var users: Dictionary<String, Bool>
                users = group["users"] as? [String : Bool] ?? [:]
                var userCount = group["userCount"] as? Int ?? 0
                if let _ = users[uid] {
                    // Remove the "userCount" and remove self from "users"
                    userCount -= 1
                    users.removeValue(forKey: uid)
                } else {
                    // Add the "userCount" and add to "users"
                    userCount += 1
                    users[uid] = true
                }
                group["userCount"] = userCount as AnyObject?
                group["users"] = users as AnyObject?
                
                // Set value and report transaction success
                currentData.value = group
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let dict = snapshot?.value as? [String: Any] {
                let group = Group.transformGroup(dict: dict)
                onSuccess(group)
            }
        }
    }
}

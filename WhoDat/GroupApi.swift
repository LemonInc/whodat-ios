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
                
                self.GROUP_REF.child(id).child("userCount").setValue(group.users?.count)
                print(group.userCount)
                
                onSuccess(group)
            }
            
        })
    }
    
    func addUserToGroup(groupId: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let ref = GROUP_REF.child(groupId).child("users").child((Api.user.CURRENT_USER?.uid)!)
        ref.setValue(true)
        
        // Remove user from group if user disconnects (Closes app or if app crashes)
        ref.onDisconnectRemoveValue()
        onSuccess()
    }
    
    func removeUserFromGroup(groupId: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let ref = GROUP_REF.child(groupId).child("users").child((Api.user.CURRENT_USER?.uid)!)
        ref.removeValue()
        onSuccess()
    }
    
    // Method used if many people interact with the same function at the same time (I.e. likes, user counts) - this method reads the current number of users from database, increments it then pushes the value back to the database so we have a more accurate reading of the count.
    func setUserCount(groupId: String, onSuccess: @escaping (Group) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let groupRef = Api.group.GROUP_REF.child(groupId)
        groupRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var group = currentData.value as? [String : AnyObject], let userId = Api.user.CURRENT_USER?.uid {
                var users: Dictionary<String, Bool>
                users = group["users"] as? [String : Bool] ?? [:]
                var userCount = group["userCount"] as? Int ?? 0
                if let _ = users[userId] {
                    // Remove the "userCount" and remove self from "users"
                    userCount -= 1
                    users.removeValue(forKey: userId)
                } else {
                    // Add the "userCount" and add to "users"
                    userCount += 1
                    users[userId] = true
                }
                group["userCount"] = userCount as AnyObject?
                group["users"] = users as AnyObject?
                
                Api.group.GROUP_REF.child(groupId).child("users").child(userId).onDisconnectRemoveValue()
                
                //groupRef.child("users").child(userId).onDisconnectRemoveValue()
                //groupRef.child("userCount").onDisconnectSetValue(userCount -= 1)
                
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
    
    func createGroup() {
        
        // Create a unique ID for each group and assign the group details to it
        let newGroupRef = Api.group.GROUP_REF.childByAutoId()
        
        let location = "Canary Wharf"
        let longitute = 37.760122
        let latitute = -122.468158
        
        let groupData = ["location": location, "longitute": longitute, "latitude": latitute] as [String : Any]
        
        newGroupRef.setValue(groupData) { (error, reference) in
            if error != nil {
                print(error!)
            } else {
                let groupId = reference.key
                // SEND GROUPID TO MESSAGEVIEWCONTROLLER
                // SEGUE TO MESSAGEVIEWCONTROLLER
            }
        }
    }
    
    func observeUserTyping(groupId id: String, onSuccess: @escaping (_ isTyping: Bool) -> Void) {
        GROUP_REF.child(id).child("users").queryOrdered(byChild: "isUserTyping").queryEqual(toValue: true).observe(FIRDataEventType.value, with: { (snapshot) in
            
            // Set userIsTyping boolean to true if someone who is not the current user is typing (I.e. Firebase snapshot returns true for atleast 1 children)
            var userIsTyping = false
            
            // Returns the number of snapshot childrens
            let numberOfChildrens = snapshot.childrenCount
            
            if numberOfChildrens == 1 {
                // If number of snapshots = 1, then check if it's the current user who's typing. If it is, then set userIsTyping to false because we don't want to show elipses when current user is typing.
                if let currentUserId = Api.user.CURRENT_USER?.uid {
                    if snapshot.hasChild(currentUserId) {
                        userIsTyping = false
                    } else {
                        userIsTyping = true
                    }
                }
            } else if snapshot.hasChildren() {
                userIsTyping = true
            } else {
                userIsTyping = false
            }
            
            onSuccess(userIsTyping)
        })
    }
}

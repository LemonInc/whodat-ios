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
    
    func addUserToGroup(groupId: String, onSuccess: @escaping () -> Void) {
        let ref = GROUP_REF.child(groupId).child("users").child((Api.user.CURRENT_USER?.uid)!)
        
        // Remove user from group if user disconnects (Closes app or if app crashes)
        ref.onDisconnectRemoveValue()
        
        ref.setValue(true)
        onSuccess()
    }
    
    func removeUserFromGroup(groupId: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let ref = GROUP_REF.child(groupId).child("users").child((Api.user.CURRENT_USER?.uid)!)
        ref.removeValue()
        onSuccess()
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

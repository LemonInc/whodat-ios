//
//  MessageTableViewCell.swift
//  WhoDat
//
//  Created by Alan Lau on 20/05/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIView!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var backgroundBubble: UIView!
    
    var isSentByCurrentUser: Bool?
    
    // This method is called whenever message cell is instantiated
    var message: Message? {
        didSet {
            updateView()
        }
    }
    
    //    var user: User? {
    //        didSet {
    //            updateAvatar()
    //        }
    //    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageTextLabel.text = ""
        
        backgroundBubble.layer.cornerRadius = 20
        backgroundBubble.clipsToBounds = true
        
        // Setting maximum width of each bubble
        let screenSize = UIScreen.main.bounds.width
        let widthConstraint = NSLayoutConstraint(item: backgroundBubble, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.lessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: screenSize - 38)
        backgroundBubble.addConstraint(widthConstraint)
    }
    
    
    func updateView() {
        
        // Grab the user who sent the corresponding message based on senderId
        Api.user.observeUser(withId: (message?.senderId)!) { (user) in
            print(user.userId)
            self.updateAvatar(user: user)
        }
        
        self.messageTextLabel.text = self.message?.messageText
        
    }
    
    
    
    func updateAvatar(user: User) {
        
        // Check if message is sent by current user or not. If it is, then set 'isSentByCurrentUser' to true, otherwise set as false
        if message?.senderId == Api.user.CURRENT_USER?.uid {
            isSentByCurrentUser = true
        } else {
            isSentByCurrentUser = false
        }
        
        if isSentByCurrentUser == false {
            // Setting the avatar view colour background by grabbing user hexcode stored in Firebase and converting to UIColor
            let helper = Helper()
            let avatarColour = helper.hexStringToUIColor(hex: (user.avatar)!)
            avatar.backgroundColor = avatarColour
        }
    }
    
}

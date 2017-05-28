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
    
    // This method is called whenever message cell is instantiated
    var message: Message? {
        didSet {
            updateView()
        }
    }

    var messageType: String?
    
//    var messageType: String? {
//        didSet {
//            updateAvatar()
//        }
//    }
    
    var user: User? {
        didSet {
            updateAvatar()
        }
    }
    
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateView() {
        messageTextLabel.text = message?.messageText
    }
    
    func updateAvatar() {
        if messageType == "IncomingChatCell" {
            print(user?.avatar)
            avatar.backgroundColor = UIColor.yellow
        }
    }

}

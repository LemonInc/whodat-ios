//
//  MessageViewController.swift
//  WhoDat
//
//  Created by Alan Lau on 20/05/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

class MessageViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var typingGif: UIImageView!
    @IBOutlet weak var anchorDownButton: UIButton!
    @IBOutlet weak var userCountLabel: UILabel!
    @IBOutlet weak var messageTextInput: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var groupId: String!
    var messages = [Message]()
    var users = [User]()
    var firstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBarStyle()
        
        // PASS GROUP ID WHEN MAP IS CONFIGURED
        groupId = "Group 1"
        
        // Setting cell row height to be dynamic based on content height
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 78
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Disable send button by default
        sendButton.isEnabled = false
        
        // Set delegate of text input so we can utilise textViewDidChange method
        messageTextInput.delegate = self
        
        // Center vertically text
        messageTextInput.centerVertically()
        
        configureSendButton()
        loadGroupDetails()
        loadMessages()
        showTypingIndicator()
        
        // Tap gesture to hide keyboard when tableview's pressed
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapGesture.delegate = self
        self.tableView.addGestureRecognizer(tapGesture)
        
        // Methods to handle when keyboard is shown or hidden to push content up
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // Set status bar text colour to white - only applicable for this view
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    // Setting gradient as an image background to the navigation bar
    func setNavigationBarStyle() {
        
        let navBar = self.navigationController?.navigationBar
        navBar?.isTranslucent = false
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIApplication.shared.statusBarFrame.width, height: UIApplication.shared.statusBarFrame.height + self.navigationController!.navigationBar.frame.height)
        let colorTop = UIColor(red:0.39, green:0.84, blue:0.26, alpha:1.0).cgColor
        let colorBottom = UIColor(red:0.17, green:0.71, blue:0.45, alpha:1.0).cgColor
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        navBar?.setBackgroundImage(image, for: UIBarMetrics.default)
        
    }
    
    @IBAction func anchorDownButton_TouchUpInside(_ sender: Any) {
        scrollToLastMessage(animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // If the user scroll position is greater than tableview height - 1000 (Further down the page), then hide anchor button. Otherwise if scroll position is less than tableview height - 1000 then show the anchor button
        if self.tableView.contentOffset.y >= (self.tableView.contentSize.height - 1000) {
            anchorDownButton.isHidden = true
        } else if self.tableView.contentOffset.y <= (self.tableView.contentSize.height - 1000) {
            anchorDownButton.isHidden = false
        }
    }
    
    // Function called when user touches screen, this will be used for dismissing the keyboard
    func dismissKeyboard(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
    // Move view up by keyboard height when keyboard is shown
    func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    // Move view down by keyboard height when keyboard is hidden
    func keyboardWillHide(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    // Disable send button if the user has not entered value on message text field
    func configureSendButton() {
        if let messageText = messageTextInput.text, !messageText.isEmpty {
            // Enable button if the user has entered something in text field
            self.enableSendButton()
        } else {
            // Disable button if text field is empty
            self.disableSendButton()
        }
    }
    
    func enableSendButton() {
        sendButton.layer.borderWidth = 0
        sendButton.layer.masksToBounds = true
        sendButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        sendButton.backgroundColor = UIColor(red:0.33, green:0.81, blue:0.31, alpha:1.0)
        
        sendButton.isEnabled = true
    }
    
    func disableSendButton() {
        sendButton.setTitleColor(UIColor(red:0.92, green:0.93, blue:0.93, alpha:1.0), for: UIControlState.normal)
        sendButton.backgroundColor = UIColor.white
        sendButton.layer.borderWidth = 1
        sendButton.layer.borderColor = UIColor(red:0.93, green:0.95, blue:0.97, alpha:1.0).cgColor
        sendButton.layer.cornerRadius = 8
        sendButton.isEnabled = false
    }
    
    // Grab group details and assign to view, observe methods trigger whenever Firebase changes, so it's an on-going function
    func loadGroupDetails() {
        Api.group.observeGroup(groupId: groupId) { (group) in
            
            // Set user count value
            guard let userCount = group.userCount else {
                return
            }
            self.userCountLabel.text = String(userCount)
            
            // Set navigation title to group location
            guard let location = group.location else {
                return
            }
            self.navigationItem.title = location
        }
    }
    
    // Grab all messages from database and assign to local messages array
    func loadMessages() {
        
        // Grab all messages from assocated group ID from group-messages table
        Api.groupMessages.observeGroupMessages(groupId: self.groupId) { (messageId) in
            
            // After grabbing all message ID's, then grab the message details from the messages table
            Api.message.observeMessages(messageId: messageId, onSuccess: { (message) in
                
                // Also grab the user detail corresponding to the message sender ID
                self.fetchUser(senderId: message.senderId!, onSuccess: {
                    
                    // Scroll to the bottom upon first load
                    if self.firstLoad == true {
                        self.scrollToLastMessage(animated: false)
                        self.firstLoad = false
                    } else {
                        // If this is not first load
                        
                        // If the user scrolls to the bottom, set 'scrolledBottom' to true
                        var scrolledToBottom = false
                        if self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.frame.size.height) {
                            scrolledToBottom = true
                        }
                        
                        // If user has scrolled to the bottom, then scroll to last message when new message comes in
                        if scrolledToBottom == true {
                            self.messages.append(message)
                            self.tableView.reloadData()
                            self.scrollToLastMessage(animated: false)
                        } else {
                            self.messages.append(message)
                            self.tableView.reloadData()
                        }
                    }
                    
                })
            })
        }
        
    }
    
    // Scroll to last message
    func scrollToLastMessage(animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
    
    // Grab the user who sent the corresponding message based on senderId
    func fetchUser(senderId: String, onSuccess: @escaping () -> Void) {
        Api.user.observeUser(withId: senderId) { (user) in
            self.users.append(user)
            onSuccess()
        }
    }
    
    @IBAction func sendButton_TouchUpInside(_ sender: Any) {
        
        // Check for current User ID
        guard let currentUser = Api.user.CURRENT_USER else {
            return
        }
        let currentUserId = currentUser.uid
        
        // Create a unique ID for each message and assign the message values to the database
        let messageRef = Api.message.MESSAGE_REF
        let newMessageId = messageRef.childByAutoId().key
        let newMessageRef = messageRef.child(newMessageId)
        
        let messageData = ["messageText": messageTextInput.text!, "senderId": currentUserId]
        
        newMessageRef.setValue(messageData) { (error, reference) in
            if error != nil {
                print(error!)
            } else {
                // When successfully added message to database, also create a one-to-many table (group-messages) to store all message ID's connecting to a specific group ID
                let groupMessageRef = Api.groupMessages.GROUP_MESSAGES_REF.child(self.groupId).child(newMessageId)
                groupMessageRef.setValue(true, withCompletionBlock: { (error, reference) in
                    if error != nil {
                        print(error!)
                    } else {
                        // Clear text field and button state
                        self.clear()
                        
                        // Hides keyboard once finished
                        self.view.endEditing(true)
                        
                        self.scrollToLastMessage(animated: false)
                    }
                })
            }
        }
        
    }
    
    // Clear text field and button state
    func clear() {
        self.messageTextInput.text = ""
        disableSendButton()
    }
    
    @IBAction func logoutButton_TouchUpInside(_ sender: Any) {
        
        // Update and decrement user count by removing from database
        let groupId = "Group 1"
        Api.group.setUserCount(groupId: groupId, onSuccess: { (group) in
            
            // Logout user after user count has been updated
            AuthService.logout(onSuccess: {
                // After log out, switch to login screen
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let signInVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                self.present(signInVC, animated: true, completion: nil)
            }, onError: { (error) in
                print(error!)
            })
            
        }) { (error) in
            print(error!)
        }
    }

    func showTypingIndicator() {
        Api.group.observeUserTyping(groupId: self.groupId) { (isUserTyping) in
            if isUserTyping == true {
                self.typingGif.isHidden = false
                self.typingGif.loadGif(name: "typing")
            } else {
                self.typingGif.isHidden = true
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
}

extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        let user = users[indexPath.row]
        var cellIdentifier = ""
        
        // Check if message is sent by current user or not - if it is, then it's an outgoing message, otherwise it's an incoming message
        if message.senderId == Api.user.CURRENT_USER?.uid {
            cellIdentifier = "OutgoingChatCell"
        } else {
            cellIdentifier = "IncomingChatCell"
        }
        
        // Set cell layout based on whether the message is incoming or outgoing
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageTableViewCell
        
        // Pass the current indexPath.row message data to MessageTableViewCell for use
        cell.message = message
        cell.user = user
        
        return cell

    }
}

extension MessageViewController: UITextViewDelegate {
    
    // Triggers when user starts
    func textViewDidChange(_ textView: UITextView) {
        
        // Add time interval to keyboard input before triggering 'textViewStoppedTyping'
        var timer: Timer? = nil
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.textViewDidEndEditing), userInfo: nil, repeats: false)
        
        // Set user typing status to true when user starts typing
        if let currentUserId = Api.user.CURRENT_USER?.uid {
            let isUserTypingRef = Api.group.GROUP_REF.child(self.groupId).child("users").child(currentUserId).child("isUserTyping")
            isUserTypingRef.setValue(true) { (error, reference) in
            }
        }
        
        // Disable send button if the user has not entered value on message text field
        configureSendButton()
    }
    
    // Triggers when user stops typing or when keyboard closes
    func textViewDidEndEditing(_ textView: UITextView) {
        
        // Set user typing status to false if user stops typing
        if let currentUserId = Api.user.CURRENT_USER?.uid {
            let isUserTypingRef = Api.group.GROUP_REF.child(self.groupId).child("users").child(currentUserId).child("isUserTyping")
                isUserTypingRef.setValue(false) { (error, reference) in
            }
        }
        
    }
    
}

extension UITextView {
    
    // Center vertically on text view input
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
}

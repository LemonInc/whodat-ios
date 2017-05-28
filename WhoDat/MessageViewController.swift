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

    @IBOutlet weak var activeUsersLabel: UILabel!
    @IBOutlet weak var messageTextInput: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    
    var messages = [Message]()
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("number of active users \(Api.numberOfActiveUsers)")
        
        // Setting cell row height to be dynamic based on content height
        tableView.dataSource = self
        tableView.estimatedRowHeight = 78
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Disable send button by default
        sendButton.isEnabled = false
        
        // Set delegate of text input so we can utilise textViewDidChange method
        messageTextInput.delegate = self
        
        // Center vertically text
        messageTextInput.centerVertically()
        
        configureSendButton()
        loadMessages()
        
        // Tap gesture to hide keyboard when tableview's pressed
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapGesture.delegate = self
        self.tableView.addGestureRecognizer(tapGesture)
        
        // Methods to handle when keyboard is shown or hiden to bring up the messages text field area
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrolling")
    }
    
    // Scroll to last message
    func scrollToLastMessage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
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
    
    func keyboardWillShow(_ notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.3) {
            self.constraintToBottom.constant = keyboardFrame!.height
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.constraintToBottom.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    // Disable send button if the user has not entered value on message text field
    func configureSendButton() {
        if let messageText = messageTextInput.text, !messageText.isEmpty {
            // Button settings when button is enabled
            self.enableSendButton()
        } else {
            // Button settings when button is disabled
            self.disableSendButton()
        }
    }
    
    func enableSendButton() {
        sendButton.setTitleColor(UIColor(red:0.05, green:0.08, blue:0.12, alpha:1.0), for: UIControlState.normal)
        sendButton.backgroundColor = UIColor(red:1.00, green:0.83, blue:0.02, alpha:1.0)
        sendButton.layer.cornerRadius = 8
        sendButton.layer.borderWidth = 0
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
    
    // Grab all messages from database and assign to local messages array
    func loadMessages() {
        Api.message.observeMessages { (messages) in
            self.fetchUser(senderId: messages.senderId!, onSuccess: {
                self.messages.append(messages)
                self.tableView.reloadData()
                self.scrollToLastMessage()
            })
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
        let newMessageRef = Api.message.MESSAGE_REF.childByAutoId()
        let messageData = ["messageText": messageTextInput.text!, "senderId": currentUserId]
        
        newMessageRef.setValue(messageData) { (error, reference) in
            if error != nil {
                print(error)
            } else {
                // Clear text field and button state
                self.clean()
                
                // Hides keyboard once finished
                self.view.endEditing(true)
            }
        }
        
    }
    
    // Clear text field and button state
    func clean() {
        self.messageTextInput.text = ""
        disableSendButton()
    }
    
    @IBAction func logoutButton_TouchUpInside(_ sender: Any) {
        AuthService.logout(onSuccess: {
            // After log out, switch to login screen
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(signInVC, animated: true, completion: nil)
        }) { (error) in
            print(error)
        }
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
        
        // Check if message is sent by current user or not then assign the cellIdentifier to be used
        if message.senderId == Api.user.CURRENT_USER?.uid {
            cellIdentifier = "OutgoingChatCell"
        } else {
            cellIdentifier = "IncomingChatCell"
        }
        
        // Set cell layout based on whether the message is incoming or outgoing
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageTableViewCell
        
        // Pass the current indexPath.row message data to MessageTableViewCell for use
        cell.message = message
        
        return cell

    }
}

extension MessageViewController: UITextViewDelegate {
    
    // Disable send button if the user has not entered value on message text field
    func textViewDidChange(_ textView: UITextView) {
        configureSendButton()
    }
    
}

extension UITextView {
    
    // Center vertically the text view input
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
}

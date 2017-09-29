
import UIKit
import KMPlaceholderTextView
import AVFoundation
import SVProgressHUD

class MessageViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var typingGif: UIImageView!
    @IBOutlet weak var anchorDownButton: UIButton!
    @IBOutlet weak var messageTextInput: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var groupId: String!
    var messages = [Message]()
    var mutedUsers = [String]()
    var firstLoad = true
    var userCountButton: UIButton!
    var player: AVAudioPlayer = AVAudioPlayer()
    var keyboardShown = 0
    var initialKeyboardHeight = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadGroupDetails()
        loadMessages()
        setUpView()
        showTypingIndicator()
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MessageViewController.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                let actionSheet = UIAlertController(title: "Title", message: "Lorem ipsum dolor sit", preferredStyle: .actionSheet)
                
                let muteUserAction = UIAlertAction(title: "Mute user", style: .default, handler: {(alert: UIAlertAction!) -> Void in
                    
                    // Mute sender by grabbing senderID and storing this on Firebase
                    let muteMessage = self.messages[indexPath.row]
                    let muteSenderId = muteMessage.senderId!
                    self.muteUser(senderId: muteSenderId)
                    
                    // For each message with matching senderID, change the text to "muted"
                    for i in 0 ..< self.messages.count {
                        if self.messages[i].senderId == muteSenderId {
                            self.messages[i].messageText = "muted"
                            print(self.messages[i].messageText!)
                            self.tableView.reloadData()
                        }
                    }
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                actionSheet.addAction(muteUserAction)
                actionSheet.addAction(cancelAction)
                
                self.present(actionSheet, animated: true, completion: nil)
                
            }
        }
    }
    
    func muteUser(senderId: String) {
        // Check for current User ID
        guard let currentUser = Api.user.CURRENT_USER else {
            return
        }
        let currentUserId = currentUser.uid
        
        let newMuteUserRef = Api.muteUser.MUTE_USER_REF.child(currentUserId).child(senderId)
        
        newMuteUserRef.setValue(true, withCompletionBlock: { (error, ref) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
                return
            } else {
                
            }
        })
    }
    
    func setUpView() {
        // Setting cell row height to be dynamic based on content height
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 78
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set delegate of text input so we can utilise textViewDidChange method
        messageTextInput.delegate = self
        
        // Center vertically text
        messageTextInput.centerVertically()
        
        configureSendButton()
        
        // Tap gesture to hide keyboard when tableview's pressed
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapGesture.delegate = self
        self.tableView.addGestureRecognizer(tapGesture)
        
        // Methods to handle when keyboard is shown or hidden to push content up
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // This enables the swipe gesture on navigation bar when custom back button is used, if we don't use custom back button then the swipe works without this.
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // Method to handle when app comes to foreground (I.e. unlock screen and app appears)
        NotificationCenter.default.addObserver(self, selector: #selector(MessageViewController.addUserToGroup), name:
            NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func addUserToGroup() {
        Api.group.addUserToGroup(groupId: self.groupId) { 
            return
        }
    }
    
    func setUserCountButton() {
        userCountButton = UIButton(type: .custom)
        userCountButton.setImage(UIImage(named: "user_count"), for: .normal)
        userCountButton.isEnabled = false
        userCountButton.titleLabel?.font = UIFont(name: "WorkSans-Light", size: 18)
        userCountButton.adjustsImageWhenHighlighted = false
        userCountButton.sizeToFit()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: userCountButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        removeUserFromGroup()
    }
    
    // Set status bar text colour to white - only applicable for this view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setNavigationBarStyle()
        setUserCountButton()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    // Setting gradient as an image background to the navigation bar
    func setNavigationBarStyle() {
        
        let navBar = self.navigationController?.navigationBar
        navBar?.isTranslucent = false
        
        let background = CAGradientLayer().backgroundGradientColor()
        background.frame = CGRect(x: 0, y: 0, width: UIApplication.shared.statusBarFrame.width, height: UIApplication.shared.statusBarFrame.height + self.navigationController!.navigationBar.frame.height)
        
        UIGraphicsBeginImageContext(background.bounds.size)
        background.render(in: UIGraphicsGetCurrentContext()!)
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
        
        // Get screen height
        let screenSize: CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height
        
        // Get keyboard height
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        // Get input field and navigation bar height
        let inputFieldHeight = 65
        let navigationBarHeight = UIApplication.shared.statusBarFrame.height + self.navigationController!.navigationBar.frame.height
        
        // Calculate tableview height when keyboard is shown
        let pushedUpTableViewHeight = Int(screenHeight) - Int(keyboardHeight) - inputFieldHeight - Int(navigationBarHeight)
        print(pushedUpTableViewHeight)
        
        // Only push view up if messages exist and the last cell will be hidden when keyboard is shown
        if messages.count > 0 {
            // Get last cell height
            let indexpath = NSIndexPath(row: messages.count - 1, section: 0)
            let rect = self.tableView.rectForRow(at: indexpath as IndexPath)
            let lastCellHeight = rect.size.height
            
            // Get last cell position
            let lastCellStartPosition = self.tableView.convert(rect, to: tableView.superview)
            let lastCellPosition = Int(lastCellStartPosition.origin.y + lastCellHeight)
            
            if lastCellPosition > pushedUpTableViewHeight {
                self.view.frame.origin.y = 64
                
                if self.view.frame.origin.y == 64 {
                    self.view.frame.origin.y -= keyboardHeight
                }
            } else {
                UIView.animate(withDuration: 0.1, animations: {
                    self.bottomConstraint.constant = keyboardHeight
                })
            }
            
        }
        
    }
    
    // Move view down by keyboard height when keyboard is hidden
    func keyboardWillHide(_ notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 64 {
                self.view.frame.origin.y += keyboardSize.height
            } else {
                UIView.animate(withDuration: 0.1, animations: {
                    self.bottomConstraint.constant = 0
                })
            }
        }
    }
    
    // Disable send button if the user has not entered value on message text field
    func configureSendButton() {
        // Disable send button by default
        sendButton.isEnabled = false
        
        if let _ = messageTextInput.text, !messageTextInput.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            // Enable button if the user has entered something in text field - excludes empty spaces and lines
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
        Api.group.observeGroup(groupId: groupId, onSuccess: { (group) in
            // Set user count value
            guard let userCount = group.users?.count else {
                return
            }
            self.userCountButton.setTitle(" \(String(userCount))", for: .normal)
            self.userCountButton.sizeToFit()
            
            // Set navigation title to group location
            guard let location = group.location else {
                return
            }
            self.navigationItem.title = location
        }) { (error) in
            SVProgressHUD.showError(withStatus: error!)
        }
    }
    
    func getMutedUsers(onSuccess: @escaping () -> Void) {
        guard let currentUser = Api.user.CURRENT_USER else {
            return
        }
        let currentUserId = currentUser.uid
        
        Api.muteUser.observeMutedUsers(userId: currentUserId, onSuccess: { (mutedUserId) in
            //print("muted user: \(mutedUserId)")
            self.mutedUsers.append(mutedUserId)
            print("muted user count: \(self.mutedUsers.count)")
        }) { (error) in
            SVProgressHUD.showError(withStatus: error!)
        }
        
        onSuccess()
    }
    
    // Grab all messages from database and assign to local messages array
    func loadMessages() {
        
        // Grab all muted users from current user session ID
        self.getMutedUsers {
            
            // After grabbing all message ID's, then grab the message details from the messages table
            Api.message.observeMessages(groupId: self.groupId, onSuccess: { (message) in
                
                // Scroll to the bottom upon first load
                if self.firstLoad == true {
                    self.scrollToLastMessage(animated: false)
                    self.firstLoad = false
                } else {
                    // If this is not first load and the user scrolls to the bottom, set 'scrolledBottom' to true
                    var scrolledToBottom = false
                    if self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.frame.size.height) {
                        scrolledToBottom = true
                    }
                    
                    // If user has scrolled to the bottom, then scroll to last message when new message comes in
                    if scrolledToBottom == true {
                        self.scrollToLastMessage(animated: false)
                    }
                }
                
                // For each message with matching senderID, change the text to "muted"
                for i in 0 ..< self.mutedUsers.count {
                    let muteSenderId = self.mutedUsers[i]
                    
                    if message.senderId == muteSenderId {
                        message.messageText = "muted"
                    } else {
                        
                    }
                }
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }) { (error) in
                SVProgressHUD.showError(withStatus: error!)
            }
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
    
    @IBAction func sendButton_TouchUpInside(_ sender: Any) {

        // Check for current User ID
        guard let currentUser = Api.user.CURRENT_USER else {
            return
        }
        let currentUserId = currentUser.uid
        
        // Create a unique ID for each message and assign the message values to the database
        let messageRef = Api.message.MESSAGE_REF
        let newMessageId = messageRef.childByAutoId().key
        let newMessageRef = Api.message.MESSAGE_REF.child(self.groupId).child(newMessageId)
        
        // Also store the timestamp of when the message is sent for ordering purposes
        let timestamp = Int(Date().timeIntervalSince1970)
        
        let messageData = ["messageText": messageTextInput.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), "senderId": currentUserId, "timestamp": timestamp] as [String : Any]
        
        newMessageRef.setValue(messageData) { (error, reference) in
            if error != nil {
                print(error!)
            } else {
                // Clear text field and button state after message is stored in database
                self.playSound()
                self.clear()
                self.setUserTypingStatusToFalse()
                self.scrollToLastMessage(animated: false)
            }
        }
        
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "send", withExtension: ".aiff") else {
            print("error")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func setUserTypingStatusToFalse() {
        let isUsertypingRef = Api.group.GROUP_REF.child("Group 1").child("users").child((Api.user.CURRENT_USER?.uid)!).child("isUserTyping")
        isUsertypingRef.setValue(false)
    }
    
    // Clear text field and button state
    func clear() {
        self.messageTextInput.text = ""
        disableSendButton()
    }
    
    func removeUserFromGroup() {
        Api.group.removeUserFromGroup(groupId: self.groupId, onSuccess: {
            self.navigationController?.popViewController(animated: true)
        }) { (error) in
            print(error!)
        }
    }
    
    @IBAction func backButton_TouchUpInside(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
        
        self.tableView.layoutIfNeeded()
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        print(message.messageText)
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


import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import Lottie

class MapViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var startChatButton: UIButton!
    let groupId = "Group 1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleChatButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Show status bar and hide navigation bar
        UIApplication.shared.isStatusBarHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func styleChatButton() {
        let background = CAGradientLayer().backgroundGradientColor()
        background.frame = startChatButton.bounds
        startChatButton.clipsToBounds = true
        startChatButton.layer.addSublayer(background)
    }
    
    // Pass groupId to MessageViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "messageVCSegue" {
            let messageVC = segue.destination as! MessageViewController
            messageVC.groupId = self.groupId
        }
    }
    
    @IBAction func startChatButton_TouchUpInside(_ sender: Any) {
        // Update and increment user count
        Api.group.addUserToGroup(groupId: self.groupId) { 
            self.performSegue(withIdentifier: "messageVCSegue", sender: nil)
        }
    }
    
}

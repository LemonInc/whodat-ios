
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
        
        let animationView = LAAnimationView.animationNamed("splash_animation")
        animationView?.frame = CGRect(x: 0, y: 0, width: self.image.frame.size.width, height: self.image.frame.size.height)
        animationView?.contentMode = .scaleAspectFill
        animationView?.center = self.image.center
        animationView?.loopAnimation = true
        self.view.addSubview(animationView!)
        animationView?.animationSpeed = 1
        animationView?.play()
        
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
    
    @IBAction func loginButton_TouchUpInside(_ sender: Any) {
        AuthService.loginAnonymously(onSuccess: {
            print("logged in")
        }) { (error) in
            print(error)
        }
    }
    
    @IBAction func logoutButton_TouchUpInside(_ sender: Any) {
        AuthService.logout(onSuccess: {
            print("logged out")
        }) { (error) in
            print(error)
        }
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

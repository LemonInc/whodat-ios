
import UIKit
import Lottie

class WalkthroughContentViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var walkthroughImage: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var index = 0
    var imageFileName = ""
    var titleText = ""
    var descriptionText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playAnimation()
        
        styleNextButton()
        
        titleLabel.text = titleText
        descriptionLabel.text = descriptionText
        
        let attrString = NSMutableAttributedString(string: descriptionText)
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        attrString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange(location: 0, length: descriptionText.characters.count))
        descriptionLabel.attributedText = attrString
        descriptionLabel.textAlignment = NSTextAlignment.center
        
        
        walkthroughImage.image = UIImage(named: imageFileName)
        
        pageControl.currentPage = index
        
        switch index {
        case 0:
            
            //walkthroughImage.loadGif(name: "onboarding")
            nextButton.setTitle("Ok, got it", for: .normal)
        case 1:
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "hasViewedWalkthrough")
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Hide status bar
        UIApplication.shared.isStatusBarHidden = true
    }
    
    func playAnimation() {
        let animationView = LOTAnimationView(name: "carousel")
        animationView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width)
        animationView.contentMode = .scaleAspectFill
        self.view.addSubview(animationView)
        animationView.animationSpeed = 1
        animationView.loopAnimation = true
        animationView.play()
    }
    
    func styleNextButton() {
        let background = CAGradientLayer().backgroundGradientColor()
        background.frame = nextButton.bounds
        nextButton.clipsToBounds = true
        nextButton.layer.addSublayer(background)
    }
    
    @IBAction func nextButton_TouchUpInside(_ sender: Any) {
        switch index {
        case 0:
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "hasViewedWalkthrough")
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }

}

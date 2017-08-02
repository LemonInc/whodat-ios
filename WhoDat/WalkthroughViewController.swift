
import UIKit

class WalkthroughViewController: UIPageViewController, UIPageViewControllerDataSource {

    var titleText = ["Chat anonymously", ""]
    var descriptionText = ["Join chat spots around you and stay updated with what's happening locally.", ""]
    var image = ["londontest.jpg", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        // On initial set up
        if let startingVC = viewControllerAtIndex(index: 0) {
            setViewControllers([startingVC], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        }
    }
    
    // Showing next page
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        // Get current index from WalkthroughContentViewController
        var index = (viewController as! WalkthroughContentViewController).index
        
        index += 1
        return viewControllerAtIndex(index: index)
    }
    
    // Showing previous page
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        // Get current index from WalkthroughContentViewController
        var index = (viewController as! WalkthroughContentViewController).index
        
        index -= 1
        return viewControllerAtIndex(index: index)
    }
    
    func viewControllerAtIndex(index: Int) -> WalkthroughContentViewController? {
        if index < 0 || index >= titleText.count {
            return nil
        }
        if let pageContentVC = storyboard?.instantiateViewController(withIdentifier: "WalkthroughContentViewController") as? WalkthroughContentViewController {
            pageContentVC.titleText = titleText[index]
            pageContentVC.descriptionText = descriptionText[index]
            pageContentVC.imageFileName = image[index]
            pageContentVC.index = index
            return pageContentVC
        }
        else {
            return nil
        }
    }
    
    func forward(index: Int) {
        if let nextVC = viewControllerAtIndex(index: index + 1) {
            setViewControllers([nextVC], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        }
    }

}

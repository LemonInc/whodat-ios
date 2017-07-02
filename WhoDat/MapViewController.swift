
import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import Lottie

import GoogleMaps
import MapKit
import CoreLocation

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var startChatButton: UIButton!
    let groupId = "Group 1"
    
    // Variable for maps
    var mapView: GMSMapView!
    var manager = CLLocationManager()
    var currentLocation: CLLocation?
    var zoomLevel: Float = 15.0
    
    // Function to manage user location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,longitude: location.coordinate.longitude,zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        mapView.isMyLocationEnabled = true
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleChatButton()

        print("map appears")
        
        /*=============== Current location method*/
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        mapView = GMSMapView(frame: view.frame)
        
        mapView.delegate = self
        
        view.addSubview(mapView)
    }
    
    @IBOutlet weak var chatBtn: UIButton!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.view.bringSubview(toFront: self.chatBtn)
        
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

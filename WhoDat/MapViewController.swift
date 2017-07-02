
import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import CoreLocation
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startChatButton: UIButton!
    
    let groupId = "Group 1"
    let manager = CLLocationManager()
    var userLocation: CLLocation? = nil
    var userLongitude: Double? = nil
    var userLatitude: Double? = nil
    var userLocationName: String? = ""
    var groups = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleChatButton()
        setupMapView()
        loadGroups()
        
        let theLocation: MKUserLocation = mapView.userLocation
        theLocation.title = "I'm here!"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Show status bar and hide navigation bar
        UIApplication.shared.isStatusBarHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func loadGroups() {
        Api.group.observeGroups { (group) in
            self.groups.append(group)
            self.addAnnotation(latitude: group.latitude!, longitude: group.longitude!)
        }
    }
    
    func setupMapView() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.mapType = MKMapType.standard
        mapView.showsUserLocation = true
        
        // Colour of pulse and user icon
        mapView.tintColor = UIColor(red:0.00, green:0.71, blue:1.00, alpha:1.0)
    }
    
    func addAnnotation(latitude: Double, longitude: Double) {
        let pinLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.title = " "
        annotation.coordinate = pinLocation
        mapView.addAnnotation(annotation)
    }
    
    // Function called everytime the user has a new location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        // Set zoom amount (span) in location
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        
        self.userLocation = CLLocation(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        // Set users latest location to be plotted on map
        let userLocation2D = CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude)
        
        // Set region using location and span
        let region: MKCoordinateRegion = MKCoordinateRegionMake(userLocation2D, span)
        mapView.setRegion(region, animated: true)
    }
    
    func getLocationDetails(location: CLLocation, onSuccess: @escaping () -> Void) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Location name
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                // Set global variable to be consumed by start chat button
                self.userLocationName = locationName as String
            }
            
            // City
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                print(city)
            }
            
            // Set global variable to be consumed by start chat button
            self.userLongitude = location.coordinate.longitude
            self.userLatitude = location.coordinate.latitude
            
            onSuccess()
        })
    }

    // Handling of annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isEqual(mapView.userLocation) {
            return nil
        }

        // For better performance, always try to reuse existing annotations.
        let annotationIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)

        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            //annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        annotationView!.image = UIImage(named: "hotspot")
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("selected")
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
        
        getLocationDetails(location: self.userLocation!) {
            Api.group.createGroup(location: self.userLocationName!, longitude: self.userLongitude!, latitude: self.userLatitude!, onSuccess: { (groupId) in
                // Update and increment user count then show messageViewController
//                Api.group.addUserToGroup(groupId: self.groupId) {
//                    self.performSegue(withIdentifier: "messageVCSegue", sender: nil)
//                }
            }) { (error) in
                print(error!)
            }
        }
        
    }
    
}

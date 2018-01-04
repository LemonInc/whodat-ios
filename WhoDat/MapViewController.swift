
import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import CoreLocation
import MapKit

//function to calculate distance between user and hotspot
extension CLLocationCoordinate2D {
    
    func distance(to coordinate: CLLocationCoordinate2D) -> Double {
        
        return MKMetersBetweenMapPoints(MKMapPointForCoordinate(self), MKMapPointForCoordinate(coordinate))
    }
}

//Function for queuing map data task
extension DispatchQueue {
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startChatButton: UIButton!
    
    var groupId = "Group 1"
    let manager = CLLocationManager()
    var userLocation: CLLocation? = nil
    var userLongitude: Double? = nil
    var userLatitude: Double? = nil
    var userLocationName: String? = ""
    var groups = [Group]()
    var selectedAnnotation: Group?
    var mapFinishedLoading = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Log user in anonymously if user has not logged in yet
        if Api.user.CURRENT_USER == nil {
            loginAnonymously()
        }
        
        styleChatButton()
        setUserTrackingButton()
        
    }
    
    func logout() {
        AuthService.logout(onSuccess: {
            print("logged out")
        }) { (error) in
            //
        }
    }
    
    func loginAnonymously() {
        AuthService.loginAnonymously(onSuccess: {
            print("logged in")
        }) { (error) in
            print(error)
        }
    }
    
    //Add annotation method
    func addAnnotation(latitude: Double, longitude: Double, type: String, id: String, name: String) {
        
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
//        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
//        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
//        self.mapView.setRegion(region, animated: true)
        
        let annotation =  CustomPointAnnotation()
        
        switch (type){
        case "Train":
            annotation.imageName = "train"
            
        case "Hospital":
            annotation.imageName = "hospital"
            
        case "Airport":
            annotation.imageName = "airport"
            
        case "School":
            annotation.imageName = "school"
            
        case "Park":
            annotation.imageName = "park"
            
        case "Stadium":
            annotation.imageName = "stadiuml"
            
        case "Museum":
            annotation.imageName = "museum"
            
        default:
            print("Integer out of range")
        }
        
        annotation.title = id
        annotation.subtitle = name
        annotation.coordinate = location
        
        self.mapView.addAnnotation(annotation)
        
    }

    
    //Annotation select
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let annotation = view.annotation {
            self.groupId = annotation.title!!
            //print("Your annotation title: \(String(describing: self.groupId))");
            
            Api.group.createGroup(groupId: self.groupId, location: annotation.subtitle!!, onSuccess: {
                mapView.deselectAnnotation(annotation, animated: false)
                self.performSegue(withIdentifier: "messageVCSegue", sender: nil)
            }) { (error) in
                SVProgressHUD.showError(withStatus: error!)
            }
        }
        
    }
    
    //Custom annotation
    class CustomPointAnnotation: MKPointAnnotation {
        var imageName: String!
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Get assigned user defaults to check if walkthrough has been seen already, if it has then don't show, otherwise show
        let defaults = UserDefaults.standard
        let hasViewedWalkthrough = defaults.bool(forKey: "hasViewedWalkthrough")
        
        if hasViewedWalkthrough != true {
            // Show walkthrough page
            if let pageVC = storyboard?.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController {
                present(pageVC, animated: true, completion: nil)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.setupMapView()
        
        // Show status bar and hide navigation bar
        UIApplication.shared.isStatusBarHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if self.mapFinishedLoading == 1 {

            //Wait for map to finish rendering before rendering JSON data
            self.waitForMapToLoadBeforeRenderingParsingData()

            mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
            self.mapFinishedLoading += 1
        }
    }
    
    func loadGroups() {
        Api.group.observeGroups(onSuccess: { (group) in
            self.groups.append(group)
            self.addAnnotation(latitude: group.latitude!, longitude: group.longitude!)
        }) { (error) in
            SVProgressHUD.showError(withStatus: error!)
        }
    }
    
    func setUserTrackingButton() {
        
        let button = MKUserTrackingButton(mapView: mapView)
        button.layer.backgroundColor = UIColor(white: 1, alpha: 1).cgColor
        button.tintColor = UIColor(red:0.01, green:0.81, blue:0.37, alpha:1.0)
        button.frame.size = CGSize(width: 50, height: 50)
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        let scale = MKScaleView(mapView: mapView)
        scale.legendAlignment = .trailing
        scale.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scale)
        
        NSLayoutConstraint.activate([button.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
                                     button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
                                     scale.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -10),
                                     scale.centerYAnchor.constraint(equalTo: button.centerYAnchor)])
        
    }
    
//    func setUserTrackingButton() {
//
//        // Mapkit tracking button
//        let trackingButton: MKUserTrackingBarButtonItem = MKUserTrackingBarButtonItem.init(mapView: mapView)
//        trackingButton.customView?.tintColor = UIColor(red:0.01, green:0.81, blue:0.37, alpha:1.0)
//        trackingButton.customView?.frame.size = CGSize(width: 50, height: 50)
//
//        // Need to use toolbar to show item on page rather than on navigation bar
//        let toolBarFrame = CGRect(origin: CGPoint(x: 0, y: 0) , size: CGSize(width: 50, height: 50))
//        let toolbar = UIToolbar.init(frame: toolBarFrame)
//        toolbar.barTintColor = UIColor.white
//        toolbar.isTranslucent = true
//        let flex: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
//        toolbar.items = [flex, trackingButton, flex]
//
//        // Need to implement this rounded view in order to get the box to look consistent with MKUserTrackingButton API. Origin is set by frame size - button size - margin
//        let origin = CGPoint(x: self.view.frame.size.width - 85, y: 60)
//        let roundedSquare: UIView = UIView(frame: CGRect(origin: origin, size: CGSize(width: 50, height: 50)))
//        roundedSquare.backgroundColor = UIColor.white
//        roundedSquare.layer.cornerRadius = 5
//        roundedSquare.layer.masksToBounds = true
//
//        roundedSquare.addSubview(toolbar)
//        mapView.addSubview(roundedSquare)
//    }
    
    func setupMapView() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.mapType = MKMapType.standard
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        
        // Colour of pulse and user icon
        mapView.tintColor = UIColor(red:0.00, green:0.71, blue:1.00, alpha:1.0)
    }
    
    func addAnnotation(latitude: Double, longitude: Double) {
        let pinLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.title = "Hi"
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
        
        manager.stopUpdatingLocation()
    }
    
    //Set images for annotation pins
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isEqual(mapView.userLocation) {
            return nil
        }
        
        // For better performance, always try to reuse existing annotations.
        let annotationIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        annotationView?.canShowCallout = false
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            //annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        let cpa = annotation as! CustomPointAnnotation
        annotationView!.image = UIImage(named: cpa.imageName)
        return annotationView
    }
    
    //Render Data from JSON
    func renderJSONMapData() {
        DispatchQueue.global(qos: .background).async { [weak self] () -> Void in
            let userLocationLatitude = self?.userLocation?.coordinate.latitude
            let userLocationLongitude = self?.userLocation?.coordinate.longitude
            
            MapAPI.getJSONMapData(latitude: userLocationLatitude!, longitude: userLocationLongitude!) { (results:[MapAPI]) in
                for result in results {
                    //Get the current location of annotation
                    let locationofHotspot = CLLocation(latitude: Double(result.latitude)!, longitude: Double(result.longitude)!)
                    
                    //Get the distance between the users current location and the location of the annotation
                    let distanceInMeters = self?.userLocation?.distance(from: locationofHotspot)
                    
                    //5 mile in meters = 8046.72
                    //1/2 mile in meters = 804.672
                    //1 mile in meters = 1609.34
                    //2 mile in meters = 3218.69
                    DispatchQueue.main.async { () -> Void in
                        if let distanceInMeters = distanceInMeters, distanceInMeters < 804.672{
                            self?.addAnnotation(latitude: Double(result.latitude)!, longitude: Double(result.longitude)!, type: result.type, id: result.id, name: result.name)
                            
                        }
                        
                    }
                    
                }
            }
            
        }
    }
    
    
    //Wait for map to load before calling renderJSONMapData()
    func waitForMapToLoadBeforeRenderingParsingData() {
        self.renderJSONMapData()
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
            //print(messageVC.groupId)
        }
    }
    
    @IBAction func startChatButton_TouchUpInside(_ sender: Any) {
        
        // UNCOMMENT AND DELETE BOTTOM SEGUE FOR CREATE CUSTOM GROUP
        
        //        getLocationDetails(location: self.userLocation!) {
        //            Api.group.createGroup(location: self.userLocationName!, longitude: self.userLongitude!, latitude: self.userLatitude!, onSuccess: { (groupId) in
        //                // Update and increment user count then show messageViewController
        //                Api.group.addUserToGroup(groupId: self.groupId) {
        //                    self.performSegue(withIdentifier: "messageVCSegue", sender: nil)
        //                }
        //            }) { (error) in
        //                print(error!)
        //            }
        //        }
        
        self.performSegue(withIdentifier: "messageVCSegue", sender: nil)
        
    }
    
}

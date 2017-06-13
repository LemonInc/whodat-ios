//
//  LoginViewController.swift
//  WhoDat
//
//  Created by Alan Lau on 01/05/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

import GoogleMaps
import MapKit
import CoreLocation

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var startChatButton: UIButton!
    
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
    
    @IBAction func startChatButton_TouchUpInside(_ sender: Any) {
        
        print("pressed")
        
        // Show progress indicator
        SVProgressHUD.show(withStatus: "Loading...")
        
        // Update and increment user count by adding to database
        let groupId = "Group 1"
        
        Api.group.addUserToGroup(groupId: groupId, onSuccess: {
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: "messageVCSegue", sender: nil)
        }, onError: { (error) in
            // Show progress indicator error
            SVProgressHUD.showError(withStatus: error!)
        })
        
    }
    
}

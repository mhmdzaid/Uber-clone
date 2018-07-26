//
//  riderVC.swift
//  Uber
//
//  Created by mohamed zead on 7/23/18.
//  Copyright © 2018 zead. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth
class riderVC: UIViewController,CLLocationManagerDelegate{

    @IBOutlet weak var callUberButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    
    @IBAction func LogoutPressed(_ sender: Any) {
        do{
            try Auth.auth().signOut()
        }catch{
            print("error loging out ")
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func callUberPressed(_ sender: Any) {
        let email = (Auth.auth().currentUser?.email)!
        if UberHasBeenCalled{
            
            UberHasBeenCalled = false
            callUberButton.setTitle("Call Uber", for: .normal)
            Database.database().reference().child("RiderRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapShot) in
                snapShot.ref.removeValue()
                Database.database().reference().child("RiderRequests").removeAllObservers()
            })
           

        }else{
            
            let requestData = ["email":email,
                               "lat":Coordinates.latitude,
                               "lon":Coordinates.longitude] as [String : Any]
            
            Database.database().reference().child("RiderRequests").childByAutoId().setValue(requestData)
            UberHasBeenCalled = true
            callUberButton.setTitle("Cancel Uber", for: .normal)
            
        }
        
            }
    
    var UberHasBeenCalled = false
    var LocationManager = CLLocationManager()
    var Coordinates = CLLocationCoordinate2D()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMap()
        checkUberIsCalled()
    }

    
    
    func setUpMap(){
       
        LocationManager.delegate = self
        LocationManager.desiredAccuracy = kCLLocationAccuracyBest
        LocationManager.requestWhenInUseAuthorization()
        LocationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let  coord = manager.location?.coordinate{
            let locationCoordinate = CLLocationCoordinate2DMake(coord.latitude, coord.longitude)
            Coordinates = locationCoordinate
        let region = MKCoordinateRegionMake(locationCoordinate, MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
        map.removeAnnotations(map.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        annotation.title = "your Location"
        map.addAnnotation(annotation)
        map.showAnnotations(map.annotations, animated: true)
        }
    }
    
    func checkUberIsCalled(){
        if let email = Auth.auth().currentUser?.email{
            Database.database().reference().child("RiderRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapShot) in
                self.callUberButton.setTitle("Cancel Uber", for: .normal)
                self.UberHasBeenCalled = true
            })
        }
    }
}

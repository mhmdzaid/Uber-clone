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

    var driverOnTheWay = false
    var DriverLocation = CLLocationCoordinate2D()
    var UberHasBeenCalled = false
    var LocationManager = CLLocationManager()
    var UserLocation = CLLocationCoordinate2D()
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
        if !driverOnTheWay{
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
                               "lat":UserLocation.latitude,
                               "lon":UserLocation.longitude] as [String : Any]
            Database.database().reference().child("RiderRequests").childByAutoId().setValue(requestData)
            UberHasBeenCalled = true
            callUberButton.setTitle("Cancel Uber", for: .normal)
         }
        }
    }
   
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
            UserLocation = locationCoordinate
            if UberHasBeenCalled{
                displayRiderNDriver()
            }else{
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
    }
    
    func checkUberIsCalled(){
        if let email = Auth.auth().currentUser?.email{
            Database.database().reference().child("RiderRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapShot) in
                self.callUberButton.setTitle("Cancel Uber", for: .normal)
                self.UberHasBeenCalled = true
                Database.database().reference().child("RiderRequests").removeAllObservers()
                if let riderDataDict = snapShot.value as? [String:AnyObject]{
                    if let lat = riderDataDict["driver's Latitude "] as? Double{
                        if let lon = riderDataDict["driver's longitude"] as? Double{
                          self.DriverLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                          self.driverOnTheWay = true
                          self.displayRiderNDriver()
                            if let email = Auth.auth().currentUser?.email{
                                Database.database().reference().child("RiderRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged, with: { (snapshot) in
                                    if let riderDataDict = snapShot.value as? [String:AnyObject]{
                                        if let lat = riderDataDict["driver's Latitude "] as? Double{
                                            if let lon = riderDataDict["driver's longitude"] as? Double{
                                                self.DriverLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                                self.driverOnTheWay = true
                                                self.displayRiderNDriver()
                                            }
                                        }
                                    }
                                })
                            }
                        }
                    }
                    
                }
            })
        }
    }
    
    
    func displayRiderNDriver(){
        let driverCLLocation = CLLocation(latitude: DriverLocation.latitude, longitude: DriverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: UserLocation.latitude, longitude: UserLocation.longitude)
        let distance = driverCLLocation.distance(from: riderCLLocation)/1000
        let roundedDistance = round(distance*100)/100
        callUberButton.setTitle("Your driver is \(roundedDistance)kms away ", for: .normal)
        map.removeAnnotations(map.annotations)
        let latDelta = abs(DriverLocation.latitude - UserLocation.latitude) * 2 + 0.005
        let lonDelta = abs(DriverLocation.longitude - UserLocation.longitude) * 2 + 0.005
        let region = MKCoordinateRegion(center: UserLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        map.setRegion(region, animated: true)
        let riderAnno = MKPointAnnotation()
        riderAnno.coordinate = UserLocation
        riderAnno.title = "Your Location"
        map.addAnnotation(riderAnno)
        let driverAnno = MKPointAnnotation()
        driverAnno.coordinate = DriverLocation
        driverAnno.title = "Your Driver"
        map.addAnnotation(driverAnno)
        map.showAnnotations(map.annotations, animated: true)
    }
}

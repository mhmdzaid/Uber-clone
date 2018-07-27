//
//  AcceptRequestVC.swift
//  Uber
//
//  Created by mohamed zead on 7/27/18.
//  Copyright © 2018 zead. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
class AcceptRequestVC: UIViewController {
    var requestLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    var requestEmail = ""
    @IBOutlet weak var map: MKMapView!
    @IBAction func acceptRequestPressed(_ sender: Any) {
        //update the rider request with coming driver location
        Database.database().reference().child("RiderRequests").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) { (snapShot) in
            snapShot.ref.updateChildValues(["driver's Latitude ":self.driverLocation.latitude,
                                            "driver's longitude":self.driverLocation.longitude])
        }
        Database.database().reference().child("RiderRequests").removeAllObservers()
        
        // give the directions
        let requestCllocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        CLGeocoder().reverseGeocodeLocation(requestCllocation) { (placemarks, error) in
            if let placemarks = placemarks{
                if placemarks.count > 0{
                    let placemark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = self.requestEmail
                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMap()
       
    }
    
    
    

    func setUpMap(){
      let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
      map.setRegion(region, animated: true)
      let annotation = MKPointAnnotation()
      annotation.title = requestEmail
      annotation.coordinate = requestLocation
      map.addAnnotation(annotation)
      map.showAnnotations(map.annotations, animated: true)
    }

}

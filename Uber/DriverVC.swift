//
//  DriverVC.swift
//  Uber
//
//  Created by mohamed zead on 7/27/18.
//  Copyright © 2018 zead. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import MapKit
class DriverVC: UIViewController {
    let LocationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    var Requests : [DataSnapshot] = []
    @IBOutlet weak var tableView: UITableView!
    @IBAction func logoutPressed(_ sender: Any) {
        do{
            try Auth.auth().signOut()
        }catch{
            print("error loging out ")
        }
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        LocationManager.delegate = self
        LocationManager.requestWhenInUseAuthorization()
        LocationManager.startUpdatingLocation()
        LocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

}



extension DriverVC : UITableViewDataSource,UITableViewDelegate , CLLocationManagerDelegate{
    
    override func viewWillAppear(_ animated: Bool) {
        Database.database().reference().child("RiderRequests").observe(.childAdded) { (snapshot) in
            
            self.Requests.append(snapshot)
            self.tableView.reloadData()
             
        }
        print("number of riders \(self.Requests.count)")
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "riderRequestCell", for: indexPath)
         let snapShot = Requests[indexPath.row]
        if let riderDataDict = snapShot.value as? [String:AnyObject]{
            if let email = riderDataDict["email"] as? String{
                if let lat = riderDataDict["lat"] as? Double{
                    if let lon = riderDataDict["lon"] as? Double{
                     let riderCLLocation = CLLocation(latitude: lat, longitude: lon)
                     let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                     let distance = driverCLLocation.distance(from: riderCLLocation)/1000
                     let roundedDistance = round(distance*100)/100
                     cell.textLabel?.text = "\(email) - \(roundedDistance) kms away "
                    }
                }
            }
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Requests.count
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate{
            self.driverLocation = coord
        }
    }

    
   
        
    
}

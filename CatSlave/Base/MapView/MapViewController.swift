//
//  MapViewController.swift
//  CatSlave
//
//  Created by crow on 9/10/17.
//  Copyright © 2017 crow. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var historyButton: UIBarButtonItem!
    
    var firebaseRef: DatabaseReference?
    var locationManager = CLLocationManager()
    var positionList = [Position]()
    var catCurrentPosition: Position?
    var catOutOfRange = false
    var userLocation: CLLocation?
    var geodesic: MKGeodesicPolyline?
    var currentUserID: String?
    var handle: AuthStateDidChangeListenerHandle?
    
    //geofencing
    var geofencingSwitch: Bool?
    var distanceForNotification: Double?
    var distanceMode: String?
    var homeCoordinate: CLLocation?
    var address: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //verify user if not log in
        if (Auth.auth().currentUser) == nil
        {
            //login
            let vc = storyboard?.instantiateViewController(withIdentifier: "LoginController")
            self.present(vc!, animated: true, completion: nil)
        }else{
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
            mapView.delegate = self
            
            //set up current user id
            currentUserID = Auth.auth().currentUser!.uid
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.currentUserID = currentUserID
            
            firebaseRef = Database.database().reference(withPath: "\(currentUserID!)/data")
            _ = firebaseRef!.observe(DataEventType.value, with: { (snapshot) in
                self.positionList.removeAll()
                let dictionary = snapshot.value as! [String: AnyObject]
                let positionDataList = dictionary["position"] as! [String: AnyObject]
                
//                positionDataList.sorted(by: <#T##((key: String, value: AnyObject), (key: String, value: AnyObject)) throws -> Bool#>)
                
                for (positionData) in positionDataList{
                    let value = positionData.value as! [String: AnyObject]
                    self.parseAndAppendCatPosition(positionData: value)
                }
                
                self.catCurrentPosition = self.positionList.last!
                self.showCatCurrentPosition(position: self.catCurrentPosition!)
                
                self.geofencingSwitch = dictionary["geofencingSwitch"] as? Bool
                self.distanceForNotification = dictionary["distanceForNotification"] as? Double
                self.distanceMode = dictionary["trackDistanceMode"] as? String
            
                if self.distanceMode == "home"{
                    let homePosition = dictionary["home"] as! [String: AnyObject]
                    self.homeCoordinate = CLLocation(latitude: homePosition["latitude"] as! Double, longitude: homePosition["longitude"] as! Double)
                    self.address = homePosition["address"] as? String
                    self.showHomeAnnotation()
                }
            
                if self.geofencingSwitch!{
                    if self.distanceMode == "home"{
                        //track distance to home
                        let distanceInMeters = self.catCurrentPosition?.coordinate!.distance(from: self.homeCoordinate!)
                        if distanceInMeters! >= self.distanceForNotification! && !self.catOutOfRange{
                            self.showAlertMessage(message: "Cat run too far from home!")
                        }else if distanceInMeters! < self.distanceForNotification! && self.catOutOfRange{
                            self.catOutOfRange = false
                        }
                    }else{
                        //track distance to me
                        if self.userLocation != nil{
                            let distanceInMeters = self.catCurrentPosition?.coordinate!.distance(from: self.userLocation!)
                            if distanceInMeters! >= self.distanceForNotification! && !self.catOutOfRange{
                                self.catOutOfRange = true
                                self.showAlertMessage(message: "Cat run too far from you!")
                            }else if distanceInMeters! < self.distanceForNotification! && self.catOutOfRange{
                                self.catOutOfRange = false
                            }
                        }
                    }
                }
            })
        }
    }
    // parse and append cat position from firebase
    func parseAndAppendCatPosition(positionData: [String: AnyObject]){
        let catCurrentPosition = Position()
        
        let timeStampString = positionData["timeStamp"] as? String
        
        //transfer date string to Date
        catCurrentPosition.timeStamp = Utility.formateStringToDate(dateString: timeStampString!, dateFormat: "YYYY-MM-DD hh:mm:ss", timeZoneStringAbbreviation: "GMT+0:00")
        
        let latitude = positionData["latitude"] as? Double
        let longitude = positionData["longitude"] as? Double
        catCurrentPosition.coordinate = CLLocation(latitude: latitude!, longitude: longitude!)
        self.positionList.append(catCurrentPosition)
    }
    
    //display home annotation with a home icon on map
    func showHomeAnnotation(){
        let annotation = CatAnnotation(newCoordinate: (homeCoordinate?.coordinate)!, newTItle: "My Home", newSubtitle: "Geofencing from home enabled", newImage: UIImage(named: "icons8-home-filled")!)
        
        self.mapView.addAnnotation(annotation)
    }
    
    //show cat current position with a cat icon on map
    func showCatCurrentPosition(position: Position){
        let allAnnotation = self.mapView.annotations
        mapView.removeAnnotations(allAnnotation)
        
        let coordinate = position.coordinate!.coordinate
        let dateString = Utility.formatDateToString(date: position.timeStamp!, dateFormat: "MM-dd, HH:mm:ss")
        let annotation = CatAnnotation(newCoordinate: coordinate, newTItle: "Meow!", newSubtitle: dateString, newImage: UIImage(named: "icons8-Black Cat Filled-64")!)
        
        self.mapView.addAnnotation(annotation)
    }
    
    // view for annotation(change default marker to a icon)
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let reuseId = "restaurantAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        annotationView?.annotation = annotation

        annotationView?.canShowCallout = true

//        let button = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 30, height: 30)))
//        button.setBackgroundImage(UIImage(named: "direction"), for: .normal)
//        button.addTarget(self, action: #selector(showDirection), for: .touchUpInside)
//        annotationView?.detailCalloutAccessoryView .leftCalloutAccessoryView = button

        // logo image
        var logoImage = UIImage(named: "icons8-Black Cat Filled-64")
        if annotation.title! == "My Home"{
            logoImage = UIImage(named: "icons8-home-filled")
        }
        let sizeChange = CGSize(width: 32,height: 32)
        UIGraphicsBeginImageContextWithOptions(sizeChange, false, 0.0)
        logoImage?.draw(in: CGRect(origin: (annotationView?.frame.origin)!, size: sizeChange))
        logoImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        annotationView?.image = logoImage

        return annotationView
    }
    
    // did updated location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            userLocation = locations.first
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: userLocation!.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    //location manager authorization
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    // map failed
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: (error)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //show cat location button clicked, zoom map
    @IBAction func showCatLocation(_ sender: Any) {
        showCatCurrentPosition(position: catCurrentPosition!)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let coordinate = catCurrentPosition?.coordinate!.coordinate
        let region = MKCoordinateRegion(center: coordinate!, span: span)
        mapView.setRegion(region, animated: true)
        if homeCoordinate != nil && distanceMode == "home"{
            showHomeAnnotation()
        }
        mapView.setCenter((catCurrentPosition?.coordinate?.coordinate)!, animated: true)
    }
    
    //history button clicked, show cat history route with polyline on map
    @IBAction func historyButtonClick(_ sender: Any) {
        if historyButton?.title == "History"{
            var points = [CLLocationCoordinate2D]()
            for position in positionList{
                points.append((position.coordinate?.coordinate)!)
            }
            
            //draw a line to connect these points
            createPolyline(mapView: mapView, points: points)
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            historyButton?.title = "Clear History"
        }
        else{
            mapView.remove(geodesic!)
            showCatLocation(sender: (Any).self)
            if homeCoordinate != nil && distanceMode == "home"{
                showHomeAnnotation()
            }
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            historyButton?.title = "History"
        }
    }
    
    //create a poly line using the positions given
    func createPolyline(mapView: MKMapView, points: [CLLocationCoordinate2D]) {
        
        geodesic = MKGeodesicPolyline(coordinates: points, count: points.count)
        mapView.add(geodesic!)
        
        UIView.animate(withDuration: 1.5, animations: { () -> Void in
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: points.last!, span: span)
            mapView.setRegion(region, animated: true)
        })
    }
    
    //map overlay for polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    //my location button clicked
    @IBAction func myLocation(_ sender: Any) {
        self.mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
    }
    
    //prepare for geofencing settings view segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapToGeofencingSegue"{
            let destinationVC = segue.destination as! GeofencingSettingViewController
            destinationVC.switchIsOn = self.geofencingSwitch!
            destinationVC.distance = self.distanceForNotification!
            destinationVC.distanceMode = self.distanceMode!
            if self.distanceMode == "home"{
                destinationVC.homeCoordinate = self.homeCoordinate!
                destinationVC.address = self.address!
            }
        }
    }
}

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
    var userLocation: CLLocation?
    var geodesic: MKGeodesicPolyline?
    
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
            
            firebaseRef = Database.database().reference(withPath: "UXzbRyL7p4gj1yf4nY1lHZRhc9l2/data")
            _ = firebaseRef!.observe(DataEventType.value, with: { (snapshot) in
                self.positionList.removeAll()
                let dictionary = snapshot.value as! [String: AnyObject]
            
                let catCurrentPosition = Position()
            
                let positionData = dictionary["position"] as! [String: AnyObject]
                let timeStampString = positionData["timeStamp"] as? String
            
                //transfer date string to Date
                catCurrentPosition.timeStamp = Utility.formateStringToDate(dateString: timeStampString!, dateFormat: "YYYY-MM-DD hh:mm:ss", timeZoneStringAbbreviation: "GMT+0:00")
            
                let latitude = positionData["latitude"] as? Double
                let longitude = positionData["longitude"] as? Double
                catCurrentPosition.coordinate = CLLocation(latitude: latitude!, longitude: longitude!)
                
                self.positionList.append(catCurrentPosition)
                self.catCurrentPosition = catCurrentPosition
                self.showCatCurrentPosition(position: catCurrentPosition)
                
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
                        let distanceInMeters = catCurrentPosition.coordinate!.distance(from: self.homeCoordinate!)
                        if distanceInMeters >= self.distanceForNotification!{
                            self.showAlertMessage(message: "Cat run too far from home!")
                        }
                    }else{
                        //track distance to me
                        if self.userLocation != nil{
                            let distanceInMeters = catCurrentPosition.coordinate!.distance(from: self.userLocation!)
                            if distanceInMeters >= self.distanceForNotification!{
                                self.showAlertMessage(message: "Cat run too far from you!")
                            }
                        }
                    }
                }
            })
        }
    }
    
    func showHomeAnnotation(){
        let annotation = CatAnnotation(newCoordinate: (homeCoordinate?.coordinate)!, newTItle: "My Home", newSubtitle: "Geofencing from home enabled", newImage: UIImage(named: "icons8-home-filled")!)
        
        self.mapView.addAnnotation(annotation)
    }
    
    func showCatCurrentPosition(position: Position){
        let allAnnotation = self.mapView.annotations
        mapView.removeAnnotations(allAnnotation)
        
        let coordinate = position.coordinate!.coordinate
        let dateString = Utility.formatDateToString(date: position.timeStamp!, dateFormat: "YYYY-MM-DD, hh:mm:ss")
        let annotation = CatAnnotation(newCoordinate: coordinate, newTItle: "Meow!", newSubtitle: dateString, newImage: UIImage(named: "icons8-Black Cat Filled-64")!)
        
        self.mapView.addAnnotation(annotation)
    }
    
    // view for annotation
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
    
    @IBAction func showCatLocation(_ sender: Any) {
        showCatCurrentPosition(position: catCurrentPosition!)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let coordinate = catCurrentPosition?.coordinate!.coordinate
        let region = MKCoordinateRegion(center: coordinate!, span: span)
        mapView.setRegion(region, animated: true)
        
        mapView.setCenter((catCurrentPosition?.coordinate?.coordinate)!, animated: true)
    }
    
    @IBAction func historyButtonClick(_ sender: Any) {
        if historyButton?.title == "History"{
            let point1 = CLLocationCoordinate2DMake(-37.8840, 145.0266);
            let point2 = CLLocationCoordinate2DMake(-37.910, 145.134);
            let point3 = CLLocationCoordinate2DMake(-37.8108, 144.9631);
            
            let points: [CLLocationCoordinate2D]
            points = [point1, point2, point3]
            
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
    
    func createPolyline(mapView: MKMapView, points: [CLLocationCoordinate2D]) {
        
        geodesic = MKGeodesicPolyline(coordinates: points, count: points.count)
        mapView.add(geodesic!)
        
        UIView.animate(withDuration: 1.5, animations: { () -> Void in
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region1 = MKCoordinateRegion(center: points[0], span: span)
            mapView.setRegion(region1, animated: true)
        })
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    @IBAction func myLocation(_ sender: Any) {
        self.mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
    }
    
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

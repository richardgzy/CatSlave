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
    var firebaseObserverID: UInt?
    var locationManager = CLLocationManager()
    var positionList = [Position]()
    var catCurrentPosition: Position?
    var geodesic: MKGeodesicPolyline?
    
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
            firebaseObserverID = firebaseRef!.observe(DataEventType.value, with: { (snapshot) in
                    self.positionList.removeAll()
                    let dictionary = snapshot.value as! [String: AnyObject]
                
                    let catCurrentPosition = Position()
                
                    let positionData = dictionary["position"] as! [String: AnyObject]
                    let timeStampString = positionData["timeStamp"] as? String
                
                    //transfer date string to Date
                    catCurrentPosition.timeStamp = Utility.formateStringToDate(dateString: timeStampString!, dateFormat: "YYYY-MM-DD hh:mm:ss", timeZoneStringAbbreviation: "GMT+0:00")
                    catCurrentPosition.latitude = positionData["latitude"] as? Double
                    catCurrentPosition.longitude = positionData["longitude"] as? Double
                
                    self.positionList.append(catCurrentPosition)
                    self.catCurrentPosition = catCurrentPosition
                    self.showCatCurrentPosition(position: catCurrentPosition)
            })
        }
    }
    
    func showCatCurrentPosition(position: Position){
        let allAnnotation = self.mapView.annotations
        mapView.removeAnnotations(allAnnotation)
        
        let coordinate = CLLocationCoordinate2D(latitude: position.latitude!, longitude: position.longitude!)
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
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
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
        let coordinate = CLLocationCoordinate2DMake(catCurrentPosition!.latitude!, catCurrentPosition!.longitude!)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        mapView.setCenter(CLLocationCoordinate2DMake((catCurrentPosition?.latitude)!, (catCurrentPosition?.longitude)!), animated: true)
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
}

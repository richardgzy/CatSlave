//
//  GeofencingSettingViewController.swift
//  CatSlave
//
//  Created by Richard on 30/10/17.
//  Copyright © 2017 crow. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class GeofencingSettingViewController: UIViewController {
    @IBOutlet weak var geofencingSwitch: UISwitch!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var distanceModeSegmentControl: UISegmentedControl!
    @IBOutlet weak var addresstf: MyTextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var setAddressButton: MyButton!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var firebasePostRef: DatabaseReference?
    var homeCoordinate: CLLocation?
    var switchIsOn: Bool?
    var distance: Double?
    var distanceMode: String?
    var address: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        geofencingSwitch.tintColor = UIColor(hexString: CONST.MAIN_RED)
        distanceSlider.tintColor = UIColor(hexString: CONST.MAIN_RED)
        distanceModeSegmentControl.tintColor = UIColor(hexString: CONST.MAIN_RED)
        
        addresstf.maxLength = 200
        addresstf.tfName = "Home Address"
        addresstf.vc = self
        
        distanceModeSegmentControl(Any.self)
        distanceSlider(Any.self)
        
        firebasePostRef = Database.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        geofencingSwitch.isOn = switchIsOn!
        distanceSlider.value = Float(distance!)
        distanceLabel.text = "\(String(format: "%.2f", distanceSlider.value))m"
        if distanceMode == "me"{
            distanceModeSegmentControl.selectedSegmentIndex = 0
        }else{
            distanceModeSegmentControl.selectedSegmentIndex = 1
            addresstf.text = address!
        }
        distanceModeSegmentControl(Any.self)
    }
    
    @IBAction func setHomeAddress(_ sender: Any) {
        let address = addresstf.text!
        
        if address.trimmingCharacters(in: CharacterSet(charactersIn: " ")) == ""{
            self.showFailMessage(view: self.view, message: "Home address can not be empty!")
            return
        }
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    self.showFailMessage(view: self.view, message: "Not able to find this location, please change and try again")
                    return
            }
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            self.homeCoordinate = CLLocation(latitude: latitude, longitude: longitude)
            self.showSucceedMessage(view: self.view, message: "Home Address Recognized Successfully")
        }
    }
    
    @IBAction func distanceModeSegmentControl(_ sender: Any) {
        if distanceModeSegmentControl.selectedSegmentIndex == 0{
            addressLabel.isHidden = true
            addresstf.isHidden = true
            setAddressButton.isHidden = true
        }else{
            addressLabel.isHidden = false
            addresstf.isHidden = false
            setAddressButton.isHidden = false
        }
    }
    
    @IBAction func distanceSlider(_ sender: Any) {
        let distance = distanceSlider.value
        distanceLabel.text = String(format: "%.2f", distance)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveAllChanges(_ sender: Any) {
        firebasePostRef!.child("UXzbRyL7p4gj1yf4nY1lHZRhc9l2/data/geofencingSwitch").setValue(geofencingSwitch.isOn)
        
        firebasePostRef!.child("UXzbRyL7p4gj1yf4nY1lHZRhc9l2/data/distanceForNotification").setValue(distanceSlider.value)
        
        if distanceModeSegmentControl.selectedSegmentIndex == 0 {
            firebasePostRef!.child("UXzbRyL7p4gj1yf4nY1lHZRhc9l2/data/trackDistanceMode").setValue("me")
        }else{
            firebasePostRef!.child("UXzbRyL7p4gj1yf4nY1lHZRhc9l2/data/trackDistanceMode").setValue("home")
            
            if homeCoordinate == nil{
                self.showFailMessage(view: self.view, message: "Please enter a valid home address and continue")
                return
            }
            
            firebasePostRef!.child("UXzbRyL7p4gj1yf4nY1lHZRhc9l2/data/home/latitude").setValue(homeCoordinate?.coordinate.latitude)
            firebasePostRef!.child("UXzbRyL7p4gj1yf4nY1lHZRhc9l2/data/home/longitude").setValue(homeCoordinate?.coordinate.longitude)
            firebasePostRef!.child("UXzbRyL7p4gj1yf4nY1lHZRhc9l2/data/home/address").setValue(addresstf.text!)
        }
        
        self.showSucceedMessage(view: self.view, message: "All geofencing settings saved successfully")
        _ = navigationController?.popViewController(animated: true)
    }
}

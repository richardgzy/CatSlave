//
//  MyCatViewController.swift
//  CatSlave
//
//  Created by Richard on 21/10/17.
//  Copyright © 2017 crow. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

protocol LogOffDelegate {
    func logOff()
}
class MyCatViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var catNameLabel: UILabel!
    @IBOutlet weak var catAgeLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var pictureModeSwitch: UISwitch!
    @IBOutlet weak var intervalSegmentControl: UISegmentedControl!
    @IBOutlet weak var humidityLabel: UILabel!
    
    var delegate : LogOffDelegate? = nil
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var firebaseRef: DatabaseReference?
    var firebaseObserverID: UInt?
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebaseRef = Database.database().reference(withPath: "UXzbRyL7p4gj1yf4nY1lHZRhc9l2/data")
        firebaseObserverID = firebaseRef!.observe(DataEventType.value, with: { (snapshot) in
                let dictionary = snapshot.value as! [String: AnyObject]
                
                let catName = dictionary["catName"] as! String
                let catAge = dictionary["catAge"] as! Int
                
                self.catNameLabel.text = catName
                self.catAgeLabel.text = String(catAge)
                
                let profile = dictionary["profile"] as! String
                
                // Create a storage reference from the URL
                let storageRef = Storage.storage().reference(forURL: profile)
                // Download the data, assuming a max size of 1MB (you can change this as necessary)
                storageRef.getData(maxSize: 1 * 150 * 150) { (data, error) -> Void in
                    let pic = UIImage(data: data!)
                    self.profileImageView.image = pic!
                }
                
                let moisture = dictionary["moisture"] as! [String: AnyObject]
                let moistureValue = moisture["moistureValue"] as! Int
                self.humidityLabel.text = String(moistureValue)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        pictureModeSwitch.tintColor = UIColor(hexString: CONST.MAIN_RED)
        intervalSegmentControl.tintColor = UIColor(hexString: CONST.MAIN_RED)
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
//                let uid = user.uid
//                let email = user.email
//                let photoURL = user.photoURL as! String
//                // show user information
//                print("\(uid as! String) , \(email as! String) , \(photoURL as! String)")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @IBAction func pictureModeSwitch(_ sender: Any) {
        if pictureModeSwitch.isOn{
            appDelegate.cameraTakingModeIsPhoto = true
            self.showSucceedMessage(view: self.view, message: "Camera mode now switched to: photo")
        }else{
            appDelegate.cameraTakingModeIsPhoto = false
            self.showSucceedMessage(view: self.view, message: "Camera mode now switched to: video")
        }
    }
    
    @IBAction func intervalSegmentControl(_ sender: Any) {
        switch intervalSegmentControl.selectedSegmentIndex{
        case 0:
            appDelegate.cameraTakingInterval = 30.0
            break
        case 1:
            appDelegate.cameraTakingInterval = 45.0
            break
        case 2:
            appDelegate.cameraTakingInterval = 60.0
            break
        case 3:
            appDelegate.cameraTakingInterval = 30.0
            break
        case 4:
            appDelegate.cameraTakingInterval = 30.0
            break
        default:
            appDelegate.cameraTakingInterval = 30.0
            break
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        // log off
        if ((Auth.auth().currentUser) != nil){
            do {
                try Auth.auth().signOut()
                delegate?.logOff()
                
                self.navigationController?.popViewController(animated: false)
                self.showSucceedMessage(view: self.view, message: "Log off succeeded")
            } catch {
                self.showFailMessage(view: self.view, message: "Log off Failed!")
            }
        }else{
            self.showAlertMessage(message: "You are already logged off")
        }
    }
}

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
    
    var delegate : LogOffDelegate?
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var firebaseRef: DatabaseReference?
    var firebaseUpdateRef: DatabaseReference?
    var currentUserId: String?
//    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUserId = appDelegate.currentUserID!
        firebaseUpdateRef = Database.database().reference()
        firebaseRef = Database.database().reference(withPath: "\(currentUserId!)")
        _ = firebaseRef!.observe(DataEventType.value, with: { (snapshot) in
            let dictionary = snapshot.value as! [String: AnyObject]
            let data = dictionary["data"] as! [String: AnyObject]
            let sensorControlData = dictionary["sensorControl"] as! [String: AnyObject]
            
            let catName = data["catName"] as! String
            let catAge = data["catAge"] as! Int
            
            self.catNameLabel.text = catName
            self.catAgeLabel.text = String(catAge)
            
            let profile = data["profile"] as! String
            
//                let storageRef = Storage.storage().reference(forURL: profile)
                // Download the data, a max size of 1MB
//                storageRef.getData(maxSize: 1 * 150 * 150) { (data, error) -> Void in
//                    guard error == nil else {
//                        self.showFailMessage(view: self.view, message: "Error occured when loading profile image")
//                        return
//                    }
//                    let pic = UIImage(data: data!)
//                    self.profileImageView.image = pic!
//                }
            if let image_url = URL(string: profile){
                do{
                    let data = try Data(contentsOf: image_url)
                    self.profileImageView.image = UIImage(data: data)
                }catch let err{
                    self.showFailMessage(view: self.view, message: "Error happened when loading image: \(err)")
                }
            }
            
            let interval = sensorControlData["takingIntervalInSeconds"] as! Int
            switch interval{
            case 30:
                self.intervalSegmentControl.selectedSegmentIndex = 0
                break
            case 45:
                self.intervalSegmentControl.selectedSegmentIndex = 1
                break
            case 60:
                self.intervalSegmentControl.selectedSegmentIndex = 2
                break
            case 300:
                self.intervalSegmentControl.selectedSegmentIndex = 3
                break
            case 600:
                self.intervalSegmentControl.selectedSegmentIndex = 4
                break
            default:
                self.intervalSegmentControl.selectedSegmentIndex = 0
                break
            }
        
            let moisture = data["moisture"] as! [String: AnyObject]
            let moistureValue = moisture["moistureValue"] as! Float
            // litter need to be changed when humidity is greater than 700
            if moistureValue >= 700.00{
                self.humidityLabel.text = "Humidity: \(String(moistureValue)) (Need to scoop litter!)"
                self.showAlertMessage(message: "Cat litter need to be changed!")
            }else{
                self.humidityLabel.text = "Humidity: \(String(moistureValue)) (Normal)"
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        pictureModeSwitch.tintColor = UIColor(hexString: CONST.MAIN_RED)
        intervalSegmentControl.tintColor = UIColor(hexString: CONST.MAIN_RED)
        
//        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
//            if let user = user {
//                let uid = user.uid
//                let email = user.email
//                let photoURL = user.photoURL as! String
//                // show user information
//                print("\(uid as! String) , \(email as! String) , \(photoURL as! String)")
//            }
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        Auth.auth().removeStateDidChangeListener(handle!)
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
            appDelegate.cameraTakingInterval = 30
            break
        case 1:
            appDelegate.cameraTakingInterval = 45
            break
        case 2:
            appDelegate.cameraTakingInterval = 60
            break
        case 3:
            appDelegate.cameraTakingInterval = 300
            break
        case 4:
            appDelegate.cameraTakingInterval = 600
            break
        default:
            appDelegate.cameraTakingInterval = 30
            break
        }
        self.firebaseUpdateRef!.child("\(currentUserId!)/sensorControl/takingIntervalInSeconds").setValue(appDelegate.cameraTakingInterval)
    }
    
    @IBAction func logOut(_ sender: Any) {
        // log off
        if ((Auth.auth().currentUser) != nil){
            do {
                try Auth.auth().signOut()
                delegate?.logOff()
                
                self.showSucceedMessage(view: self.view, message: "Log off succeeded")
                
                //login page
                let vc = storyboard?.instantiateViewController(withIdentifier: "LoginController")
                self.present(vc!, animated: true, completion: nil)
            } catch {
                self.showFailMessage(view: self.view, message: "Log off Failed!")
            }
        }else{
            self.showAlertMessage(message: "You are already logged off")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myCatToEditCatSegue"{
            let vc = segue.destination as! EditCatViewController
            vc.catName = catNameLabel.text!
            vc.catAge = catAgeLabel.text!
            if profileImageView.image != nil{
                vc.profileImage = profileImageView.image!
            }
        }
    }
}

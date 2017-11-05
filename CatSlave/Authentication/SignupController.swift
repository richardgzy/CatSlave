//
//  SignupController.swift
//  CatSlave
//
//  Created by Richard on 16/10/17.
//  Copyright © 2017 crow. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Photos

class SignupController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate {
    @IBOutlet weak var emailtf: MyTextField!
    @IBOutlet weak var passwordtf: MyTextField!
    @IBOutlet weak var renterPasswordtf: MyTextField!
    @IBOutlet weak var catNametf: MyTextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var catAgePicker: UIPickerView!
    
    let pickerData: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"]
    var photoPicker = UIImagePickerController()
    var firebasePostRef: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init text field
        self.emailtf.maxLength = 40
        self.emailtf.tfName = "Email"
        self.emailtf.vc = self
        
        self.passwordtf.maxLength = 15
        self.passwordtf.tfName = "Password"
        self.passwordtf.vc = self
        
        self.renterPasswordtf.maxLength = 15
        self.renterPasswordtf.tfName = "ReenterPassword"
        self.renterPasswordtf.vc = self
        
        self.catNametf.maxLength = 15
        self.catNametf.tfName = "ReenterPassword"
        self.catNametf.vc = self
        
        self.catAgePicker.delegate = self
        self.catAgePicker.dataSource = self
        
        self.profileImageView.image = UIImage(named: "icons8-Cat Profile-64")
        
        firebasePostRef = Database.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //select profile image
    @IBAction func selectImageButton(_ sender: Any) {
        self.photoPicker.sourceType = .photoLibrary
        self.present(self.photoPicker, animated: true, completion: nil)
    }
    
    //try to sign up using firebase Auth with all information given
    @IBAction func signup(_ sender: Any) {
        let email = emailtf.text!
        let password = passwordtf.text!
        let rePassword = renterPasswordtf.text!
        let catName = catNametf.text!
        let catAge = Int(pickerData[catAgePicker.selectedRow(inComponent: 0)])
        let profileImage = profileImageView.image!
        
        // check blank input
        if (email == "" || password == "" || rePassword == "")
        {
            self.showFailMessage(view: self.view, message: "You have not input all the fields!")
            return
        }
        else if (password != rePassword)
        {
            // check password and re-enter password
            self.showFailMessage(view: self.view, message: "Passwords are not the same!")
            return
        }
        
        var newUid = ""
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            guard error == nil else{
                self.showFailMessage(view: self.view, message: "Error happened signing up user, user might already exists")
                return
            }
            newUid = (user?.uid)!
        
            //set up user information and defalut value
            let currentDateString = Utility.getCurrentDateTimeString()
            
            self.firebasePostRef?.child("\(newUid)/data").setValue(["catName": catName])
            self.firebasePostRef?.child("\(newUid)/data/catAge").setValue(catAge)
            self.firebasePostRef?.child("\(newUid)/data/distanceForNotification").setValue(100)
            self.firebasePostRef?.child("\(newUid)/data/geofencingSwitch").setValue(false)
            self.firebasePostRef?.child("\(newUid)/data/trackDistanceMode").setValue("me")
            
            //upload profile image
            let data = Utility.compressImageSize(image: profileImage)
            let profileRef = Storage.storage().reference().child("\(newUid).png")
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            _ = profileRef.putData(data, metadata: metadata) { (metadata, error) in
                guard error == nil else {
                    self.showFailMessage(view: self.view, message: "Error occured when uploading profile image")
                    return
                }
                let downloadURL = metadata!.downloadURL()?.absoluteString
                self.firebasePostRef?.child("\(newUid)/data/profile").setValue(downloadURL)
            }
            
            //moisture
            self.firebasePostRef?.child("\(newUid)/data/moisture/moistureValue").setValue(0)
            self.firebasePostRef?.child("\(newUid)/data/moisture/timeStamp").setValue(currentDateString)
            
            //home
            self.firebasePostRef?.child("\(newUid)/data/home/address").setValue("Monash University")
            self.firebasePostRef?.child("\(newUid)/data/home/address").setValue(-37.9107779)
            self.firebasePostRef?.child("\(newUid)/data/home/address").setValue(145.1338631)
            
            //position
            self.firebasePostRef?.child("\(newUid)/data/home/position").setValue("Monash University")
            
            //camera
            self.firebasePostRef?.child("\(newUid)/data/camera/imageShource").setValue("https://firebasestorage.googleapis.com/v0/b/fit5140-3ff79.appspot.com/o/tumblr_o6d6a4cA7g1qgn992o1_500.png?alt=media&token=efe88106-e0ca-41bf-98cc-4ab2f036a39b")
            self.firebasePostRef?.child("\(newUid)/data/camera/timeStamp").setValue(currentDateString)
            
            //video
            self.firebasePostRef?.child("\(newUid)/data/video/videoSource").setValue("https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
            self.firebasePostRef?.child("\(newUid)/data/video/timeStamp").setValue(currentDateString)
            
            //position
            self.firebasePostRef?.child("\(newUid)/data/position/\(currentDateString)/latitude").setValue(-37.9107779)
            self.firebasePostRef?.child("\(newUid)/data/position/\(currentDateString)/longitude").setValue(145.1338631)
            self.firebasePostRef?.child("\(newUid)/data/position/\(currentDateString)/timeStamp").setValue(currentDateString)
            
            //sensor control
            self.firebasePostRef?.child("\(newUid)/sensorControl/cameraMode").setValue(true)
            self.firebasePostRef?.child("\(newUid)/sensorControl/takingIntervalInSeconds").setValue(30000)
        }
        
    }
    
    //dismiss sign up view and go back to log in view
    @IBAction func cancel(_ sender: Any) {
//        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
        //login
        let vc = storyboard?.instantiateViewController(withIdentifier: "LoginController")
        self.present(vc!, animated: true, completion: nil)
    }
    
    //UIPickerView number of components
    func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }
    
    //UIPickerView row count
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //UIPcikerView titile for each row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
}

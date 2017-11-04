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
        }
        
        firebasePostRef!.child("\(newUid)").setValue(newUid)
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

//
//  EditCatViewController.swift
//  CatSlave
//
//  Created by Richard on 25/10/17.
//  Copyright © 2017 crow. All rights reserved.
//

import UIKit
import Firebase
import Photos

class EditCatViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate {

    @IBOutlet weak var catNameTf: MyTextField!
    @IBOutlet weak var catAgePicker: UIPickerView!
    let pickerData: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"]
    @IBOutlet weak var profileImageView: UIImageView!
    
    var photoPicker = UIImagePickerController()
    var firebaseUpdateRef: DatabaseReference?
    var firebaseRef: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.catNameTf.maxLength = 40
        self.catNameTf.tfName = "CatName"
        self.catNameTf.vc = self
        
        self.catAgePicker.delegate = self
        self.catAgePicker.dataSource = self
        
        firebaseUpdateRef = Database.database().reference()
        
        firebaseRef = Database.database().reference(withPath: "UXzbRyL7p4gj1yf4nY1lHZRhc9l2/data")
        _ = firebaseRef!.observe(DataEventType.value, with: { (snapshot) in
            let dictionary = snapshot.value as! [String: AnyObject]

            let catName = dictionary["catName"] as! String
            let catAge = dictionary["catAge"] as! Int

            self.catNameTf.text = catName
            self.catAgePicker.selectRow(catAge - 1, inComponent: 1, animated: true)

            let profile = dictionary["profile"] as! String

            // Create a storage reference from the URL
            let storageRef = Storage.storage().reference(forURL: profile)
            // Download the data, assuming a max size of 1MB (you can change this as necessary)
            storageRef.getData(maxSize: 1 * 150 * 150) { (data, error) -> Void in
                let pic = UIImage(data: data!)
                self.profileImageView.image = pic!
            }
        })
    }
    
    @IBAction func changeProfile(_ sender: Any) {
        self.photoPicker.sourceType = .photoLibrary
        self.present(self.photoPicker, animated: true, completion: nil)
    }
    
    // did finish picking photo
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        self.dismiss(animated: true, completion: nil)
//        let referenceUrl = info[UIImagePickerControllerPHAsset] as? URL
//        let assets = PHAsset.fet .fetchAssets(withALAssetURLs: [referenceUrl!], options: nil)
//        let asset = assets.firstObject
//        asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
//            let imageFile = contentEditingInput?.fullSizeImageURL
//            var imageData = NSData(contentsOf: imageFile!)
//            let image = UIImage(data: imageData! as Data)
//            imageData = self.compressImageSize(image: image!)
//            self.iconData = imageData! as Data
//            self.profileImageView.image = UIImage(data: imageData! as Data)
//        })
//    }
    
    @IBAction func saveButton(_ sender: Any) {
        let catName = catNameTf.text
        let catAge = Int(pickerData[catAgePicker.selectedRow(inComponent: 0)])
        
        if catName?.trimmingCharacters(in: CharacterSet.init(charactersIn: " ")) == "" {
            self.showFailMessage(view: self.view, message: "Cat name can not be empty")
            return
        }
        
        //update info
        self.firebaseUpdateRef!.child("UXzbRyL7p4gj1yf4nY1lHZRhc9l2/data/catName").setValue(catName)
        self.firebaseUpdateRef!.child("UXzbRyL7p4gj1yf4nY1lHZRhc9l2/data/catAge").setValue(catAge)
        
        //update profile
        
        
        self.showSucceedMessage(view: self.view, message: "Update information successfully")
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}

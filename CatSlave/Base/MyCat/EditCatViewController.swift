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

class EditCatViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var catNameTf: MyTextField!
    @IBOutlet weak var catAgePicker: UIPickerView!
    let pickerData: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"]
    @IBOutlet weak var profileImageView: UIImageView!
    
    var photoPicker = UIImagePickerController()
    var firebaseUpdateRef: DatabaseReference?
    var firebaseRef: DatabaseReference?
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentUserId: String?
    
    var catName: String?
    var catAge: String?
    var profileImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        catNameTf.maxLength = 40
        catNameTf.tfName = "CatName"
        catNameTf.vc = self
        
        catAgePicker.delegate = self
        catAgePicker.dataSource = self
        
        photoPicker.delegate = self
        
        firebaseUpdateRef = Database.database().reference()
        
        currentUserId = appDelegate.currentUserID!
        
//        firebaseRef = Database.database().reference(withPath: "UXzbRyL7p4gj1yf4nY1lHZRhc9l2/data")
//        _ = firebaseRef!.observe(DataEventType.value, with: { (snapshot) in
//            let dictionary = snapshot.value as! [String: AnyObject]
//
//            let catName = dictionary["catName"] as! String
//            let catAge = dictionary["catAge"] as! Int
//
//            let profile = dictionary["profile"] as! String
//
//            // Create a storage reference from the URL
//            let storageRef = Storage.storage().reference(forURL: profile)
//            // Download the data, assuming a max size of 1MB (you can change this as necessary)
//            storageRef.getData(maxSize: 1 * 150 * 150) { (data, error) -> Void in
//                let pic = UIImage(data: data!)
//                self.profileImageView.image = pic!
//            }
//        })
        
        catNameTf.text = catName!
        catAgePicker.selectRow(Int(catAge!)! - 1 , inComponent: 0, animated: true)
        profileImageView.image = profileImage!
    }
    
    @IBAction func changeProfile(_ sender: Any) {
        self.photoPicker.sourceType = .photoLibrary
        self.present(self.photoPicker, animated: true, completion: nil)
    }
    
    //when image picker cancelled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // did finish picking photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        self.dismiss(animated: true, completion: nil)
//        let referenceUrl = info[UIImagePickerControllerPHAsset] as? String
//        let assets = PHAsset.fetchAssets(withBurstIdentifier: referenceUrl!, options: nil)
//        let asset = assets.firstObject
//        asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
//            let imageFile = contentEditingInput?.fullSizeImageURL
//            let imageData = NSData(contentsOf: imageFile!)
//            let image = UIImage(data: imageData! as Data)
//            self.profileImageView.image = image
//        })
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    //save button clicked, save all changes made
    @IBAction func saveButton(_ sender: Any) {
        let catName = catNameTf.text
        let catAge = Int(pickerData[catAgePicker.selectedRow(inComponent: 0)])
        
        if catName?.trimmingCharacters(in: CharacterSet.init(charactersIn: " ")) == "" {
            self.showFailMessage(view: self.view, message: "Cat name can not be empty")
            return
        }
    
        
        //update info
        self.firebaseUpdateRef!.child("\(currentUserId!)/data/catName").setValue(catName)
        self.firebaseUpdateRef!.child("\(currentUserId!)/data/catAge").setValue(catAge)
        
        //update profile
        
        let data = compressImageSize(image: profileImageView.image!)
        let profileRef = Storage.storage().reference().child("\(currentUserId!).png")
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        _ = profileRef.putData(data, metadata: metadata) { (metadata, error) in
            guard error == nil else {
                self.showFailMessage(view: self.view, message: "Error occured when uploading profile image")
                return
            }
            let downloadURL = metadata!.downloadURL()?.absoluteString
            self.firebaseUpdateRef!.child("\(self.currentUserId!)/data/profile").setValue(downloadURL)
        }

        self.showSucceedMessage(view: self.view, message: "Update information successfully")
        _ = navigationController?.popViewController(animated: true)
    }
    
    // compress image
    func compressImageSize(image:UIImage) -> Data{
        let originalImgSize = (UIImagePNGRepresentation(image)! as Data?)?.count
        var zipImageData : Data? = nil
        if originalImgSize!>1500 {
            zipImageData = UIImageJPEGRepresentation(image,0.1)! as Data?
        }else if originalImgSize!>600 {
            zipImageData = UIImageJPEGRepresentation(image,0.2)! as Data?
        }else if originalImgSize!>400 {
            zipImageData = UIImageJPEGRepresentation(image,0.3)! as Data?
        }else if originalImgSize!>300 {
            zipImageData = UIImageJPEGRepresentation(image,0.4)! as Data?
        }else if originalImgSize!>200 {
            zipImageData = UIImageJPEGRepresentation(image,0.5)! as Data?
        }
        return zipImageData!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UIpickerview number of components
    func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }
    
    //UIPIckerview row count
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //UIPickerview initial row titles
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}

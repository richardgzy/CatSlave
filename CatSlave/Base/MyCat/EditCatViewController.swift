//
//  EditCatViewController.swift
//  CatSlave
//
//  Created by Richard on 25/10/17.
//  Copyright © 2017 crow. All rights reserved.
//

import UIKit
import Firebase

class EditCatViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var catNameTf: MyTextField!
    @IBOutlet weak var catAgePicker: UIPickerView!
    let pickerData: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"]
    
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.catNameTf.maxLength = 40
        self.catNameTf.tfName = "CatName"
        self.catNameTf.vc = self
        
        self.catAgePicker.delegate = self
        self.catAgePicker.dataSource = self
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let catName = catNameTf.text
        let catAge = Int(pickerData[catAgePicker.selectedRow(inComponent: 0)])
        
        if catName?.trimmingCharacters(in: CharacterSet.init(charactersIn: " ")) == "" {
            self.showFailMessage(view: self.view, message: "Cat name can not be empty")
            return
        }
        
        //update info
        self.ref.child("UXzbRyL7p4gj1yf4nY1lHZRhc9l2/data/catName").setValue(catName)
        self.ref.child("UXzbRyL7p4gj1yf4nY1lHZRhc9l2/data/catAge").setValue(catAge)
        
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

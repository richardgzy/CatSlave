//
//  SignupController.swift
//  CatSlave
//
//  Created by Richard on 16/10/17.
//  Copyright © 2017 crow. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignupController: UIViewController {
    @IBOutlet weak var emailtf: MyTextField!
    @IBOutlet weak var passwordtf: MyTextField!
    @IBOutlet weak var renterPasswordtf: MyTextField!
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signup(_ sender: Any) {
        let email = emailtf.text!
        let password = passwordtf.text!
        let rePassword = renterPasswordtf.text!
        
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
    }
    
    @IBAction func cancel(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
}

//
//  LoginController.swift
//  CatSlave
//
//  Created by Richard on 16/10/17.
//  Copyright © 2017 crow. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginController: UIViewController {
    
    @IBOutlet weak var emailtf: MyTextField!
    @IBOutlet weak var passwordtf: MyTextField!
    
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
        
        firebasePostRef = Database.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //try to log in when button clicked
    @IBAction func login(_ sender: Any) {
        let email = self.emailtf.text!
        let password = self.passwordtf.text!
        
        // check blank input
        if email == "" || password == ""
        {
            self.showFailMessage(view: self.view, message: "You have not input all the fields!")
            return
        }
    
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if user == nil
            {
                // login fail
                self.showFailMessage(view: self.view, message: (error?.localizedDescription)!)
            }
            else
            {
                var appdelegate = UIApplication.shared.delegate as! AppDelegate
                appdelegate.currentUserID = user?.uid
                
               //update firebase current user id therefore notify backend
                self.firebasePostRef!.child("currentUserId").setValue(appdelegate.currentUserID)
                
                // login succeed
                self.showSucceedMessage(view: self.view, message: "Log in Successfully")
                
                //use notification
                let notificationName = Notification.Name(rawValue: "LoginSucceed")
                NotificationCenter.default.post(name: notificationName, object: self, userInfo: nil)
                
//                self.delegate?.loginSucceed(tab: self.tabIndex)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

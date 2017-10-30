//
//  MyTextField.swift
//  PhotographyLover
//
//  Created by wc on 21/05/2017.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit

class MyTextField: UITextField, UITextFieldDelegate {

    var tfName : String = ""
    var tempString : String = ""
    var maxLength : Int?
    var vc : UIViewController?
    var borderView : UIView = UIView()
    
    // init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        // layout
        let height = CONST.TEXTFIELD_HEIGHT
        self.borderStyle = .none
        borderView = UIView()
        borderView.frame = CGRect(x: -0.5 * height, y: 0, width: self.frame.size.width+height, height: height)
        borderView.layer.cornerRadius = height/2.0
        borderView.layer.masksToBounds = true
        borderView.layer.borderWidth = 0.8
        borderView.layer.borderColor = UIColor(hexString: CONST.MAIN_RED)?.cgColor
        borderView.isUserInteractionEnabled = false
        self.addSubview(borderView)
        
        // text change delegate
        self.addTarget(self, action: #selector(textFieldEditingChanged), for: UIControlEvents.editingChanged)
        self.delegate = self
    }
    
    // layout subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = CONST.TEXTFIELD_HEIGHT
        borderView.frame = CGRect(x: -0.5 * height, y: 0, width: self.frame.size.width+height, height: height)
    }
    
    // save the text before textfield editingchanged
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // record text
        tempString = textField.text!
        return true
    }
    
    // text field editing changed
    @objc func textFieldEditingChanged(sender: UITextField) {
        //name changed, check name textfiled length
        if (sender.text?.characters.count)! > self.maxLength!
        {
            if tempString.characters.count > self.maxLength!
            {
                // if use suggest words, substring the text
                sender.text = tempString[0..<self.maxLength!]
            }
            else
            {
                // reset to before changed
                sender.text = tempString
            }
            vc?.showProgressWithImageName(view: (vc?.view)!, message: tfName + " cannot exceed " + String(maxLength!) + " !", imageName: "cross")
        }
    }
    
    // when press return on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // hide the keyboard
        textField.resignFirstResponder()
        return true;
    }
}

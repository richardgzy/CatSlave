//
//  BaseViewController.swift
//  PhotographyLover
//
//  Created by wc on 19/03/2017.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit

extension UIViewController {
    
    //show succeed MBProgressHUD message
    func showSucceedMessage(view:UIView, message:String) {
        showProgressWithImageName(view:view, message:message, imageName:"tick")
    }
    
    //show fail MBProgressHUD message
    func showFailMessage(view:UIView, message:String) {
        showProgressWithImageName(view:view, message:message, imageName:"cross")
    }

    //show MBProgressHUD with image
    func showProgressWithImageName(view:UIView, message:String, imageName:String) {
        let hud = MBProgressHUD.showAdded(to:view, animated: true)
        hud.mode = MBProgressHUDMode.customView
        hud.customView = UIImageView(image: UIImage(named: imageName)!)
        hud.detailsLabel.text = message
        hud.hide(animated: true, afterDelay: 1)
    }
    
    //show alert
    func showAlertMessage(message:NSString) {
        let alertVC = UIAlertController(title: "Alert", message: message as String, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: .default, handler:nil)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    //show alert with action
    func showAlertMessageWithAction(message:NSString, okHandler : ((UIAlertAction) -> Swift.Void)? = nil) {
        let alertVC = UIAlertController(title: "Alert", message: message as String, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler:okHandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler:nil)
        alertVC.addAction(cancelAction)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    // hide keyboard
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for v in self.view.subviews
        {
            if v is MyTextField || v is UITextView
            {
                v.resignFirstResponder()
            }
        }
        super.touchesBegan(touches, with: event)
    }
}

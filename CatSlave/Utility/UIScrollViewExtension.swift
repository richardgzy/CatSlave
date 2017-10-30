//
//  UIScrollViewExtension.swift
//  PhotographyLover
//
//  Created by wc on 29/05/2017.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    // hide keyboard
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for v in self.subviews
        {
            if v is MyTextField || v is UITextView
            {
                v.resignFirstResponder()
            }
        }
        super.touchesBegan(touches, with: event)
    }
}

//
//  UIColorExtension.swift
//  DrawinMonsterEncyclopaedia
//  Use hexString to create UIColor
//  Created by wc on 10/04/2017.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit

extension UIColor  {
    
    // init using hex String
    convenience init?(hexString: String) {
        self.init(hexString: hexString, alpha: 1.0)
    }
    
    // init using hexString and alpha
    convenience init?(hexString: String, alpha: Float) {
        
        // remove spaces and uppercase the string
        let set = CharacterSet.whitespacesAndNewlines
        var hex = hexString.trimmingCharacters(in: set).uppercased()
        
        // remove #
        if hex.hasPrefix("#") {
            hex.remove(at: hex.startIndex)
        }
        
        var red:UInt32 = 0, green:UInt32 = 0, blue:UInt32 = 0
        
        // substring and get int value
        Scanner(string: hex[0..<2]).scanHexInt32(&red)
        
        Scanner(string: hex[2..<4]).scanHexInt32(&green)
        
        Scanner(string: hex[4..<6]).scanHexInt32(&blue)
        
        self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha))
    }
 
}

//
//  StringExtension.swift
//  DrawinMonsterEncyclopaedia
//
//  Created by wc on 13/04/2017.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit

extension String {
    
    // use [startIndex..<endIndex] to substring instead String.Index
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            return String(self[startIndex..<endIndex])
        }
    }
}

//
//  MyButton.swift
//  DrawinMonsterEncyclopaedia
//
//  Created by wc on 13/04/2017.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit

class MyButton: UIButton {

    // init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        // height
        let height = self.frame.size.height
        
        // make the corner round
        self.layer.masksToBounds = true
        self.layer.cornerRadius = height/2.0
        
        // color
        self.backgroundColor = UIColor(hexString: CONST.MAIN_RED)
        self.setTitleColor(UIColor.white, for: .normal)
    }
}

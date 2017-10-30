//
//  MyTabBarController.swift
//  Assignment2_Sensor
//
//  Created by crow on 18/9/17.
//  Copyright © 2017 crow. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.barTintColor = UIColor.white
        self.tabBar.tintColor = UIColor(red: 106/255.0, green: 117/255.0, blue: 225/255.0, alpha: 1)
        
        for item in self.tabBar.items! {
            let barItem = item as UITabBarItem
            // set tabbaritem image in center
            barItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

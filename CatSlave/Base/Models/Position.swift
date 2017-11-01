//
//  Position.swift
//  CatSlave
//
//  Created by Richard on 19/10/17.
//  Copyright © 2017 crow. All rights reserved.
//

import UIKit
import CoreLocation

class Position: NSObject {
    var timeStamp: Date?
    var coordinate: CLLocation?
    
    override init() {
        super.init()
    }
    
    init(timeStamp: Date, latitude: Double, longitude: Double){
        self.timeStamp = timeStamp
        self.coordinate = CLLocation(latitude: latitude, longitude: longitude)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

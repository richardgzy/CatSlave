//
//  Position.swift
//  CatSlave
//
//  Created by Richard on 19/10/17.
//  Copyright © 2017 crow. All rights reserved.
//

import UIKit

class Position: NSObject {
    var timeStamp: Date?
    var latitude: Double?
    var longitude: Double?
    
    override init() {
    }
    
    init(timeStamp: Date, latitude: Double, longitude: Double){
        self.timeStamp = timeStamp
        self.latitude = latitude
        self.longitude = longitude
    }
}

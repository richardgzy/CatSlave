//
//  CatAnnotation.swift
//  CatSlave
//
//  Created by Richard on 23/10/17.
//  Copyright © 2017 crow. All rights reserved.
//
import UIKit
import MapKit

class CatAnnotation: NSObject, MKAnnotation{
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: UIImage?
    
    // init
    init(newCoordinate: CLLocationCoordinate2D, newTItle: String, newSubtitle: String, newImage: UIImage){
        self.coordinate = newCoordinate
        self.title = newTItle
        self.subtitle = newSubtitle
        self.image = newImage
    }
}

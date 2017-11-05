//
//  Utility.swift
//  CatSlave
//
//  Created by Richard on 29/10/17.
//  Copyright © 2017 crow. All rights reserved.
//

import UIKit

struct Utility {
    
    //convert string to date
    static func formateStringToDate(dateString: String, dateFormat: String, timeZoneStringAbbreviation: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        //Current time zone, change if needed
        dateFormatter.timeZone = TimeZone(abbreviation: timeZoneStringAbbreviation)
        let date = dateFormatter.date(from: dateString)
        return date!
    }
    
    //convert date to string
    static func formatDateToString(date: Date, dateFormat: String)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_AU")
        dateFormatter.dateFormat = dateFormat
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    // compress image
    static func compressImageSize(image:UIImage) -> Data{
        let originalImgSize = (UIImagePNGRepresentation(image)! as Data?)?.count
        var zipImageData : Data? = nil
        if originalImgSize!>1500 {
            zipImageData = UIImageJPEGRepresentation(image,0.1)! as Data?
        }else if originalImgSize!>600 {
            zipImageData = UIImageJPEGRepresentation(image,0.2)! as Data?
        }else if originalImgSize!>400 {
            zipImageData = UIImageJPEGRepresentation(image,0.3)! as Data?
        }else if originalImgSize!>300 {
            zipImageData = UIImageJPEGRepresentation(image,0.4)! as Data?
        }else if originalImgSize!>200 {
            zipImageData = UIImageJPEGRepresentation(image,0.5)! as Data?
        }
        return zipImageData!
    }
    
    //get current date and time String
    static func getCurrentDateTimeString() -> String{
        let date = Date()
        return formatDateToString(date: date, dateFormat: "yyyy-mm-dd hh:mm:ss")
    }
}

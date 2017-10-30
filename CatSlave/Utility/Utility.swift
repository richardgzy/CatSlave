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
        dateFormatter.dateFormat = dateFormat
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}

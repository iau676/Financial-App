//
//  Date+Extensions.swift
//  ios-dca-calculator
//
//  Created by ibrahim uysal on 12.07.2022.
//

import Foundation

extension Date {
    
    var MMYYFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: self)
    }
    
}

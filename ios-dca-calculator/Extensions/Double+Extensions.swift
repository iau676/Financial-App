//
//  Double+Extensions.swift
//  ios-dca-calculator
//
//  Created by ibrahim uysal on 15.07.2022.
//

import Foundation


extension Double {
    
    var stringValue: String {
        return String(describing: self)
    }
    
    var twoDecimalPlaceString: String {
        return String(format: "%.2f", self)
    }
    
}

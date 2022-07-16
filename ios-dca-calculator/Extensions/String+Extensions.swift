//
//  String+Extensions.swift
//  ios-dca-calculator
//
//  Created by ibrahim uysal on 9.07.2022.
//

import Foundation


extension String {
    
    func addBrackets() -> String {
        return "(\(self))"
    }
    
    func prefix(withText text: String) -> String {
        return text + self
    }
    
}

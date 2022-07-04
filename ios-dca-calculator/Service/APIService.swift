//
//  APIService.swift
//  ios-dca-calculator
//
//  Created by ibrahim uysal on 4.07.2022.
//

import Foundation
import Combine

struct APIService {
    
    var API_KEY: String {
        return Key().keys.randomElement() ?? ""
    }
    
    func fetchSymbolsPublisher(keywords: String) -> AnyPublisher<SearchResults, Error> {
        
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(keywords)&apikey=\(API_KEY)"
        
        let url = URL(string: urlString)!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: SearchResults.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main, options: nil)
            .eraseToAnyPublisher()
            
            
    }
    
}

//
//  APIService.swift
//  ios-dca-calculator
//
//  Created by ibrahim uysal on 4.07.2022.
//

import Foundation
import Combine

struct APIService {
    
    enum APIServiceError: Error {
        case encoding
        case badRequest
    }
    
    var API_KEY: String {
        return Key().keys.randomElement() ?? ""
    }
    
    func fetchSymbolsPublisher(keywords: String) -> AnyPublisher<SearchResults, Error> {
        
        guard let keywords = keywords.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return Fail(error: APIServiceError.encoding).eraseToAnyPublisher() }
        
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(keywords)&apikey=\(API_KEY)"
        
        guard let url = URL(string: urlString) else { return Fail(error: APIServiceError.badRequest).eraseToAnyPublisher() }
        
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: SearchResults.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main, options: nil)
            .eraseToAnyPublisher()
            
            
    }
    
}

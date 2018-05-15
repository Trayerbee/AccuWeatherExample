//
//  Target.swift
//  AccuWeather
//
//  Created by Karshigabekov, Ilyas on 14/05/2018.
//  Copyright © 2018 Ilyas-Karshigabekov. All rights reserved.
//

import Foundation

protocol Target {
    var path: String { get }
    var parameters: [String : String] { get }
}

extension Target {
    func request(with baseURL: URL) -> URLRequest {
        
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            fatalError("Unable to create URL components")
        }
        
        //
        let parametersWithKey = parameters.merging(["apikey": "nHLlFYxp24NfxkNQ2yAfXkLZjQKVM9QY", "locale": "en-US"], uniquingKeysWith: { $1 })
        
        components.queryItems = parametersWithKey.map {
            URLQueryItem(name: String($0), value: String($1))
        }
        
        guard let url = components.url else {
            fatalError("Could not get url")
        }
        
        var request = URLRequest(url: url)
        
        //For this app we always use get
        request.httpMethod = "GET"
        print (url)
        return request
    }
}

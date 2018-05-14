//
//  Core.swift
//  AccuWeather
//
//  Created by Karshigabekov, Ilyas on 14/05/2018.
//  Copyright © 2018 Ilyas-Karshigabekov. All rights reserved.
//

import Foundation
import RxSwift
import Freddy

class Core {
    private let baseURL : URL
    
    private init(base: URL) {
        baseURL = base
    }
}

extension Core {
    
    func send<T: JSONDecodable>(apiRequest: Target) -> Observable<T> {
        return Observable<T>.create { observer in
            let request = apiRequest.request(with: self.baseURL)
            let task = URLSession.shared.dataTask(with: request) { (optionalData, response, error) in
                if let error = error {
                    observer.onError(error)
                }
                else {
                    print(optionalData ?? "No data")
                    print(response ?? "No response")
                    do {
                        guard let data = optionalData else {
                            throw "Empty data"
                        }
                        let json = try JSON(data: data)
                        let model: T = try json.decode(type: T.self)
                        observer.onNext(model)
                    } catch let error {
                        observer.onError(error)
                    }
                    observer.onCompleted()
                }
                
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    
    public static func defaultNetworkCore() throws -> Core {
        guard let url = URL(string: "http://dataservice.accuweather.com") else {
            throw "Somehow failed to convert base URL from string."
        }
        return Core(base: url)
    }
}

extension String: Error {}

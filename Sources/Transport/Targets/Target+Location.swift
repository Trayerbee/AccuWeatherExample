//
//  Target+Location.swift
//  AccuWeather
//
//  Created by Karshigabekov, Ilyas on 14/05/2018.
//  Copyright © 2018 Ilyas-Karshigabekov. All rights reserved.
//

import Foundation

class LocationRequests: Target {
    var path = "/locations/v1"
    var parameters: [String : String]
  
    init(endPoint: String, params: [String: String]) {
        path = "\(path)/\(endPoint)"
        parameters = params
    }
}

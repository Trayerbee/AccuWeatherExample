//
//  Target+Forecast.swift
//  AccuWeather
//
//  Created by Karshigabekov, Ilyas on 14/05/2018.
//  Copyright © 2018 Ilyas-Karshigabekov. All rights reserved.
//

import Foundation

class OneDayForecast: Target {
    var path = "/forecasts/v1/daily/1day"
    var parameters: [String : String]
    
    init(endPoint: String, params: [String: String]) {
        path = "\(path)/\(endPoint)"
        parameters = params
    }
}

class FiveDayForecast: Target {
    var path = "/forecasts/v1/daily/5day"
    var parameters: [String : String]
    
    init(endPoint: String, params: [String: String]) {
        path = "\(path)/\(endPoint)"
        parameters = params
    }
}

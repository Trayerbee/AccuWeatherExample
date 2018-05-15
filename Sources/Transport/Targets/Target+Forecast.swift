//
//  Target+Forecast.swift
//  AccuWeather
//
//  Created by Karshigabekov, Ilyas on 14/05/2018.
//  Copyright © 2018 Ilyas-Karshigabekov. All rights reserved.
//

import Foundation

class DayForecast: Target {
    var path = "/forecasts/v1/daily"
    var parameters: [String : String]
    
    init(endPoint: String, params: [String: String]) {
        path = "\(path)/\(endPoint)"
        parameters = params
    }
}

enum DaysNumber {
    case oneDay
    case fiveDays
    
    public var endpoint: String {
        switch self {
        case .oneDay:
            return "1day"
        case .fiveDays:
            return "5day"
        }
    }
}

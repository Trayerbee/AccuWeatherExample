//
//  Forecast.swift
//  AccuWeather
//
//  Created by Karshigabekov, Ilyas on 15/05/2018.
//  Copyright © 2018 Ilyas-Karshigabekov. All rights reserved.
//

import Foundation

public struct Forecast {
    public let date: Date
    public let temperature: Temperature
    public let dayCondition: String
    public let nightCondition: String
    
    public var readableDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYYY"
        return formatter.string(from: date)
    }
    
    public struct Temperature {
        public let minimum: Double
        public let maximum: Double
    }
}

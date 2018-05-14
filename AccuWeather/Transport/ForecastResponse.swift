//
//  ForecastResponse.swift
//  AccuWeather
//
//  Created by Karshigabekov, Ilyas on 14/05/2018.
//  Copyright © 2018 Ilyas-Karshigabekov. All rights reserved.
//

import Foundation
import RxAlamofire
import RxSwift
import Freddy

struct ForecastResponse {
    public struct Forecast {
        public let date: Date
        public let temperature: Temperature
        public let dayCondition: String
        public let nightCondition: String
    }
    
    public struct Temperature {
        public let minimum: Double
        public let maximum: Double
    }
    
    public let headline: String
    public let forecasts: [Forecast]
}

extension ForecastResponse.Forecast: JSONDecodable {
    public init(json: JSON) throws {
        let timeStamp = try json.getInt(at: "EpochDate")
        date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        temperature = try json.decode(at: "Temperature", type: ForecastResponse.Temperature.self)
        dayCondition = try json.getString(at: "Day", "IconPhrase")
        nightCondition = try json.getString(at: "Night", "IconPhrase")
    }
}


extension ForecastResponse.Temperature: JSONDecodable {
    public init(json: JSON) throws {
        minimum = try json.getDouble(at: "Minimum", "Value")
        maximum = try json.getDouble(at: "Maximum", "Value")

    }
}
extension ForecastResponse: JSONDecodable {
    public init(json: JSON) throws {
        let optionalForecasts = try json.decodedArray(at: "DailyForecasts", alongPath: .nullBecomesNil, type: ForecastResponse.Forecast.self)
        guard let forecasts = optionalForecasts else {
            throw "Unable to parse forecast"
        }
        
        self.headline = try json.getString(at: "Headline", "Text")
        self.forecasts = forecasts
    }
}

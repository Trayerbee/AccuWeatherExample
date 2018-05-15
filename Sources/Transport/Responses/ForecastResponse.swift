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
    public let headline: String
    public let forecasts: [Forecast]
}

extension Forecast: JSONDecodable {
    public init(json: JSON) throws {
        let timeStamp = try json.getInt(at: "EpochDate")
        date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        temperature = try json.decode(at: "Temperature", type: Forecast.Temperature.self)
        dayCondition = try json.getString(at: "Day", "IconPhrase")
        nightCondition = try json.getString(at: "Night", "IconPhrase")
    }
}


extension Forecast.Temperature: JSONDecodable {
    public init(json: JSON) throws {
        minimum = try json.getDouble(at: "Minimum", "Value")
        maximum = try json.getDouble(at: "Maximum", "Value")

    }
}
extension ForecastResponse: JSONDecodable {
    public init(json: JSON) throws {
        let optionalForecasts = try json.decodedArray(at: "DailyForecasts", alongPath: .nullBecomesNil, type: Forecast.self)
        guard let forecasts = optionalForecasts else {
            throw "Unable to parse forecast"
        }
        self.headline = try json.getString(at: "Headline", "Text")
        self.forecasts = forecasts
    }
}

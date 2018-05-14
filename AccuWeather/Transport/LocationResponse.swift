//
//  LocationResponse.swift
//  AccuWeather
//
//  Created by Karshigabekov, Ilyas on 14/05/2018.
//  Copyright © 2018 Ilyas-Karshigabekov. All rights reserved.
//

import Foundation
import RxAlamofire
import RxSwift
import Freddy

struct CityResponse {
    public struct City {
        public let key: String
        public let localName: String
        public let country: Country
        public let area: Area
    }
    
    public struct Area {
        public let identifier: String
        public let localName: String
    }
    
    public struct Country {
        public let identifier: String
        public let localName: String
    }
    
    public let cities: [City]
}

extension CityResponse.City: JSONDecodable {
    public init(json: JSON) throws {
        key = try json.getString(at: "Key")
        localName = try json.getString(at: "LocalizedName")
        country = try json.decode(at: "Country", type: CityResponse.Country.self)
        area = try json.decode(at: "AdministrativeArea", type: CityResponse.Area.self)
    }
}

extension CityResponse: JSONDecodable {
    public init(json: JSON) throws {
        let optionalCities = try json.decodedArray(alongPath: .nullBecomesNil, type: CityResponse.City.self)
        guard let cities = optionalCities else {
            throw "Unable to parse regions response"
        }
        self.cities = cities
    }
}
extension CityResponse.Area: JSONDecodable {
    public init(json: JSON) throws {
        identifier = try json.getString(at: "ID")
        localName = try json.getString(at: "LocalizedName")
    }
}

extension CityResponse.Country: JSONDecodable {
    public init(json: JSON) throws {
        identifier = try json.getString(at: "ID")
        localName = try json.getString(at: "LocalizedName")
    }
}

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
    public let cities: [City]
}

extension City: JSONDecodable {
    public init(json: JSON) throws {
        key = try json.getString(at: "Key")
        localName = try json.getString(at: "LocalizedName")
        country = try json.decode(at: "Country", type: Country.self)
        area = try json.decode(at: "AdministrativeArea", type: Area.self)
    }
}

extension CityResponse: JSONDecodable {
    public init(json: JSON) throws {
        let optionalCities = try json.decodedArray(alongPath: .nullBecomesNil, type: City.self)
        guard let cities = optionalCities else {
            throw "Unable to parse regions response"
        }
        self.cities = cities
    }
}
extension Area: JSONDecodable {
    public init(json: JSON) throws {
        identifier = try json.getString(at: "ID")
        localName = try json.getString(at: "LocalizedName")
        englishName = nil
    }
}

extension Country: JSONDecodable {
    public init(json: JSON) throws {
        identifier = try json.getString(at: "ID")
        localName = try json.getString(at: "LocalizedName")
        englishName = nil
    }
}

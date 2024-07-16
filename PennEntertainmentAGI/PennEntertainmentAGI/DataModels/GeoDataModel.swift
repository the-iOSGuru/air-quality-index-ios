//
//  GeoDataModel.swift
//  PennEntertainmentAGI
//
//  Created by Buddy Rich on 7/11/24.
//

import Foundation

class ErrorResponse: Codable {
    let status: String
    let message: String
    
    init(status: String, message: String) {
        self.status = status
        self.message = message
    }
}

// MARK: - GeoData
class GeoData: Codable {
    let status: String
    let data: DataClass

    init(status: String, data: DataClass) {
        self.status = status
        self.data = data
    }
}

// MARK: - DataClass
class DataClass: Codable {
    let aqi, idx: Int
    let attributions: [Attribution]
    let city: City
    let dominentpol: String
    let iaqi: Iaqi
    let time: Time
    let forecast: Forecast
    let debug: Debug

    init(aqi: Int, idx: Int, attributions: [Attribution], city: City, dominentpol: String, iaqi: Iaqi, time: Time, forecast: Forecast, debug: Debug) {
        self.aqi = aqi
        self.idx = idx
        self.attributions = attributions
        self.city = city
        self.dominentpol = dominentpol
        self.iaqi = iaqi
        self.time = time
        self.forecast = forecast
        self.debug = debug
    }
}

// MARK: - Attribution
class Attribution: Codable {
    let url: String
    let name: String
    let logo: String?

    init(url: String, name: String, logo: String?) {
        self.url = url
        self.name = name
        self.logo = logo
    }
}

// MARK: - City
class City: Codable {
    let geo: [Double]
    let name: String
    let url: String
    let location: String

    init(geo: [Double], name: String, url: String, location: String) {
        self.geo = geo
        self.name = name
        self.url = url
        self.location = location
    }
}

// MARK: - Debug
class Debug: Codable {
    let sync: String

    init(sync: String) {
        self.sync = sync
    }
}

// MARK: - Forecast
class Forecast: Codable {
    let daily: Daily

    init(daily: Daily) {
        self.daily = daily
    }
}

// MARK: - Daily
class Daily: Codable {
    let o3, pm10, pm25: [O3]

    init(o3: [O3], pm10: [O3], pm25: [O3]) {
        self.o3 = o3
        self.pm10 = pm10
        self.pm25 = pm25
    }
}

// MARK: - O3
class O3: Codable {
    let avg: Int
    var day: String
    let max, min: Int
    var dayOfWeek: String?

    init(avg: Int, day: String, max: Int, min: Int) {
        self.avg = avg
        self.day = day
        self.max = max
        self.min = min
    }
}

// MARK: - Iaqi
class Iaqi: Codable {
    let h, p, pm25, t: H
    let w, wg: H

    init(h: H, p: H, pm25: H, t: H, w: H, wg: H) {
        self.h = h
        self.p = p
        self.pm25 = pm25
        self.t = t
        self.w = w
        self.wg = wg
    }
}

// MARK: - H
class H: Codable {
    let v: Double

    init(v: Double) {
        self.v = v
    }
}

// MARK: - Time
class Time: Codable {
    let s, tz: String
    let v: Int
    let iso: String

    init(s: String, tz: String, v: Int, iso: String) {
        self.s = s
        self.tz = tz
        self.v = v
        self.iso = iso
    }
}

//
//  WeatherModel.swift
//  Clima
//
//  Created by Pino Omodei on 10/03/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation

struct WeatherModel {
    let cityName: String
    let weatherId: Int
    let temp: Double
    
    var tempString: String { String(format: "%.1f", temp)}
    
    var conditionName: String {
        switch weatherId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 700...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "questionmark"
        }
    }
}

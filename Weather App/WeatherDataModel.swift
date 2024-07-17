//
//  WeatherDataModel.swift
//  Weather App
//
//  Created by Abhijith Rajeev on 2024-07-17.
//

import Foundation

struct CityWeather {
    let cityName: String
    let temperatureC: Float
    let temperatureF: Float
    let conditionCode: Int
}

class WeatherDataModel {
    static let shared = WeatherDataModel()
    private init() {}
    
    var citiesWeather: [CityWeather] = []
}

//
//  Temperature.swift
//  WeatherSun
//
//  Created by Bartosz Pawełczyk on 02/11/2017.
//  Copyright © 2017 Bartosz Pawełczyk. All rights reserved.
//

import Foundation

class Temperature {
    static var actualTemperature = Temperature()
    
    private init(){}
    
    var index: Int! = 0
    var actualTemp: Double!
    var actualForecastDay: Double!
    var actualForecastNight: Double!
    
    func convertToFarenheit() {
        actualTemp = convert(temp: actualTemp)
    }
    
    func forecastConvertToFarenheit() {
        actualForecastDay = convert(temp: actualForecastDay)
        actualForecastNight = convert(temp: actualForecastNight)
    }
    
    func convert(temp: Double) -> Double {
        return (temp * 1.8) + 32
    }
    
    func clear() {
        actualForecastNight = 0
        actualForecastDay = 0
        actualTemp = 0
    }
}

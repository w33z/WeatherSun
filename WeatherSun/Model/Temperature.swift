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
        actualTemp = convertFahrenheit(temp: actualTemp)
        actualForecastDay = convertFahrenheit(temp: actualForecastDay)
        actualForecastNight = convertFahrenheit(temp: actualForecastNight)
    }
    
    func convertFahrenheit(temp: Double) -> Double {
        return (temp * 1.8) + 32
    }
   
}

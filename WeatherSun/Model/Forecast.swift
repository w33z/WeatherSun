//
//  Forecast.swift
//  WeatherSun
//
//  Created by Bartosz Pawełczyk on 23/10/2017.
//  Copyright © 2017 Bartosz Pawełczyk. All rights reserved.
//

import Foundation
import Alamofire

class Forecast {
    var _forecastDay: String!
    var _weatherType: String!
    var _dayTemp: Double!
    var _nightTemp: Double!
    
    var forecastDay: String {
        get {
            if _forecastDay == nil {
                _forecastDay = " "
            }
        
            return _forecastDay
        }
        set {
            _forecastDay = newValue
        }
    }
    
    var weatherType: String {
        get {
            if _weatherType == nil {
            _weatherType = " "
            }
            
            return _weatherType
        }
        set {
            _weatherType = newValue
        }
    }
    
    var dayTemp: Double {
        get {
            if _dayTemp == nil {
                _dayTemp = 0.0
            }
        
            return _dayTemp
        }
        set {
            _dayTemp = newValue
        }
    }
    
    var nightTemp: Double {
        get {
            if _nightTemp == nil {
                _nightTemp = 0.0
            }
        
            return _nightTemp
        }
        set {
            _nightTemp = newValue
        }
    }
    
    init(forecastDay: String){
        self._forecastDay = forecastDay
    }
    
    init(weatherDict: Dictionary<String,AnyObject>){
        if let temp = weatherDict["temp"] as? Dictionary<String,AnyObject>{
            
            if let day = temp["day"] as? Double,let night = temp["night"] as? Double {
                self._dayTemp = (day - KELVINS)
                self._nightTemp = (night - KELVINS)
            }
        }
        
        if let weather = weatherDict["weather"] as? [Dictionary<String,AnyObject>] {
            
            if let main = weather[0]["main"] as? String {
                switch main.lowercased() {
                case "mist","smoke","haze","fog","dust":
                    self._weatherType = "atmosphere"
                default:
                    self._weatherType = main.lowercased()
                }
            }
        }
        
        if let date = weatherDict["dt"] as? Double {

            let unixConvertedDate = Date(timeIntervalSince1970: date)
            self._forecastDay = unixConvertedDate.dayOfTheWeek().capitalized
        }
    }
}

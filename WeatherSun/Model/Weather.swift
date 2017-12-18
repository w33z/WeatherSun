//
//  Weather.swift
//  WeatherSun
//
//  Created by Bartosz Pawełczyk on 23/10/2017.
//  Copyright © 2017 Bartosz Pawełczyk. All rights reserved.
//

import Foundation
import Alamofire


class Weather {
    var _cityName: String!
    var _weatherType: String!
    var _currentTemp: Double!
    var _weatherDescription: String!
    
    var cityName: String {
        if _cityName == nil {
            _cityName = ""
        }
        return _cityName
    }
    
    var weatherType: String{
        if _weatherType == nil {
            _weatherType = ""
        }
        
        return _weatherType
    }
    
    var currentTemp: Double{
        if _currentTemp == nil {
            _currentTemp = 0.0
        }
        
        return _currentTemp
    }
    
    var weatherDescription: String {
        if _weatherDescription == nil {
            _weatherDescription = ""
        }
        
        return _weatherDescription
    }
    
    func downloadWeatherDetails(completed: @escaping DownloadComplete){
        Alamofire.request(CURRENT_WEATHER_URL).responseJSON { response in
            let result = response.result

            if let dict = result.value as? Dictionary<String,AnyObject> {
                if let name = dict["name"] as? String {
                    self._cityName = name.capitalized
                }
                if let weather = dict["weather"] as? [Dictionary<String,AnyObject>]{
                    if let main = weather[0]["main"], let description = weather[0]["description"] as? String {
                        //self._weatherType = main.lowercased
                        switch main.lowercased {
                        case "mist","smoke","haze","fog","dust":
                            self._weatherType = "atmosphere"
                        default:
                            self._weatherType = main.lowercased
                        }
                        self._weatherDescription = description.capitalized
                    }
                }
                if let main = dict["main"] as? Dictionary<String,AnyObject>{
                    if let temp = main["temp"] as? Double {
                        self._currentTemp = temp - KELVINS
                    }
                }
            }
            completed()
        }
    }
}

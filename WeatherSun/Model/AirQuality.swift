//
//  AirQuality.swift
//  WeatherSun
//
//  Created by Bartosz Pawełczyk on 02.12.2017.
//  Copyright © 2017 Bartosz Pawełczyk. All rights reserved.
//

import Foundation
import Alamofire

enum airQualityDescription: String{
    case good = "Zadowalający"
    case moderate = "Dopuszczalny"
    case unhealthyForSensitive = "Niezdrowy dla wrażliwych osób"
    case unhealthy = "Niezdrowy"
    case veryUnhealty = "Bardzo niezdrowy"
    case danger = "Niebezpieczny !"
    case error = "Brak danych"
}

class AirQuality {
    var airData = [[String:Double]]()
    var description: String = "Stan powietrza: "
    
    func downloadAirQualityDetails(completed: @escaping DownloadComplete){
        Alamofire.request(AIR_QUALITY_URL).responseJSON { response in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String,AnyObject> {
                if let data = dict["data"] as? Dictionary<String,AnyObject>{
                    if let iaqi = data["iaqi"] as? Dictionary<String,AnyObject> {
                        if let o3 = iaqi["o3"] as? Dictionary<String,Double> {
                            for (_, value) in o3 {
                                self.airData.append(["o3":value])
                            }
                        }
                        if let pm25 = iaqi["pm25"] as? Dictionary<String,Double> {
                            for (_, value) in pm25 {
                                self.airData.append(["pm25":value])
                            }
                        }
                        if let pm10 = iaqi["pm10"] as? Dictionary<String,Double> {
                            for (_, value) in pm10 {
                                self.airData.append(["pm10":value])
                            }
                        }
                        if let no2 = iaqi["no2"] as? Dictionary<String,Double> {
                            for (_, value) in no2 {
                                self.airData.append(["no2":value])
                            }
                        }
                        let value = self.airData[1]["pm25"]!
                        switch (value) {
                        case 0..<50:
                            self.description = airQualityDescription.good.rawValue
                        case 51..<100:
                            self.description = airQualityDescription.moderate.rawValue
                        case 101..<150:
                            self.description = airQualityDescription.unhealthyForSensitive.rawValue
                        case 151..<200:
                            self.description = airQualityDescription.unhealthy.rawValue
                        case 201..<300:
                            self.description = airQualityDescription.veryUnhealty.rawValue
                        case 301..<1000:
                            self.description = airQualityDescription.danger.rawValue
                        default:
                            self.description = airQualityDescription.error.rawValue
                        }
                    }
                }
            }
            completed()
        }
    }
}

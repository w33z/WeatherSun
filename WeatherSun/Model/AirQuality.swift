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
    case error = "Brak wszystkich danych"
}

class AirQuality {
    var airData = [[String:Any]]()
    var description: String = "Stan powietrza: "
    
    func setDescription(_ value: Double){
        switch (value) {
        case 1..<50:
            self.description = airQualityDescription.good.rawValue
        case 50..<100:
            self.description = airQualityDescription.moderate.rawValue
        case 100..<150:
            self.description = airQualityDescription.unhealthyForSensitive.rawValue
        case 150..<200:
            self.description = airQualityDescription.unhealthy.rawValue
        case 200..<300:
            self.description = airQualityDescription.veryUnhealty.rawValue
        case 300..<1000:
            self.description = airQualityDescription.danger.rawValue
        default:
            self.description = airQualityDescription.error.rawValue
        }
    }
    
    func downloadAirQualityDetails(completed: @escaping DownloadComplete){
        Alamofire.request(AIR_QUALITY_URL).responseJSON { response in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String,AnyObject> {
                if let data = dict["data"] as? Dictionary<String,AnyObject>{
                    if let iaqi = data["iaqi"] as? Dictionary<String,AnyObject> {
                        if let o3 = iaqi["o3"] as? Dictionary<String,Double> {
                            let o3Value = o3["v"]!
                            self.airData.append(["o3":o3Value])
                        } else {
                           self.airData.append(["o3":0.0])
                        }                        
                        if let pm25 = iaqi["pm25"] as? Dictionary<String,Double> {
                            let pm25Value = pm25["v"]!
                            self.airData.append(["pm25":pm25Value])
                        } else {
                            self.airData.append(["pm25":0.0])
                        }
                        if let pm10 = iaqi["pm10"] as? Dictionary<String,Double> {
                            let pm10Value = pm10["v"]!
                            self.airData.append(["pm10":pm10Value])
                        } else {
                            self.airData.append(["pm10":0.0])
                        }
                        if let no2 = iaqi["no2"] as? Dictionary<String,Double> {
                            let no2Value = no2["v"]!
                            self.airData.append(["no2":no2Value])
                        } else {
                            self.airData.append(["no2":0.0])
                        }
                       let value = self.airData[1]["pm25"] as! Double
                       self.setDescription(value)
                    }
                }
            }
            completed(true)
        }
    }
}

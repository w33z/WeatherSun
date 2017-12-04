//
//  ForecastCollectionViewCell.swift
//  WeatherSun
//
//  Created by Bartosz Pawełczyk on 23/10/2017.
//  Copyright © 2017 Bartosz Pawełczyk. All rights reserved.
//

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var forecastDay: UILabel!
    @IBOutlet weak var forecastImage: UIImageView!
    @IBOutlet weak var forecastTemp: UILabel!
    
    func updateForecastCell(forecast: Forecast){
        translateForecastDay(forecast)
        forecastImage.image = UIImage(named: forecast.weatherType)
        
        Temperature.actualTemperature.actualForecastDay = forecast.dayTemp
        Temperature.actualTemperature.actualForecastNight = forecast.nightTemp
        
        if Temperature.actualTemperature.index == 0 {
            forecastTemp.text = "\(Int(Temperature.actualTemperature.actualForecastDay))˚/\(Int(Temperature.actualTemperature.actualForecastNight))˚"
        } else if Temperature.actualTemperature.index == 1 {
            Temperature.actualTemperature.forecastConvertToFarenheit()
            forecastTemp.text = "\(Int(Temperature.actualTemperature.actualForecastDay))˚/\(Int(Temperature.actualTemperature.actualForecastNight))˚"
        }
    }
    
    func translateForecastDay(_ forecast: Forecast){
        switch forecast.forecastDay {
        case "Mon":
            forecastDay.text = "Pon"
        case "Tue":
            forecastDay.text = "Wt"
        case "Wed":
            forecastDay.text = "Śr"
        case "Thu":
            forecastDay.text = "Czw"
        case "Fri":
            forecastDay.text = "Pt"
        case "Sat":
            forecastDay.text = "Sob"
        case "Sun":
            forecastDay.text = "Niedz"
        default:
            forecastDay.text = "\(forecast.forecastDay)"
        }
    }
}

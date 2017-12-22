 //
//  Constants.swift
//  WeatherSun
//
//  Created by Bartosz Pawełczyk on 23/10/2017.
//  Copyright © 2017 Bartosz Pawełczyk. All rights reserved.
//

import Foundation

let DAILY_API_KEY = "1ee0caf5d33dd23741fa3b28164f09fa"
let FORECAST_API_KEY = "42a1771a0b787bf12e734ada0cfc80cb"
let LATITUDE = "lat="
let LONGITUDE = "&lon="
let lang = "&lang=pl"
let KELVINS = 273.15

typealias DownloadComplete = () -> ()

 var CURRENT_WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather?lat=\(Location.sharedInstance.latitude ?? 0)&lon=\(Location.sharedInstance.longitude ?? 0)\(lang)&appid=\(DAILY_API_KEY)"
var FORECAST_WEATHER_URL = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(Location.sharedInstance.latitude ?? 0)&lon=\(Location.sharedInstance.longitude ?? 0)\(lang)&cnt=10&mode=json&appid=\(FORECAST_API_KEY)"


let AIR_QUALITY_KEY = "d582ec06be0f0aa42392fa5cdef0d5115ebfd863"
var AIR_QUALITY_URL = "https://api.waqi.info/feed/geo:\(Location.sharedInstance.latitude ?? 0);\(Location.sharedInstance.longitude ?? 0)/?token=\(AIR_QUALITY_KEY)"

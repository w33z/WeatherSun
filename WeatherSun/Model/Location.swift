//
//  Location.swift
//  WeatherSun
//
//  Created by Bartosz Pawełczyk on 22/10/2017.
//  Copyright © 2017 Bartosz Pawełczyk. All rights reserved.
//

import CoreLocation

class Location {
    static var sharedInstance = Location()
    
    private init() {}
    var latitude: Double!
    var longitude: Double!
    var name: String! = "Obecna lokalizacja"
}

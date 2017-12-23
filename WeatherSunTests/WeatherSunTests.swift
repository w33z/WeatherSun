//
//  WeatherSunTests.swift
//  WeatherSunTests
//
//  Created by Bartosz Pawełczyk on 22/10/2017.
//  Copyright © 2017 Bartosz Pawełczyk. All rights reserved.
//

import XCTest
@testable import WeatherSun

class WeatherSunTests: XCTestCase {
    
    func testCovertToFarenthite(){
        XCTAssertEqual(Temperature.actualTemperature.convertFahrenheit(temp: 0), 32)
        XCTAssertEqual(Temperature.actualTemperature.convertFahrenheit(temp: 34.5), 94.1)
    }
    
}

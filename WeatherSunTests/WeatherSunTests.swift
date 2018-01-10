//
//  WeatherSunTests.swift
//  WeatherSunTests
//
//  Created by Bartosz Pawełczyk on 22/10/2017.
//  Copyright © 2017 Bartosz Pawełczyk. All rights reserved.
//

import XCTest
import Alamofire
@testable import WeatherSun

class WeatherSunTests: XCTestCase {
    
    let weather = Weather()
    let weatherVC = WeatherViewController()
    
    func testCovertToFarenthite() {
        XCTAssertEqual(Temperature.actualTemperature.convertFahrenheit(temp: 0), 32)
        XCTAssertEqual(Temperature.actualTemperature.convertFahrenheit(temp: 34.5), 94.1)
    }
    
    func testDownloadWeather() {
        let exp = expectation(description: "weather")
        
        weather.downloadWeatherDetails { success in
            XCTAssertTrue(success)
            XCTAssertEqual("Cupertino", self.weather.cityName)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testDownloadForecast() {
        let exp = expectation(description: "forecast")
        
        weatherVC.downloadForecast { success in
            XCTAssertTrue(success)
            XCTAssertEqual(9, self.weatherVC.forecasts.count)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}

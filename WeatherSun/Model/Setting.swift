//
//  Setting.swift
//  WeatherSun
//
//  Created by Bartosz Pawełczyk on 31/10/2017.
//  Copyright © 2017 Bartosz Pawełczyk. All rights reserved.
//

import Foundation

class Setting {
    let name: String!
    let imageName: String!
    
    init(_ name: String,_ imageName: String){
        self.name = name
        self.imageName = imageName
    }
    
    init(_ name: String){
        self.name = name
        self.imageName = ""
    }
    
    
    
}

//
//  SettingCell.swift
//  WeatherSun
//
//  Created by Bartosz Pawełczyk on 28/10/2017.
//  Copyright © 2017 Bartosz Pawełczyk. All rights reserved.
//

import UIKit
import BetterSegmentedControl

class SettingCell: UICollectionViewCell {

    let settingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let settingImage: UIImageView = {
        let image = UIImageView()
        image.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let switchTemp: UISwitch = {
        let switchT = UISwitch()
        
        return switchT
    }()
    
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.lightGray : UIColor.white
            settingLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            settingImage.tintColor = isHighlighted ? UIColor.white : UIColor.lightGray
        }
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let control = BetterSegmentedControl(
        frame: CGRect(x: 0, y: 0.0, width: 200, height: 50.0),
        titles: ["°C", "°F"],
        index: 0,
        options: [.backgroundColor(UIColor.lightGray),
                  .cornerRadius(15),
                  .titleColor(.white),
                  .indicatorViewBackgroundColor(UIColor.white),
                  .selectedTitleColor(.black),
                  .titleFont(UIFont(name: "HelveticaNeue", size: 16.0)!),
                  .selectedTitleFont(UIFont(name: "HelveticaNeue-Medium", size: 16.0)!)]
    )

    func setupViews(setting: Setting){
        
        settingLabel.text = setting.name
        settingImage.image = UIImage(named: setting.imageName)
        
        if setting.name == "tempSwap" {

            settingLabel.isHidden = true
            self.isHighlighted = false
            control.center = CGPoint(x: self.frame.width/2, y: self.frame.height / 2)
            control.addTarget(self, action: #selector(changeUnitTemperature), for: .valueChanged)
            addSubview(control)
        }
        
        addSubview(settingImage)
        addSubview(settingLabel)
        
        settingLabel.translatesAutoresizingMaskIntoConstraints = false
        settingLabel.leftAnchor.constraint(equalTo: leftAnchor,constant: 75).isActive = true
        settingLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 15).isActive = true
        settingLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        settingLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        settingImage.translatesAutoresizingMaskIntoConstraints = false
        settingImage.leftAnchor.constraint(equalTo: leftAnchor,constant: 20).isActive = true
        settingImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        settingImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        settingImage.widthAnchor.constraint(equalToConstant: 30).isActive = true
        settingImage.heightAnchor.constraint(equalToConstant: 30).isActive = true

    }
    
    @objc func changeUnitTemperature(){
        let index = Int(control.index)
        if index == 0 {
            Temperature.actualTemperature.index = index
            
        } else if index == 1 {
            Temperature.actualTemperature.index = index
        }

    }  
}

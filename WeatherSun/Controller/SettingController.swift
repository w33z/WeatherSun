//
//  SettingController.swift
//  WeatherSun
//
//  Created by Bartosz Pawełczyk on 27/10/2017.
//  Copyright © 2017 Bartosz Pawełczyk. All rights reserved.
//

import Foundation
import UIKit

class SettingController: NSObject, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    let blackView = UIView()
    
    let settings: [Setting] = {
        return [Setting("tempSwap"),Setting("Zmień miasto","city"),Setting("Informacje","information"),Setting("Anuluj","cancel")]
        }()
    
    let cellHeight: CGFloat = 55
    let settingIdCell = "settingIdCell"
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    var weatherViewController: WeatherViewController?
    
    func showSetting(){
        if let window = UIApplication.shared.keyWindow {
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)

            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
            
            window.addSubview(blackView)
            window.addSubview(collectionView)
            
            let height: CGFloat = CGFloat(settings.count) * cellHeight
            let y = window.frame.height - height
            collectionView.frame = CGRect(x: 0, y: window.frame.size.height , width: window.frame.size.width, height: height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.size.width, height: self.collectionView.frame.size.height)
            }, completion: nil)
        }
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.collectionView.frame = CGRect(x: 0, y: window.frame.size.height, width: self.collectionView.frame.size.width, height: self.collectionView.frame.size.height)
            }
            self.weatherViewController?.locationAuthStatus()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: settingIdCell, for: indexPath) as? SettingCell {
            let setting = settings[indexPath.item]
            cell.setupViews(setting: setting)
            return cell
        } else {
            return SettingCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width,height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let setting = settings[indexPath.item]
        if setting.name != "tempSwap" && setting.imageName != "cancel" {
            dismiss()
            weatherViewController?.showControllerForSetting(setting: setting)
        } else if setting.imageName == "cancel" {
            dismiss()
        }
        
    }
    
    override init(){
        super.init()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SettingCell.self, forCellWithReuseIdentifier: settingIdCell)
    }
}

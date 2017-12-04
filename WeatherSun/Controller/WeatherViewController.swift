//
//  ViewController.swift
//  WeatherSun
//
//  Created by Bartosz Pawełczyk on 22/10/2017.
//  Copyright © 2017 Bartosz Pawełczyk. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import MapKit

class WeatherViewController: UIViewController, CLLocationManagerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate,MKMapViewDelegate{

    @IBOutlet weak var currentCity: UILabel!
    @IBOutlet weak var currentImageWeather: UIImageView!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var currentDesription: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    
    var currentWeather: Weather!
    
    var forecast: Forecast!
    var forecasts = [Forecast]()
    
    var currentAirQuality: AirQuality!
    
    lazy var settingLauncher: SettingController = {
        let launcher = SettingController()
        launcher.weatherViewController = self
        return launcher
    }()
    
    var label : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: label.font.fontName, size: 18)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.text = "Stan powietrza:"
        label.numberOfLines = 6
        return label
    }()
    
    var airQualityText = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startMonitoringSignificantLocationChanges()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    
        currentWeather = Weather()
        currentAirQuality = AirQuality()
        
        label.frame = CGRect(x: 0, y: 360, width: self.scrollView.frame.width, height: CGFloat.init(140))
        label.center.x = self.scrollView.center.x

        self.scrollView.addSubview(label)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationAuthStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }

    @IBAction func settingButton(_ sender: Any) {
        settingLauncher.showSetting()
    }
    
    var mapKit = MKMapView()
    var resultSearchController:UISearchController? = nil
    
    func showControllerForSetting(setting: Setting){
        let controllerForSetting = UIViewController()
        self.navigationController?.pushViewController(controllerForSetting, animated: true)
        controllerForSetting.navigationItem.title = setting.name
        controllerForSetting.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.title = ""
        
        if setting.imageName == "information" {
            
            let label = UILabel(frame: CGRect(x: 0, y: 130, width: self.view.frame.width, height: 100))
            label.font = UIFont(name: label.font.fontName, size: 20)
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.numberOfLines = 5
            label.text = "Icons and images: http://flaticon.com \n Weather API: http://openweathermap.com \n AirQuality API: http://aqicn.org/api/"
            controllerForSetting.view.backgroundColor = UIColor.lightGray
            controllerForSetting.view.addSubview(label)
        } else if setting.imageName == "city" {
            let cityTableViewController = storyboard!.instantiateViewController(withIdentifier: "CityTableViewController") as! CityTableViewController
            resultSearchController = UISearchController(searchResultsController: cityTableViewController)
            resultSearchController?.searchResultsUpdater = cityTableViewController
            //cityTableViewController.view.backgroundColor = UIColor.clear
            
            let searchBar = resultSearchController!.searchBar
            searchBar.sizeToFit()
            controllerForSetting.navigationItem.titleView = resultSearchController?.searchBar
            searchBar.placeholder = "Szukaj miasta..."
            resultSearchController?.hidesNavigationBarDuringPresentation = false
            definesPresentationContext = false
            cityTableViewController.mapView = mapKit
            cityTableViewController.updateSearchResults(for: resultSearchController!)
            controllerForSetting.view.addSubview(searchBar)

            /*let searchBar = UISearchBar()
            searchBar.frame = CGRect(x: 0, y: 60, width: self.view.frame.width, height: 50)
            searchBar.searchBarStyle = UISearchBarStyle.prominent
            searchBar.placeholder = "Szukaj miasta..."
            searchBar.sizeToFit()
            searchBar.isTranslucent = false
            searchBar.delegate = self

            controllerForSetting.view.backgroundColor = UIColor.lightGray
            controllerForSetting.view.addSubview(searchBar)*/
            
            mapKit.frame = CGRect(x: 0, y: 60, width: self.view.frame.width, height: self.view.frame.height)
            mapKit.delegate = self
            mapKit.showsUserLocation = true
            
            let span = MKCoordinateSpan(latitudeDelta: 0.05,longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: (currentLocation?.coordinate)!, span: span)
            self.mapKit.setRegion(region, animated: true)
        
            controllerForSetting.view.addSubview(mapKit)
            
            
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
//
    }
    

    @IBAction func refreshData(_ sender: Any) {
        locationAuthStatus()
        collectionView.reloadData()
    }
    
    func locationAuthStatus(){
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            currentLocation = locationManager?.location
            Location.sharedInstance.latitude = currentLocation?.coordinate.latitude
            Location.sharedInstance.longitude = currentLocation?.coordinate.longitude
            forecasts.removeAll()
            self.airQualityText = ""
            self.label.text = ""
            currentAirQuality.airData.removeAll()
            Temperature.actualTemperature.clear()
            self.currentAirQuality.downloadAirQualityDetails {
                self.airQualityText += "Stan powietrza: \(self.currentAirQuality.description)\n"
                for i in 0..<self.currentAirQuality.airData.count {
                    for (name,value) in self.currentAirQuality.airData[i] {
                        self.airQualityText += "\n\(name): \(value)"
                    }
                }
            self.currentWeather.downloadWeatherDetails {
                self.downloadForecast {
                        self.updateMainUI()
                    }
                }
            }
        } else {
            locationManager?.requestWhenInUseAuthorization()
            locationAuthStatus()
        }
    }
    
    func updateMainUI(){
        currentCity.text = currentWeather.cityName
        Temperature.actualTemperature.actualTemp = currentWeather.currentTemp
        if Temperature.actualTemperature.index == 0 {
            currentTemp.text = "\(Int(Temperature.actualTemperature.actualTemp))˚"
        } else if Temperature.actualTemperature.index == 1 {
            Temperature.actualTemperature.convertToFarenheit()
            currentTemp.text = "\(Int(Temperature.actualTemperature.actualTemp))˚"
        }
        currentDesription.text = currentWeather.weatherDescription
        currentImageWeather.image = UIImage(named: currentWeather.weatherType)
        label.text = airQualityText
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.scrollView.frame.height + label.frame.height)
    }
    
    func downloadForecast(completed: @escaping DownloadComplete) {
        Alamofire.request(FORECAST_WEATHER_URL).responseJSON { response in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String,AnyObject> {
                if let list = dict["list"] as? [Dictionary<String,AnyObject>] {
                    for obj in list {
                        let forecast = Forecast(weatherDict: obj)
                        self.forecasts.append(forecast)
                    }
                    self.forecasts.remove(at: 0) //Delete actual day from forecast
                    self.collectionView.reloadData()
                }
            }
            completed()
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forecasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastCell", for: indexPath) as? ForecastCollectionViewCell {
            let forecast = forecasts[indexPath.item]
            cell.updateForecastCell(forecast: forecast)
            return cell
        } else {
            return ForecastCollectionViewCell()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


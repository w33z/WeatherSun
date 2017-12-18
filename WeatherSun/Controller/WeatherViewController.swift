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
import GooglePlaces

class WeatherViewController: UIViewController,GMSAutocompleteResultsViewControllerDelegate, CLLocationManagerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate,MKMapViewDelegate{

    @IBOutlet weak var currentCity: UILabel!
    @IBOutlet weak var currentImageWeather: UIImageView!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var currentDesription: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var nextLocation: CLLocation!
    
    var mapKit = MKMapView()
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    var currentWeather: Weather!
    
    var forecast: Forecast!
    var forecasts = [Forecast]()
    
    var currentAirQuality: AirQuality!
    
    lazy var settingLauncher: SettingController = {
        let launcher = SettingController()
        launcher.weatherViewController = self
        return launcher
    }()
    
    var airQualityLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: label.font.fontName, size: 18)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.text = "Stan powietrza:"
        label.numberOfLines = 10
        return label
    }()
    
    var airQualityText = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
    
        currentWeather = Weather()
        currentAirQuality = AirQuality()
        
        airQualityLabel.frame = CGRect(x: 0, y: 355, width: self.scrollView.frame.width, height: CGFloat.init(160))
        airQualityLabel.center.x = self.scrollView.center.x

        self.scrollView.addSubview(airQualityLabel)
        
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

    @IBAction func refreshData(_ sender: Any) {
        locationAuthStatus()
        collectionView.reloadData()
    }
    
    @IBAction func settingButton(_ sender: Any) {
        settingLauncher.showSetting()
    }
    
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        
        Location.sharedInstance.name = place.name
        nextLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        Location.sharedInstance.latitude = nextLocation.coordinate.latitude
        Location.sharedInstance.longitude = nextLocation.coordinate.longitude
        setRegion()
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    fileprivate func setRegion() {
        mapKit.removeAnnotations(mapKit.annotations)
        let span = MKCoordinateSpan(latitudeDelta: 0.05,longitudeDelta: 0.05)
        let coords = CLLocationCoordinate2DMake(Location.sharedInstance.latitude, Location.sharedInstance.longitude)
        let region = MKCoordinateRegion(center: coords, span: span)
        self.mapKit.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.title = Location.sharedInstance.name
        annotation.coordinate = coords
        mapKit.addAnnotation(annotation)
    }
    
    func showControllerForSetting(setting: Setting){
        let controllerForSetting = UIViewController()
        self.navigationController?.pushViewController(controllerForSetting, animated: true)
        controllerForSetting.navigationItem.title = setting.name
        controllerForSetting.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.title = ""
        
        if setting.imageName == "information" {
            
            let informationsLabel = UILabel(frame: CGRect(x: 0, y: 130, width: self.view.frame.width, height: 120))
            informationsLabel.font = UIFont(name: informationsLabel.font.fontName, size: 20)
            informationsLabel.textColor = UIColor.white
            informationsLabel.textAlignment = .center
            informationsLabel.numberOfLines = 6
            informationsLabel.text = "Icons and images: http://flaticon.com \n Weather API:\n http://openweathermap.com \n AirQuality API: http://aqicn.org/api/"
            controllerForSetting.view.backgroundColor = UIColor.lightGray
            controllerForSetting.view.addSubview(informationsLabel)
        } else if setting.imageName == "city" {
            resultsViewController = GMSAutocompleteResultsViewController()
            resultsViewController?.delegate = self

            searchController = UISearchController(searchResultsController: resultsViewController)
            searchController?.searchResultsUpdater = resultsViewController
            
            let searchBar = searchController?.searchBar
            searchBar?.setValue("Anuluj", forKey:"_cancelButtonText")
            searchBar?.sizeToFit()
            searchBar?.placeholder = "Szukaj miasta..."
            searchController?.hidesNavigationBarDuringPresentation = false
            definesPresentationContext = false
            navigationController?.navigationBar.isTranslucent = false

            controllerForSetting.view.addSubview(searchBar!)
            
            
            mapKit.frame = CGRect(x: 0, y: 55, width: self.view.frame.width, height: self.view.frame.height)
            mapKit.delegate = self
            mapKit.showsUserLocation = true
            setRegion()
        
            controllerForSetting.view.addSubview(mapKit)
            
            
        }
    }
    
    func locationAuthStatus(){
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if currentLocation == nil {
                currentLocation = locationManager?.location
                Location.sharedInstance.latitude = currentLocation?.coordinate.latitude
                Location.sharedInstance.longitude = currentLocation?.coordinate.longitude
            } else {
                
                currentLocation = nextLocation
                Location.sharedInstance.latitude = nextLocation.coordinate.latitude
                Location.sharedInstance.longitude = nextLocation.coordinate.longitude
                
                CURRENT_WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather?lat=\(Location.sharedInstance.latitude!)&lon=\(Location.sharedInstance.longitude!)\(lang)&appid=\(DAILY_API_KEY)"
                FORECAST_WEATHER_URL = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(Location.sharedInstance.latitude!)&lon=\(Location.sharedInstance.longitude!)\(lang)&cnt=10&mode=json&appid=\(FORECAST_API_KEY)"
                AIR_QUALITY_URL = "https://api.waqi.info/feed/geo:\(Location.sharedInstance.latitude!);\(Location.sharedInstance.longitude!)/?token=\(AIR_QUALITY_KEY)"
            }

            forecasts.removeAll()
            self.airQualityText = ""
            currentAirQuality.airData.removeAll()
            Temperature.actualTemperature.clear()
            self.currentAirQuality.downloadAirQualityDetails {
                self.currentWeather.downloadWeatherDetails {
                    self.downloadForecast {
                        self.updateMainUI()
                    }
                }
                self.airQualityText += "Stan powietrza: \(self.currentAirQuality.description)\n"
                for i in 0..<self.currentAirQuality.airData.count {
                    for (name,value) in self.currentAirQuality.airData[i] {
                        self.airQualityText += "\n\(name): \(value)"
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
        airQualityLabel.text = airQualityText
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.scrollView.frame.height + airQualityLabel.frame.height)
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
                    self.forecasts.remove(at: 0)
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

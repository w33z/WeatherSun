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
    
    var mapView = MKMapView()
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
    
    var airQualityLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(18)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.text = "Stan powietrza: -"
        label.numberOfLines = 0
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

        
        airQualityLabel.frame = CGRect(x: 0, y: 385, width: self.scrollView.frame.size.width, height: 160)
        airQualityLabel.center.x = self.view.center.x

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
        mapView.removeAnnotations(mapView.annotations)
        let span = MKCoordinateSpan(latitudeDelta: 0.05,longitudeDelta: 0.05)
        let coords = CLLocationCoordinate2DMake(Location.sharedInstance.latitude, Location.sharedInstance.longitude)
        let region = MKCoordinateRegion(center: coords, span: span)
        self.mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.title = Location.sharedInstance.name
        annotation.coordinate = coords
        mapView.addAnnotation(annotation)
    }
    
    fileprivate func prepareInformations(_ controllerForSetting: UIViewController) {
        let label = UILabel(frame: CGRect(x: 0, y: (self.view.frame.size.height / 2) - 100, width: self.view.frame.size.width, height: 200))
        label.font = UIFont(name: label.font.fontName, size: 20)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Icons and images:\n http://flaticon.com \n\n Weather API:\n http://openweathermap.com \n\n AirQuality API: \nhttp://aqicn.org/api/"
        controllerForSetting.view.backgroundColor = UIColor.lightGray
        controllerForSetting.view.addSubview(label)
    }
    
    fileprivate func prepareCityChange(_ controllerForSetting: UIViewController) {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        resultsViewController?.autocompleteFilter?.type = .region
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
        
        let backToCurrentLocationButton = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        backToCurrentLocationButton.setImage(UIImage(named: "navigation"), for: .normal)
        backToCurrentLocationButton.addTarget(self, action: #selector(backToCurrentLocation), for: .touchUpInside)
        
        backToCurrentLocationButton.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        backToCurrentLocationButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        let barButton = UIBarButtonItem(customView: backToCurrentLocationButton)
        controllerForSetting.navigationItem.rightBarButtonItem = barButton
        
        
        mapView.frame = CGRect(x: 0, y: 55, width: self.view.frame.size.width, height: self.view.frame.size.height)
        mapView.delegate = self
        setRegion()
        
        controllerForSetting.view.addSubview(mapView)
    }
    
    @objc func backToCurrentLocation(){
        setLocation(locationManager.location)
        nextLocation = currentLocation
        Location.sharedInstance.name = "Obecna lokalizacja"
        setRegion()
        locationAuthStatus()
    }

    func showControllerForSetting(setting: Setting){
        let controllerForSetting = UIViewController()
        self.navigationController?.pushViewController(controllerForSetting, animated: true)
        controllerForSetting.navigationItem.title = setting.name
        controllerForSetting.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.title = ""
        
        if setting.imageName == "information" {
            
            prepareInformations(controllerForSetting)
        } else if setting.imageName == "city" {
            
            prepareCityChange(controllerForSetting)
        }
    }
    
    fileprivate func setLocation(_ location: CLLocation?){
        currentLocation = location
        
        guard let coords = location?.coordinate else { return }
        
        Location.sharedInstance.updateCoords(coords.latitude, coords.longitude)
        updateURLS(coords.latitude, coords.longitude)
    }
    
    func locationAuthStatus(){
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if currentLocation == nil {
                
                setLocation(locationManager.location)
                nextLocation = currentLocation
            } else {
                
                setLocation(nextLocation)
            }

            self.currentAirQuality.airData.removeAll()
            self.currentAirQuality.downloadAirQualityDetails {
                self.currentWeather.downloadWeatherDetails {
                    self.downloadForecast {
                        self.updateMainUI()
                    }
                }
                self.airQualityText = ""
                self.airQualityText += "Stan powietrza: \n\(self.currentAirQuality.description)\n"
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
    
    fileprivate func updateMainUI(){
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
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: self.scrollView.frame.size.height + airQualityLabel.frame.size.height)
    }
    
    fileprivate func downloadForecast(completed: @escaping DownloadComplete) {
        forecasts.removeAll()
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

//
//  ViewController.swift
//  ChanceOfWeather
//
//  Created by Jonathan Archille on 12/18/16.
//  Copyright © 2016 The Iron Yard. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate
{
    
    var isInitialLaunch = true
    var forecasts = [Weather]()
    let locationManager = CLLocationManager()
    var currentLatLong = (34.113501, -117.3834457)
        {
        didSet
        {
            fetchForecasts(latLong: currentLatLong, completion: { (forecast) in
                self.setLabels(weather: forecast)
                self.forecasts.append(forecast)
            })
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setButtons()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if isInitialLaunch
        {
            performSegue(withIdentifier: "changeLocationSegue", sender: self)
            isInitialLaunch = false
        }
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBOutlet weak var pastLocationsButton: UIButton!
    
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var changeLocationButton: UIButton!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    @IBOutlet weak var locationTitleLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var apparentTempLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var precipLabel: UILabel!
    
    @IBAction func useCurrentLocationTapped(_ sender: Any)
    {
        configureLocationManager()
        fetchForecasts(latLong: (currentLatLong), completion: { (forecast) in
            self.forecasts.append(forecast)
            self.setLabels(weather: forecast)
            
        })
    }
    
    func setLabels(weather: Weather)
    {
        
        if let locationName = weather.locationName {
            locationTitleLabel.text = locationName
        } else { locationTitleLabel.text = "--" }
        
        if let summary = weather.summary {
            summaryLabel.text = summary
        } else { summaryLabel.text = "--" }
        
        if let temperature = weather.temperature {
            temperatureLabel.text = "\(String(format: "%.0f", temperature))°"
        } else { temperatureLabel.text = "--" }
        
        if let apparentTemperature = weather.apparentTemperature {
            apparentTempLabel.text = "Feels like: \(String(format: "%.0f", apparentTemperature))°"
        } else { apparentTempLabel.text = "--" }
        
        if let minTemp = weather.minimumTemp {
            lowTempLabel.text = "Low Temp: \(String(format: "%.0f", minTemp))°"
        } else { lowTempLabel.text = "--" }
        
        if let maxTemp = weather.maxTemp {
            highTempLabel.text = "High Temp: \(String(format: "%.0f", maxTemp))°"
        } else { highTempLabel.text = "--" }
        
        if let humidity = weather.humidity {
            humidityLabel.text = "Humidity: \(String(format: "%.0f", humidity))%"
        } else { humidityLabel.text = "--" }
        
        if let bearing = weather.windBearing, let windSpeed = weather.windSpeed {
            windLabel.text = "Wind: from \(String(format: "%.0f", bearing))° at \(String(format: "%.0f", windSpeed)) m.p.h"
        } else { windLabel.text = "No wind indicated" }
        
        let precipProb = weather.precipProbability
        
        if weather.precipType != nil && precipProb != nil
        {
            precipLabel.text = "\(String(format: "%.0f", precipProb!))% chance of \(weather.precipType!)"
        } else { precipLabel.text = "No precipitation forecasted" }
        
        if let viz = weather.visibility {
            visibilityLabel.text = "Visibility: \(String(format: "%.0f", viz)) miles"
        } else { visibilityLabel.text = "--" }
        
        
        switch weather.icon!
        {
        case "clear-day":
            weatherIconImageView.image = #imageLiteral(resourceName: "clear-day")
        case "clear-night":
            weatherIconImageView.image = #imageLiteral(resourceName: "clear-night")
        case "rain":
            weatherIconImageView.image = #imageLiteral(resourceName: "rain")
        case "snow":
            weatherIconImageView.image = #imageLiteral(resourceName: "snow")
        case "sleet":
            weatherIconImageView.image = #imageLiteral(resourceName: "sleet")
        case "wind":
            weatherIconImageView.image = #imageLiteral(resourceName: "wind")
        case "fog":
            weatherIconImageView.image = #imageLiteral(resourceName: "fog")
        case "cloudy":
            weatherIconImageView.image = #imageLiteral(resourceName: "cloudy")
        case "partly-cloudy-day":
            weatherIconImageView.image = #imageLiteral(resourceName: "partly-cloudy-day")
        case "partly-cloudy-night":
            weatherIconImageView.image = #imageLiteral(resourceName: "partly-cloudy-night")
        default:
            weatherIconImageView.image = #imageLiteral(resourceName: "default")
        }
    }
    
    func setButtons()
    {
        changeLocationButton.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        changeLocationButton.layer.borderWidth = 1.5
        changeLocationButton.layer.borderColor = UIColor.black.cgColor
        changeLocationButton.layer.cornerRadius = 5
        
        currentLocationButton.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        currentLocationButton.layer.borderWidth = 1.5
        currentLocationButton.layer.borderColor = UIColor.black.cgColor
        currentLocationButton.layer.cornerRadius = 5
        
        pastLocationsButton.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        pastLocationsButton.layer.borderWidth = 1.5
        pastLocationsButton.layer.borderColor = UIColor.black.cgColor
        pastLocationsButton.layer.cornerRadius = 5
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "changeLocationSegue"
        {
            let destination = segue.destination as! ChangeLocationVC
            destination.delegate = self
        } else
        {
            let destination = segue.destination as! HistoryTableViewController
            destination.savedHistory = forecasts
        }
    }
    
    //MARK - CLLocation
    
    func configureLocationManager()
    {
        let status = CLLocationManager.authorizationStatus()
        if status != .denied && status != .restricted
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            if status == .notDetermined
            {
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if status == .authorizedWhenInUse
        {
            locationManager.startUpdatingLocation()
        }
        else
        {
            print("Oh no! They denied us access!")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print(error.localizedDescription)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[0]
        currentLatLong  = (location.coordinate.latitude, location.coordinate.longitude)
    }
    
}

extension ViewController: mainVCDelegate
{
    func setCoordinates(latLong: (Double, Double))
    {
        currentLatLong = latLong
    }
    
}



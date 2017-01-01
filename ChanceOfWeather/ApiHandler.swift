//
//  ApiHandler.swift
//  ChanceOfWeather
//
//  Created by Jonathan Archille on 12/18/16.
//  Copyright © 2016 The Iron Yard. All rights reserved.
//

import Foundation
import CoreLocation


let forecast = Weather()

func fetchForecasts(latLong: (Double, Double), completion: @escaping (Weather) -> ()) {
    
    fetchLocationName(coords: latLong)
    
    let url = URL(string: "https://api.darksky.net/forecast/cd81470fecd4bc9ae1c0af2bb48b4b73/\(latLong.0),\(latLong.1)")
    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
        
        if error != nil {
            print(error.debugDescription)
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            
            
            if let currently = json["currently"] as? [String: Any]
            {
                forecast.summary = currently["summary"] as? String
                forecast.icon = currently["icon"] as? String
                forecast.precipType = currently["precipType"] as? String
                forecast.temperature = currently["temperature"] as? Double
                forecast.apparentTemperature = currently["apparentTemperature"] as? Double
                forecast.precipProbability = currently["precipProbability"] as! Double * 100
                forecast.precipType = currently["precipType"] as? String
                forecast.windBearing = currently["windBearing"] as? Double
                forecast.windSpeed = currently["windSpeed"] as? Double
                forecast.humidity = currently["humidity"] as! Double * 100
                forecast.visibility = currently["visibility"] as? Double
            }
            
            if let daily = json["daily"] as? [String: Any]
            {
                if let data = daily["data"] as? [[String: Any]]
                {
                    if let today = data[0] as? [String: Any]
                    {
                        forecast.minimumTemp = today["temperatureMin"] as? Double
                        forecast.maxTemp = today["temperatureMax"] as? Double
                    }
                    
                }
            }
            
            
            DispatchQueue.main.async {
                completion(forecast)
            }
            
            
        } catch let error
        {
            print(error.localizedDescription)
        }
        
    }).resume()
    
}

func fetchLocationName(coords: (Double, Double))
{
    
    let location = CLLocation.init(latitude: coords.0, longitude: coords.1)
    CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
        
        if error != nil {
            print("error")
            return
        }
        
        if let response = placemarks?.first
        {
            guard let city = response.locality else { return }
            guard let state = response.administrativeArea else { return }
            
            forecast.locationName = "\(city), \(state)"
        }
        
    })
    
}




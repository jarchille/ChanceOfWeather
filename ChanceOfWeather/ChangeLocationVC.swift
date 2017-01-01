//
//  ChangeLocationVC.swift
//  ChanceOfWeather
//
//  Created by Jonathan Archille on 12/18/16.
//  Copyright © 2016 The Iron Yard. All rights reserved.
//

import UIKit
import CoreLocation

protocol mainVCDelegate {
    func setCoordinates(latLong: (Double, Double))
}

class ChangeLocationVC: UIViewController, UITextFieldDelegate {
    
    var delegate: mainVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(red: 79/255, green: 106/255, blue: 150/255, alpha: 1)
        
        cityStateTextField.delegate = self
        zipocodeTextField.delegate = self
        activityIndicator.isHidden = true
        
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var forecastButton: UIButton!
    
    @IBOutlet weak var cityStateTextField: UITextField!
    @IBOutlet weak var zipocodeTextField: UITextField!
    
    @IBAction func getForecast(_ sender: Any) {
        
        if zipocodeTextField.text != "" {
            let zipCode = zipocodeTextField.text
            forwardGeocode(someLocation: zipCode!)
        } else if cityStateTextField.text != "" {
            let cityState = cityStateTextField.text
            forwardGeocode(someLocation: cityState!)
        } else {
            let alert = UIAlertController(title: "ERROR" , message: "No data entered! Please try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        return true
    }
    
    func forwardGeocode(someLocation: String)
    {
        CLGeocoder().geocodeAddressString(someLocation, completionHandler:
            {
                
                (placemarks, error) in
                self.processResponse(withPlacemarks: placemarks, error: error)
                
        })
        forecastButton.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?)
    {
        forecastButton.isHidden = false
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        
        if error != nil
        {
            let alert = UIAlertController(title: "ERROR" , message: "No locations found! Please try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:
                { (action) in
                    alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location
            {
                let latLong = (location.coordinate.latitude, location.coordinate.longitude)
                delegate?.setCoordinates(latLong: latLong)
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        }
        
    }

}





//
//  WeatherManager.swift
//  Clima
//
//  Created by Pino Omodei on 10/03/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func weatherDidChange(_ weatherManager: WeatherManager, weather: WeatherModel)
    func weatherDidFailWithError(_ weatherManager: WeatherManager, _ error: Error)
}

struct WeatherManager {
    var delegate: WeatherManagerDelegate?
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?units=metric&lang=IT&appid=52afb43496ab6a16c949ed864939e202"
    
    func fetchWeather (cityName: String) {
        let urlString = ("\(weatherURL)&q=\(cityName.urlEncoded!)")
        performRequest(with: urlString)
    }

    func fetchWeather (latitude: Double, longitude: Double) {
        let urlString = ("\(weatherURL)&lat=\(latitude)&lon=\(longitude)")
        performRequest(with: urlString)
    }

    func performRequest(with urlString: String) {
        // 1. Create the URL
        
        if let url = URL(string: urlString) {
            // 2. Create a Session
            let session = URLSession(configuration: .default)
            // 3. Give the sesion a task with that URL
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.weatherDidFailWithError (self, error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = parseJSON(safeData) {
                        // Use the instance here --> Delegate Design Pattern!
                        delegate?.weatherDidChange(self, weather: weather)
                    }
                }
            }
            // 4. Execute the task
            task.resume()
        }
    }
    
    func parseJSON (_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            // take decodedData
            let cityName = decodedData.name
            let temp = decodedData.main.temp
            let weatherId = decodedData.weather[0].id
            
            // and create an instance of the model based on this data
            let weather = WeatherModel(cityName: cityName, weatherId: weatherId, temp: temp)
            
            // finally, we return it
            return (weather)
            
        } catch {
            delegate?.weatherDidFailWithError (self, error)
            return nil
        }
        
    }
}

extension String {
    var urlEncoded: String? {
        return addingPercentEncoding(withAllowedCharacters: .alphanumerics)
    }
}

/*
func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
                -> Void ) {
    // Use the last reported location.
    if let lastLocation = self.locationManager.location {
        let geocoder = CLGeocoder()
            
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(lastLocation,
                    completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                completionHandler(firstLocation)
            }
            else {
             // An error occurred during geocoding.
                completionHandler(nil)
            }
        })
    }
    else {
        // No location was available.
        completionHandler(nil)
    }
}
*/

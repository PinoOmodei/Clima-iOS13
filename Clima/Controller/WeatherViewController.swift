//
//  ViewController.swift
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delega al VC di gestire gli eventi del searchTextField
        // tutti gli eventi vengono notificati dal searchTextField al VC
        searchTextField.delegate = self
        weatherManager.delegate = self
        locationManager.delegate = self
        
        // Gestione dell'accesso alla posizione e richiesta della posizione una tantum
        locationManager.requestWhenInUseAuthorization()
        // locationManager.requestLocation() -> Spostato nell'handler del "cambio autorizzazione"
    }
    

    
    
}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return (textField.text != "")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // End Editing: Use the textField content
        // note: surely not NIL - see ShouldEndEditing method
        if let city = textField.text {
            weatherManager.fetchWeather(cityName: city)
        }
        
        // clean the textField
        textField.text = ""
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    
    func weatherDidChange(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.tempString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func weatherDidFailWithError(_ weatherManager: WeatherManager, _ error: Error) {
        print("View Controller detected a WeatherManager error")
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    
    @IBAction func positionPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            let lat = currentLocation.coordinate.latitude
            let lon = currentLocation.coordinate.longitude
            print("Refreshing weather from current location")
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager raised an error")
        print(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
         let status = CLLocationManager.authorizationStatus()
  
         switch status {
            case .authorizedAlways:
                locationManager.requestLocation()
            case .authorizedWhenInUse:
                locationManager.requestLocation()
            default:
                return
         }
     }
}

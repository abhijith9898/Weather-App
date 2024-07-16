//
//  ViewController.swift
//  Weather App
//
//  Created by Abhijith Rajeev on 2024-07-12.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    @IBOutlet var weatherCondition: UILabel!
    @IBOutlet var temperatureView: UILabel!
    @IBOutlet var weatherIconView: UIImageView!
    @IBOutlet var currentLocationView: UILabel!
    @IBOutlet var searchBoxView: UITextField!
    @IBOutlet var temperatureToggle: UISegmentedControl!
    
    private let locationManager = CLLocationManager()
    private var weatherResponse: WeatherResponse?
    
    let weatherIconMap: [Int: String] = [
        1000: "sun.max.fill",                // Clear
        1003: "cloud.sun.fill",              // Partly Cloudy
        1006: "cloud.fill",                  // Cloudy
        1009: "smoke.fill",                  // Overcast
        1030: "cloud.fog.fill",              // Mist
        1063: "cloud.drizzle.fill",          // Patchy rain possible
        1066: "cloud.snow.fill",             // Patchy snow possible
        1069: "cloud.sleet.fill",            // Patchy sleet possible
        1072: "cloud.hail.fill",             // Patchy freezing drizzle possible
        1087: "cloud.bolt.fill",             // Thundery outbreaks possible
        1114: "cloud.snow.fill",             // Blowing snow
        1117: "cloud.snow.fill",             // Blizzard
        1135: "cloud.fog.fill",              // Fog
        1147: "cloud.fog.fill",              // Freezing fog
        1150: "cloud.drizzle.fill",          // Patchy light drizzle
        1153: "cloud.drizzle.fill",          // Light drizzle
        1168: "cloud.hail.fill",             // Freezing drizzle
        1171: "cloud.hail.fill",             // Heavy freezing drizzle
        1180: "cloud.drizzle.fill",          // Patchy light rain
        1183: "cloud.rain.fill",             // Light rain
        1186: "cloud.rain.fill",             // Moderate rain at times
        1189: "cloud.rain.fill",             // Moderate rain
        1192: "cloud.heavyrain.fill",        // Heavy rain at times
        1195: "cloud.heavyrain.fill",        // Heavy rain
        1198: "cloud.hail.fill",             // Light freezing rain
        1201: "cloud.hail.fill",             // Moderate or heavy freezing rain
        1204: "cloud.sleet.fill",            // Light sleet
        1207: "cloud.sleet.fill",            // Moderate or heavy sleet
        1210: "cloud.snow.fill",             // Patchy light snow
        1213: "cloud.snow.fill",             // Light snow
        1216: "cloud.snow.fill",             // Patchy moderate snow
        1219: "cloud.snow.fill",             // Moderate snow
        1222: "cloud.snow.fill",             // Patchy heavy snow
        1225: "cloud.snow.fill",             // Heavy snow
        1237: "cloud.hail.fill",             // Ice pellets
        1240: "cloud.drizzle.fill",          // Light rain shower
        1243: "cloud.heavyrain.fill",        // Moderate or heavy rain shower
        1246: "cloud.heavyrain.fill",        // Torrential rain shower
        1249: "cloud.sleet.fill",            // Light sleet showers
        1252: "cloud.sleet.fill",            // Moderate or heavy sleet showers
        1255: "cloud.snow.fill",             // Light snow showers
        1258: "cloud.snow.fill",             // Moderate or heavy snow showers
        1261: "cloud.hail.fill",             // Light showers of ice pellets
        1264: "cloud.hail.fill",             // Moderate or heavy showers of ice pellets
        1273: "cloud.bolt.rain.fill",        // Patchy light rain with thunder
        1276: "cloud.bolt.rain.fill",        // Moderate or heavy rain with thunder
        1279: "cloud.bolt.snow.fill",        // Patchy light snow with thunder
        1282: "cloud.bolt.snow.fill"         // Moderate or heavy snow with thunder
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // displaySampleImage()
        searchBoxView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        if let location = searchBoxView.text, !location.isEmpty {
            loadWeather(for: location)
        }
        return true
    }
    

    @IBAction func onSearchButtonClick(_ sender: UIButton) {
        if let location = searchBoxView.text, !location.isEmpty {
            loadWeather(for: location)
        }
    }
    
    @IBAction func onLocationButtonClick(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    @IBAction func onToggleClick(_ sender: UISegmentedControl) {
        print("segment: \(sender.selectedSegmentIndex)")
        updateTemperatureDisplay()
    }
    
    @IBAction func onClitiesButtonClick(_ sender: UIButton) {
    }
    
    private func loadWeather(for location: String?){
        guard let location = location else {
            return
        }
        
        guard let url = getURL(query:location) else {
            print("Could not get URL")
            return
        }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) {data, response, error in
            print("API call complete")
            
            guard error == nil else {
                print("Error:")
                return
            }
            
            guard let data = data else {
                print("No data")
                return
            }
            
            
            if let weatherResponse = self.parseJson(data: data) {
               
                self.weatherResponse = weatherResponse
                
                DispatchQueue.main.async {
                    self.temperatureView.text = "\(weatherResponse.current.temp_c) C"
                    self.currentLocationView.text = "\(weatherResponse.location.name)"
                    self.weatherCondition.text = "\(weatherResponse.current.condition.text)"
                    self.updateTemperatureDisplay()
                    self.displayWeatherImage(code:weatherResponse.current.condition.code)
                }
                
            }
            
            
            
        }
        
        dataTask.resume()
    }
    
    private func getURL(query: String)-> URL? {
        let baseURL = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "d3203e1df2194c0aa4962343241407"
        
        guard let url = "\(baseURL)\(currentEndpoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        print(url)
        
        return URL(string: url)
    }
    
    private func parseJson(data: Data) -> WeatherResponse? {
        let decoder =  JSONDecoder()
        var weather: WeatherResponse?
        
        do{
            weather = try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            print("Error decoding")
        }
        
        return weather
    }
    
    private func updateTemperatureDisplay() {
            guard let weatherResponse = weatherResponse else {
                return
            }
            
            let temperature: String
            if temperatureToggle.selectedSegmentIndex == 0 {
                // Celsius
                temperature = "\(weatherResponse.current.temp_c) °C"
            } else {
                // Fahrenheit
                temperature = "\(weatherResponse.current.temp_f) °F"
            }
            
            temperatureView.text = temperature
    }
    
    private func displayWeatherImage(code:Int){
        
        let defaultColor = UIColor(hex: "#8E5F7E")
        let config:UIImage.SymbolConfiguration
        if(code == 1000){
            config = UIImage.SymbolConfiguration(paletteColors: [
                .systemYellow
            ])
        } else {
            config = UIImage.SymbolConfiguration(paletteColors: [
                defaultColor, .systemYellow
            ])
        }
        
        if let icon = weatherIconMap[code] {
            weatherIconView.preferredSymbolConfiguration = config
            weatherIconView.image = UIImage(systemName: icon)
        } else {
            weatherIconView.image = UIImage(systemName: "questionmark.circle")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            loadWeather(for: "\(location.coordinate.latitude),\(location.coordinate.longitude)")
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error)")
    }
    
}

struct Location: Decodable {
    let name: String
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}

struct Weather: Decodable {
    let temp_c: Float
    let temp_f: Float
    let condition: WeatherCondition
}

struct WeatherResponse: Decodable {
    let location: Location
    let current: Weather
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        let alpha = CGFloat(1.0)
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}


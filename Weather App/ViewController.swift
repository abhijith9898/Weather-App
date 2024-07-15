//
//  ViewController.swift
//  Weather App
//
//  Created by Abhijith Rajeev on 2024-07-12.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var weatherCondition: UILabel!
    @IBOutlet var temperatureView: UILabel!
    @IBOutlet var weatherIconView: UIImageView!
    @IBOutlet var currentLocationView: UILabel!
    @IBOutlet var searchBoxView: UITextField!
    @IBOutlet var temperatureToggle: UISegmentedControl!
    
    
    private var weatherResponse: WeatherResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        displaySampleImage()
    }
    
    private func displaySampleImage(){
        
        let customPurple = UIColor(hex: "#8E5F7E")
        
        let config = UIImage.SymbolConfiguration(paletteColors: [
            customPurple, .systemYellow
        ])
        
        weatherIconView.preferredSymbolConfiguration = config
        weatherIconView.image = UIImage(systemName: "cloud.sun.fill")
    }

    @IBAction func onSearchButtonClick(_ sender: UIButton) {
        loadWeather(search: searchBoxView.text)
    }
    @IBAction func onLocationButtonClick(_ sender: UIButton) {
    }
    @IBAction func onToggleClick(_ sender: UISegmentedControl) {
        print("segment: \(sender.selectedSegmentIndex)")
        updateTemperatureDisplay()
    }
    @IBAction func onClitiesButtonClick(_ sender: UIButton) {
    }
    
    private func loadWeather(search: String?){
        guard let search = search else {
            return
        }
        
        guard let url = getURL(query:search) else {
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


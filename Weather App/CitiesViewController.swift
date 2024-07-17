//
//  CitiesViewController.swift
//  Weather App
//
//  Created by Abhijith Rajeev on 2024-07-16.
//

import UIKit

class CitiesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
   
    @IBOutlet var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.register(UINib(nibName: "TableCustomCell", bundle: nil), forCellReuseIdentifier: "tableViewCell")
        tableView.dataSource = self
        tableView.delegate = self

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeatherDataModel.shared.citiesWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as? TableCustomCell else {
                   return UITableViewCell()
               }
        let cityWeather = WeatherDataModel.shared.citiesWeather[indexPath.row]
                
        let isCelsius = UserDefaults.standard.bool(forKey: "isCelsius")
        let temperature = isCelsius ? "\(cityWeather.temperatureC) °C" : "\(cityWeather.temperatureF) °F"
        let symbolName = cityWeather.conditionIcon
                
        cell.cityNameLabel?.text = "\(cityWeather.cityName)"
        cell.temperatureLabel?.text = "\(temperature)"
        
        let defaultColor = UIColor(hex: "#8E5F7E")
        let config:UIImage.SymbolConfiguration
        if(cityWeather.conditionCode == 1000){
            config = UIImage.SymbolConfiguration(paletteColors: [
                .systemYellow
            ])
        } else {
            config = UIImage.SymbolConfiguration(paletteColors: [
                defaultColor, .systemYellow
            ])
        }
        
            cell.imageView?.preferredSymbolConfiguration = config
            cell.imageView?.image = UIImage(systemName: symbolName)

                
        return cell
    }
  
    

   
}

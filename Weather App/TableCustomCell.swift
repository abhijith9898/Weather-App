//
//  TableCustomCell.swift
//  Weather App
//
//  Created by Abhijith Rajeev on 2024-07-17.
//

import UIKit

class TableCustomCell: UITableViewCell {
    
    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var weatherImageView: UIImageView!
    
    override func awakeFromNib() {
            super.awakeFromNib()
        weatherImageView.contentMode = .scaleAspectFit
        }
}

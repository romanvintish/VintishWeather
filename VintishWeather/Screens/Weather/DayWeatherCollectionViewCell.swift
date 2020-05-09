//
//  DayWeatherCollectionViewCell.swift
//  VintishYalantisWeather
//
//  Created by Roman Vintish on 07.05.2020.
//  Copyright © 2020 Vintish. All rights reserved.
//

import UIKit

class DayWeatherCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var atDayBlockTitleLabel: UILabel!
    @IBOutlet weak var atNightBlockTitleLabel: UILabel!
    @IBOutlet weak var atDayDescription: UILabel!
    @IBOutlet weak var atNightDescription: UILabel!
    @IBOutlet weak var atDayImageView: UIImageView!
    @IBOutlet weak var atNightImageView: UIImageView!
    
    @IBOutlet private weak var substrateView: UIView! {
        didSet {
            substrateView.layer.cornerRadius = 15
        }
    }
    
}

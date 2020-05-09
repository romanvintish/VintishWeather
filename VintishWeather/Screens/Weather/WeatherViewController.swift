//
//  WeatherViewController.swift
//  VintishYalantisWeather
//
//  Created by Roman Vintish on 07.05.2020.
//  Copyright © 2020 Vintish. All rights reserved.
//

import UIKit
import Kingfisher
import RealmSwift

class WeatherViewController: UIViewController {
    
    let cityName = "Dnipro"
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "Weather in \(cityName)"
        }
    }
    
    @IBOutlet private weak var modesSegmentControl: UISegmentedControl! {
        didSet {
            modesSegmentControl.selectedSegmentIndex = 0
            modesSegmentControl.setTitle("Two days", forSegmentAt: 0)
            modesSegmentControl.setTitle("Three days", forSegmentAt: 1)
            modesSegmentControl.setTitle("Five days", forSegmentAt: 2)
        }
    }
        
    @IBAction private func modesSegmentControlChangeValue(_ sender: Any) {
        switch modesSegmentControl.selectedSegmentIndex {
        case 0:
            mode = .twoDays
        case 1:
            mode = .threeDays
        case 2:
            mode = .fiveDays
        default:
            break
        }
    }
    
    @IBOutlet private weak var daysCollectionView: UICollectionView! {
        didSet {
            daysCollectionView.register(UINib(nibName: String(describing: DayWeatherCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: DayWeatherCollectionViewCell.self))
            daysCollectionView.delegate = self
            daysCollectionView.dataSource = self
            daysCollectionView.contentInset = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
            daysCollectionView.scrollIndicatorInsets = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    @IBOutlet weak var chartContainerView: UIView! {
        didSet {
            chartContainerView.layer.cornerRadius = 15
        }
    }
    
    @IBOutlet weak var chartBackgroundView: PeaksChartBackgroundView!
    
    @IBOutlet weak var chartView: PeaksChartView!
    
    private enum WeatherViewControllerMode: Int {
        case twoDays = 2
        case threeDays = 3
        case fiveDays = 5
    }
    
    private var mode: WeatherViewControllerMode = .twoDays {
        didSet {
            daysCollectionView.reloadData()
            setCharts()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        load()
    }

    var city: City? {
        didSet {
            daysCollectionView.reloadData()
            setCharts()
        }
    }
    
    private func setCharts() {
        guard let days = city?.fiveDaysForecast?.dayForecasts.prefix(mode.rawValue), days.count > 0 else {
            return
        }

        var maximumTemperature: Float = ((days[0].temperature?.maximum?.value.value ?? 0) + (days[0].temperature?.minimum?.value.value ?? 0))/2
        var minimumTemperature: Float = maximumTemperature

        for day in days {
            guard let dmaxTemperature = day.temperature?.maximum?.value.value, let dminTemperature = day.temperature?.minimum?.value.value else {
                continue
            }
            
            let dTemperature = (dmaxTemperature + dminTemperature)/2

            if dTemperature > maximumTemperature {
                maximumTemperature = dTemperature
            }
            
            if dTemperature < minimumTemperature {
                minimumTemperature = dTemperature
            }
        }
                    
        let temperatureDifference = maximumTemperature - minimumTemperature
                    
        var backgroundValues:[PeaksChartBackgroundViewValue] = Array.init()
        var graphicValues:[PeaksChartViewValue] = Array.init()
        
        for (index, day) in days.enumerated() {
            guard let dmaxTemperature = day.temperature?.maximum?.value.value, let dminTemperature = day.temperature?.minimum?.value.value else {
                continue
            }
            
            let dTemperature = (dmaxTemperature + dminTemperature)/2
            
            let relativeTemperatureDifference = dTemperature - minimumTemperature
            
            let position = CGFloat(relativeTemperatureDifference/temperatureDifference)
            
            graphicValues.append(PeaksChartViewValue.init(progress: position, tapHandler: {
                self.daysCollectionView?.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .centeredHorizontally, animated: true)
            }))
            
            backgroundValues.append(PeaksChartBackgroundViewValue.init(isVertical: false, progress: 1-position))
        }
        
        for i in 0..<days.count {
            backgroundValues.append(PeaksChartBackgroundViewValue.init(isVertical: true, progress: CGFloat(i)/CGFloat(days.count-1)))
        }
        
        chartBackgroundView.values = backgroundValues
        chartView.values = graphicValues
    }
    
    private func load() {
        DatabaseFetchService.shared.city(forName: cityName) { (city) in
            self.city = city
        }
        
        DatabaseUpdateService.shared.cities(forName: cityName) { (errors, success, cities) in
            guard let city = cities?.first else {
                return
            }
            
            DatabaseUpdateService.shared.fiveDaysForecast(forCity: city) { (errors, success, city) in
                self.city = city
            }
        }
    }
    
}

extension WeatherViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = city?.fiveDaysForecast?.dayForecasts.count else {
            return 0
        }
        
        return mode.rawValue
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let day = city?.fiveDaysForecast?.dayForecasts[indexPath.row] else {
            return UICollectionViewCell()
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: DayWeatherCollectionViewCell.self), for: indexPath) as! DayWeatherCollectionViewCell

        cell.temperatureLabel.text = "\(day.temperature?.minimum?.value.value ?? 0.0) - \(day.temperature?.maximum?.value.value ?? 0.0) \(day.temperature?.maximum?.unit ?? "")"
        
        cell.atDayBlockTitleLabel.text = "At day:"
        cell.atNightBlockTitleLabel.text = "At Night:"

        let atDayImageUrl = AccuWeatherAPI.shared.imageUrlForCode(day.dayForecasts?.imageId.value)
        cell.atDayImageView.kf.setImage(with: atDayImageUrl)
        
        let atNightImageUrl = AccuWeatherAPI.shared.imageUrlForCode(day.nightForecasts?.imageId.value)
        cell.atNightImageView.kf.setImage(with: atNightImageUrl)
        
        cell.atDayDescription.text = day.dayForecasts?.phrase
        cell.atNightDescription.text = day.nightForecasts?.phrase

        if let dateTimestamp = day.date.value {
            let date = Date.init(timeIntervalSince1970: Double(dateTimestamp))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd • MM • yyyy"
            
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = nil
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width - 40, height: collectionView.frame.size.height - 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
}

//
//  DailyForecast.swift
//  VintishWeather
//
//  Created by Roman Vintish on 08.05.2020.
//  Copyright © 2020 Vintish. All rights reserved.
//

import Foundation
import RealmSwift

class DailyForecast: Object, Decodable {

    var date = RealmOptional<Int>()
    @objc dynamic var temperature: Temperature?
    @objc dynamic var dayForecasts: Forecast?
    @objc dynamic var nightForecasts: Forecast?

    enum CodingKeys: String, CodingKey {
        case date = "EpochDate"
        case temperature = "Temperature"
        case dayForecasts = "Day"
        case nightForecasts = "Night"
    }

    public required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            date = RealmOptional(try container.decodeIfPresent(Int.self, forKey: .date))
            temperature = try container.decodeIfPresent(Temperature.self, forKey: .temperature)
            dayForecasts = try container.decodeIfPresent(Forecast.self, forKey: .dayForecasts)
            nightForecasts = try container.decodeIfPresent(Forecast.self, forKey: .nightForecasts)

            let realm = try Realm()
                        
            if realm.isInWriteTransaction {
                realm.add(self)
            } else {
                try realm.write {
                    realm.add(self)
                }
            }
        } catch {
            print(error)
        }
    }
    
}

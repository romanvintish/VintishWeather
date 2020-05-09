//
//  FiveDaysForecast.swift
//  VintishWeather
//
//  Created by Roman Vintish on 08.05.2020.
//  Copyright © 2020 Vintish. All rights reserved.
//

import Foundation
import RealmSwift

class FiveDaysForecast: Object, Decodable {

    var dayForecasts = List<DailyForecast>()
    
    enum CodingKeys: String, CodingKey {
        case dayForecasts = "DailyForecasts"
    }
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            if let set = try container.decodeIfPresent(Set<DailyForecast>.self, forKey: .dayForecasts) {
                let sortedItems = Array(set).sorted(by: { (first, second) -> Bool in
                    return first.date.value ?? 0 < second.date.value ?? 0
                })
                
                dayForecasts.removeAll()
                dayForecasts = List()
                dayForecasts.append(objectsIn: sortedItems)
            }
                        
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



//
//  DatabaseUpdateService.swift
//  VintishWeather
//
//  Created by Roman Vintish on 08.05.2020.
//  Copyright © 2020 Vintish. All rights reserved.
//

import Foundation
import RealmSwift

class DatabaseUpdateService: NSObject {
    
    static let shared = DatabaseUpdateService()
    private let systemErrorKey = "Network system error"

    func cities(forName name:String, completion:@escaping (_ errors:[String:String]?, _ success:Bool, _ cities:[City]?)->()) {
        AccuWeatherAPI.shared.cities(forName: name) { (error, data, type) in
            guard let data = data else {
                if let error = error {
                    completion([self.systemErrorKey:error.localizedDescription], false, nil)
                } else {
                    completion(nil, false, nil)
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode([City].self, from: data)
                completion(nil, true, response)
            } catch {
                completion([self.systemErrorKey:error.localizedDescription], false, nil)
            }
        }
    }
    
    func fiveDaysForecast(forCity city:City, completion:@escaping (_ errors:[String:String]?, _ success:Bool, _ forecasts:City?)->()) {
        guard let cityId = city.id.value else {
            completion([self.systemErrorKey:"Incorrect city"], false, nil)
            return
        }
        
        AccuWeatherAPI.shared.fiveDaysWeather(cityId: String(cityId)) { (error, data, type) in
            guard let data = data else {
                if let error = error {
                    completion([self.systemErrorKey:error.localizedDescription], false, nil)
                } else {
                    completion(nil, false, nil)
                }
                return
            }
            
            do {
                let fiveDaysForecast = try JSONDecoder().decode(FiveDaysForecast?.self, from: data)
                
                let realm = try Realm()

                if realm.isInWriteTransaction {
                    city.fiveDaysForecast = fiveDaysForecast
                } else {
                    try realm.write {
                        city.fiveDaysForecast = fiveDaysForecast
                    }
                }

                completion(nil, true, city)
            } catch {
                completion([self.systemErrorKey:error.localizedDescription], false, nil)
            }
        }
    }
    
}

//
//  DatabaseFetchService.swift
//  VintishWeather
//
//  Created by Roman Vintish on 08.05.2020.
//  Copyright © 2020 Vintish. All rights reserved.
//

import Foundation
import RealmSwift

class DatabaseFetchService {
    
    static let shared = DatabaseFetchService()
    
    private func first<T: Object>() -> T? {
        do {
            let realm = try Realm()
            let objects = realm.objects(T.self)
            return objects.first
        } catch {
            print(error)
            return nil
        }
    }
    
    private func all<T: Object>() -> [T]? {
        do {
            let realm = try Realm()
            return Array(realm.objects(T.self))
        } catch {
            print(error)
            return nil
        }
    }
    
    var cities: [City]? {
        get {
            return all()
        }
    }
    
    func city(forName name:String, completion:@escaping (_ city:City?)->()) {
        do {
            let city: City? = all()?.first { (city) -> Bool in
                return city.name == name
            }
            
            completion(city)
        } catch {
            completion(nil)
        }
    }
    
}

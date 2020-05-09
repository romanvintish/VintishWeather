//
//  DatabaseSupportService.swift
//  VintishWeather
//
//  Created by Roman Vintish on 08.05.2020.
//  Copyright © 2020 Vintish. All rights reserved.
//

import Foundation
import RealmSwift

class DatabaseSupportService {
    
    static let shared = DatabaseSupportService()
    
    func delete(_ completion:(_ success:Bool)->Void) {
        do {
            let realm = try! Realm()

            try realm.write {
                realm.deleteAll()
            }
            
            completion(true)
        } catch  {
            print("Realm clean error")
            
            print(error)
            
            completion(false)
        }
    }
    
    func prepare() {
        var configuration = Realm.Configuration.defaultConfiguration
        configuration.deleteRealmIfMigrationNeeded = true

        do {
            let documentsURL = try FileManager.default.url(for: .applicationSupportDirectory,
                                                           in: .userDomainMask,
                                                           appropriateFor: nil,
                                                           create: true)
            let realmPath = documentsURL.appendingPathComponent("db.realm")
            configuration.fileURL = realmPath
        } catch {
            print(error)
        }
        
        Realm.Configuration.defaultConfiguration = configuration
    }
    
}

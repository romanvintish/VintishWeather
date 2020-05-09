//
//  City.swift
//  VintishWeather
//
//  Created by Roman Vintish on 08.05.2020.
//  Copyright © 2020 Vintish. All rights reserved.
//

import Foundation
import RealmSwift

class City: Object, Decodable {

    @objc dynamic var name:String?
    var id = RealmOptional<Int>()
    @objc dynamic var fiveDaysForecast:FiveDaysForecast?
    
    enum CodingKeys: String, CodingKey {
        case id = "Key"
        case name = "EnglishName"
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            if let stringID = try container.decodeIfPresent(String.self, forKey: .id) {
                id = RealmOptional(Int(stringID))
            }
            
            name = try container.decodeIfPresent(String.self, forKey: .name)
            
            let realm = try Realm()
   
            if realm.isInWriteTransaction {
                realm.add(self, update: .modified)
            } else {
                try realm.write {
                    realm.add(self, update: .modified)
                }
            }
        } catch {
            print(error)
        }
    }
    
}


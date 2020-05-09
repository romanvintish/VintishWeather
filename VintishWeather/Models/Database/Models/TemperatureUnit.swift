//
//  TemperatureUnit.swift
//  VintishWeather
//
//  Created by Roman Vintish on 08.05.2020.
//  Copyright © 2020 Vintish. All rights reserved.
//

import Foundation
import RealmSwift

class TemperatureUnit: Object, Decodable {

    @objc dynamic var unit:String?
    var value = RealmOptional<Float>()

    enum CodingKeys: String, CodingKey {
        case unit = "Unit"
        case value = "Value"
    }

    public required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            unit = try container.decodeIfPresent(String.self, forKey: .unit)
            value = RealmOptional(try container.decodeIfPresent(Float.self, forKey: .value))
            
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

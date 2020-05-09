//
//  Temperature.swift
//  VintishWeather
//
//  Created by Roman Vintish on 08.05.2020.
//  Copyright © 2020 Vintish. All rights reserved.
//

import Foundation
import RealmSwift

class Temperature: Object, Decodable {

    @objc dynamic var maximum: TemperatureUnit?
    @objc dynamic var minimum: TemperatureUnit?

    enum CodingKeys: String, CodingKey {
        case maximum = "Maximum"
        case minimum = "Minimum"
    }
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            maximum = try container.decodeIfPresent(TemperatureUnit.self, forKey: .maximum)
            minimum = try container.decodeIfPresent(TemperatureUnit.self, forKey: .minimum)

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


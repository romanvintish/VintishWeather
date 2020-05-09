//
//  Forecast.swift
//  VintishWeather
//
//  Created by Roman Vintish on 08.05.2020.
//  Copyright © 2020 Vintish. All rights reserved.
//

import Foundation
import RealmSwift

class Forecast: Object, Decodable {

    @objc dynamic var phrase:String?
    var imageId = RealmOptional<Int>()

    enum CodingKeys: String, CodingKey {
        case imageId = "Icon"
        case phrase = "IconPhrase"
    }

    public required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            phrase = try container.decodeIfPresent(String.self, forKey: .phrase)
            imageId = RealmOptional(try container.decodeIfPresent(Int.self, forKey: .imageId))
            
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

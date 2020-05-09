//
//  ServerResponse.swift
//  VintishWeather
//
//  Created by Roman Vintish on 08.05.2020.
//  Copyright © 2020 Vintish. All rights reserved.
//

import Foundation

class ServerResponse: Decodable {
    
    var success: Bool = false
    var errors: [String:String]?
    
    enum ServerResponseCodingKeys: String, CodingKey {
        case errors = "errors"
        case success = "success"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ServerResponseCodingKeys.self)
        
        do {
            success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
            errors = try container.decodeIfPresent([String:String].self, forKey: .errors)
        } catch {
            print(error)
        }
    }
    
}

class ServerResponseWithData<DataType>: ServerResponse where DataType: Decodable {
    
    var data: DataType?
    var links: ServerResponseLinks?
    var meta: ServerResponseMeta?

    enum ServerResponseWithDataCodingKeys: String, CodingKey {
        case data = "data"
        case links = "links"
        case meta = "meta"
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)

        let container = try decoder.container(keyedBy: ServerResponseWithDataCodingKeys.self)
        
        do {
            data = try container.decodeIfPresent(DataType.self, forKey: .data)
            links = try container.decodeIfPresent(ServerResponseLinks.self, forKey: .links)
            meta = try container.decodeIfPresent(ServerResponseMeta.self, forKey: .meta)
        } catch {
            print(error)
        }
    }

}

class ServerResponseLinks: Decodable {
    
    var first: String?
    var last: String?
    var prev: String?
    var next: String?

    enum CodingKeys: String, CodingKey {
        case first = "first"
        case last = "last"
        case prev = "prev"
        case next = "next"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            first = try container.decodeIfPresent(String.self, forKey: .first)
            last = try container.decodeIfPresent(String.self, forKey: .last)
            prev = try container.decodeIfPresent(String.self, forKey: .prev)
            next = try container.decodeIfPresent(String.self, forKey: .next)
        } catch {
            print(error)
        }
    }
    
}

class ServerResponseMeta: Decodable {
    
    var currentPage: Int?
    var offset: Int?
    var lastPage: Int?
    var path: String?
    var perPage: Int?
    var to: Int?
    var total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case offset = "offset"
        case lastPage = "last_page"
        case path = "path"
        case perPage = "per_page"
        case to = "to"
        case total = "total"
    }
  
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            path = try container.decodeIfPresent(String.self, forKey: .path)
            currentPage = try container.decodeIfPresent(Int.self, forKey: .currentPage)
            offset = try container.decodeIfPresent(Int.self, forKey: .offset)
            lastPage = try container.decodeIfPresent(Int.self, forKey: .lastPage)
            perPage = try container.decodeIfPresent(Int.self, forKey: .perPage)
            to = try container.decodeIfPresent(Int.self, forKey: .to)
            total = try container.decodeIfPresent(Int.self, forKey: .total)
        } catch {
            print(error)
        }
    }
    
}

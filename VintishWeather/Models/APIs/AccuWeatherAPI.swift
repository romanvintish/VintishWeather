//
//  OpenWeatherAPI.swift
//  VintishYalantisWeather
//
//  Created by Roman Vintish on 07.05.2020.
//  Copyright © 2020 Vintish. All rights reserved.
//

import Foundation

let prodHost: String = "https://dataservice.accuweather.com/"

class AccuWeatherAPI: NSObject {
    
    static var shared = AccuWeatherAPI()
    
    private let baseUrl = prodHost //stageHost
    
    private var networkingService: NetworkingService = NetworkingService()
    
    private let apiKey = "GaH4CtpJfQl53SpEI3SBXUELDuKd6Irm"
    
    func cities(forName name:String,
                completion:@escaping (_ error:Error?, _ data:Data?,_ type:String?)->()) {
        let url = baseUrl + "locations/v1/cities/search"
        
        var parameters: [String:String] = [:]
        
        parameters["q"] = name
        parameters["apikey"] = apiKey
        
        networkingService.connect(type: .get,
                                  url: url,
                                  inPathParameters: parameters,
                                  completion: { (error, data, type) in
                                    completion(error, data, type?.rawValue)
        })
    }
    
    func cities(forIPAddress address:String,
                completion:@escaping (_ error:Error?, _ data:Data?,_ type:String?)->()) {
        let url = baseUrl + "locations/v1/cities/ipaddress"
        
        var parameters: [String:String] = [:]
        
        parameters["q"] = address
        parameters["apikey"] = apiKey
        
        networkingService.connect(type: .get,
                                  url: url,
                                  inPathParameters: parameters,
                                  completion: { (error, data, type) in
                                    completion(error, data, type?.rawValue)
        })
    }
    
    func fiveDaysWeather(cityId:String,
                         completion:@escaping (_ error:Error?, _ data:Data?,_ type:String?)->()) {
        let url = baseUrl + "forecasts/v1/daily/5day/\(cityId)"
        
        var parameters: [String:String] = [:]
        
        parameters["q"] = cityId
        parameters["apikey"] = apiKey
        parameters["metric"] = "true"

        networkingService.connect(type: .get,
                                  url: url,
                                  inPathParameters: parameters,
                                  completion: { (error, data, type) in
                                    completion(error, data, type?.rawValue)
        })
    }
    
    func imageUrlForCode(_ code:Int?) -> URL? {
        guard let code = code else {
            return nil
        }
        
        let path = "https://developer.accuweather.com/sites/default/files/\(String(format: "%02d", code))-s.png"
        
        return URL.init(string: path)
    }
    
}

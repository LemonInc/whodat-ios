//
//  JSONDownloader.swift
//  WhoDat
//
//  Created by Apple on 23/07/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//

import Foundation

class JSONDownloader {
    
    let session:URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    typealias JSON = [String: AnyObject]
    
    func jsonTask(with request: URLRequest, completionHandler completion: @escaping (JSON?, JSONError?) -> Void) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { data, response, error in
            
            //convert to http response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestFailed)
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                        completion(json, nil)
                    } catch {
                        completion(nil, .jsonConversionFailure)
                    }
                }else {
                    completion(nil, .invalidData)
                }
                
            } else {
                completion(nil, .responseUnsuccessful)
            }
        }
        
        return task
    }
}

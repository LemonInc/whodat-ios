//  MapAPI.swift
//  WhoDat
//
//  Created by Apple on 10/12/2017.
//  Copyright © 2017 WotDat. All rights reserved.
//
import CoreLocation
import Foundation

struct MapAPI{
    let latitude:String
    let longitude:String
    let id:String
    let type:String
    let name:String
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    
    init(json:[String:Any]) throws {
        guard let latitude = json["Latitude"] as? String else {throw SerializationError.missing("Latitude is missing")}
        guard let longitude = json["Longitude"] as? String else {throw SerializationError.missing("Longitude is missing")}
        guard let id = json["ID"] as? String else {throw SerializationError.missing("ID is missing")}
        guard let type = json["Type"] as? String else {throw SerializationError.missing("Type is missing")}
        guard let name = json["Name"] as? String else {throw SerializationError.missing("Name is missing")}
        
        self.latitude = latitude
        self.longitude = longitude
        self.id = id
        self.type = type
        self.name = name
        
    }
    
    static let basePath = "https://raw.githubusercontent.com/LemonInc/master-data/master/master-data.json"
    
    static func getJSONMapData (latitude:CLLocationDegrees, longitude:CLLocationDegrees, completion: @escaping ([MapAPI]) -> ()) {
        let url = basePath
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
        
            var mapDataArray:[MapAPI] = []
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyData = json["items"] as? [[String:Any]] {
                            
                            for dataPoint in dailyData {
                                var latitudeString = dataPoint["Latitude"] as! String
                                var longitudeString = dataPoint["Longitude"] as! String
                                
                                if (latitudeString.characters.count != 0) || (longitudeString.characters.count != 0) {
                                    if let mapAPIObject = try? MapAPI(json: dataPoint) {
                                        mapDataArray.append(mapAPIObject)
                                    }
                                }
                                
                            }
                            
                        }
                    }
                }catch {
                    print(error.localizedDescription)
                }
                
                completion(mapDataArray)
                
            }
            
            
        }
        
        task.resume()
        
        
    }
    
    
}

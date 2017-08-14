////
////  DataApi.swift
////  WhoDat
////
////  Created by Apple on 19/07/2017.
////  Copyright © 2017 WotDat. All rights reserved.
////
//
import Foundation

class DataAPI {
    lazy var baseUrl: URL = {
        return URL(string: "https://firebasestorage.googleapis.com/v0/b/whodat-fdb19.appspot.com/o/data.json?alt=media&token=3004f0e9-c773-40eb-bab9-c9a0bd82ef9b")!
    }()
    
    let downloader = JSONDownloader()
    
}




//
//class DataApi {
//    
//    let dataPath = "https://firebasestorage.googleapis.com/v0/b/whodat-fdb19.appspot.com/o/data.json?alt=media&token=3004f0e9-c773-40eb-bab9-c9a0bd82ef9b"
//    
//    func getDataFromJson() {
//        
//        let url = URL(string: dataPath)
//        
//        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
//            if error != nil {
//                print("ERROR FROM JSON")
//                
//            } else {
//                
//                if let data = data {
//                    print(data)
//                }
//                
//                
//                
//                
//            }
//
//        }
//    }
//    
//    
//    
//    
//    
//    
//    
//    
//    
//}

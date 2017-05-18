//
//  ServerAPIManager.swift
//  RahoovatorIOS
//
//  Created by MacBook Pro on 4/4/17.
//  Copyright © 2017 Helldog. All rights reserved.
//

import Foundation

class ServerAPIManager {
    class func send(data: String,
                    completion handler: ((Bool, String) -> ())?) {
        let path = URL(string: "http://192.168.0.5/" + data)!
        LSNetworkManager.getRequestWith(path: path) {
            responseData, statuscode in
            guard let response = responseData else {
                return
            }
            
            if statuscode == 200 {
                handler?(true, String(data: response, encoding: .utf8)!)
            } else {
                handler?(false, "ERROR")
            }
        }
        
    }

}
    

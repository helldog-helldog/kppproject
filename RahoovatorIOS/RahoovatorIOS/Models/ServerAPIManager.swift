//
//  ServerAPIManager.swift
//  RahoovatorIOS
//
//  Created by MacBook Pro on 4/4/17.
//  Copyright © 2017 Helldog. All rights reserved.
//

import Foundation
import SwiftSocket

class ServerAPIManager {
    
    static private var client = TCPClient(address: "oleg.com", port: Int32(80))
    
    class func connectToServer() {
        client.connect(timeout: 10)
    }
    
    class func send(data: String?) {
        if data == nil {
            return
        }
        
        client.send(string: data!)
    }
}

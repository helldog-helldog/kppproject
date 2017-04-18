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
    
    var shared = ServerAPIManager()
    
    private var client = TCPClient(address: "oleg.com", port: Int32(80))
    
    func send(data: String) -> String {
        switch client.connect(timeout: 10) {
        case .success:
            if let response = sendRequest(string: data, using: client) {
                return response
            }
            return ""
        case .failure(let error):
            return error.localizedDescription
        }
    }
    
    private func sendRequest(string: String, using client: TCPClient) -> String? {
        
        switch client.send(string: string) {
        case .success:
            return readResponse(from: client)
        case .failure(let error):
            return error.localizedDescription
        }
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10) else { return nil }
        
        return String(bytes: response, encoding: .utf8)
    }
}

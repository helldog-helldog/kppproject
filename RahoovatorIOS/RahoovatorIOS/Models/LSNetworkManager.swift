//
//  LSNetworkManager.swift
//  HFL
//
//  Created by LembergSun on 7/28/16.
//  Copyright © 2016 LembergSun. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case DELETE = "DELETE"
    case PUT = "PUT"
}

struct HTTPHeader {
    let value: String
    let field: String
}

class LSNetworkManager {
    
    //MARK: - Private methods
    private class func runTaskWithRequest(request: URLRequest,
                                          handler: @escaping (_ responseData: Data?, _ statusCode: Int) -> ()) {
        let task = URLSession.shared.dataTask(with: request)
        { (data, response, error) in
            if let error = error as NSError? {
                if error.code == -999 {
                    return
                }
                DispatchQueue.main.async {
                    let errorDictionary = ["errors" : [error.localizedDescription]]
                    let errorData =
                        try? JSONSerialization.data(withJSONObject: errorDictionary, options: [])
                    handler(errorData,
                            error.code)
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    let errorDictionary = ["errors" : ["Server does not respond"]]
                    let errorData =
                        try? JSONSerialization.data(withJSONObject: errorDictionary, options: [])
                    handler(errorData,
                            0)
                }
                return
            }
            let statusCode = (response as! HTTPURLResponse).statusCode
            //warning: temp code
            print("status code: \(statusCode)")
            let parsedData: Any?
            do {
                parsedData = try JSONSerialization.jsonObject(with: data, options: [])
                print("response: \(String(describing: parsedData))")
            }
            catch {
                let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                print("error: \(String(describing: responseString))")
            }
            ////////////////////
            DispatchQueue.main.async {
                handler(data,
                        statusCode)
            }
        }
        task.resume()
    }
    
    private class func requestWith(method: HTTPMethod,
                                   path: URL,
                                   parameters: Any?,
                                   headers: Array<HTTPHeader>?,
                                   handler: @escaping (_ responseData: Data?,
        _ statusCode: Int) -> ()) {
        print("request path: \(path.absoluteString)")
        var request = URLRequest(url: path)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 30
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let parameters = parameters {
            print("parameters: \(parameters)")
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters,
                                                           options: JSONSerialization.WritingOptions())
        }
        if let headers = headers {
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.field)
            }
        }
        print("request headers: \(String(describing: request.allHTTPHeaderFields))")
        runTaskWithRequest(request: request) { (responseData, statusCode) in
            handler(responseData, statusCode)
        }
    }
    
    //MARK: - public methods
    class func postRequestWith(path: URL,
                               headers: Array<HTTPHeader>? = nil,
                               parameters: Any?,
                               handler: ((_ responseData: Data?,
        _ statusCode: Int) -> ())?) {
        requestWith(method: .POST,
                    path: path,
                    parameters: parameters,
                    headers: headers) { (responseData, statusCode) in
                        if let handler = handler {
                            handler(responseData,
                                    statusCode)
                        }
        }
    }
    
    class func getRequestWith(path: URL,
                              parameters: [String : String]? = nil,
                              headers: Array<HTTPHeader>? = nil,
                              handler: ((_ responseData: Data?,
        _ statusCode: Int) -> ())?) {
        let requestURL = NSURLComponents(string: path.absoluteString)
        if let parameters = parameters {
            requestURL?.queryItems = []
            for (name, value) in parameters {
                requestURL?.queryItems?.append(URLQueryItem(name: name, value: value))
            }
        }
        
        
        requestWith(method: .GET,
                    path: (requestURL?.url)!,
                    parameters: nil,
                    headers: headers) { (responseData, statusCode) in
                        if let handler = handler {
                            handler(responseData,
                                    statusCode)
                        }
        }
    }
    
    class func deleteRequestWith(path: URL,
                                 headers: Array<HTTPHeader>? = nil,
                                 parameters: Any?,
                                 handler: ((_ responseData: Data?,
        _ statusCode: Int) -> ())?) {
        requestWith(method: .DELETE,
                    path: path,
                    parameters: parameters,
                    headers: headers) { (responseData, statusCode) in
                        if let handler = handler {
                            handler(responseData,
                                    statusCode)
                        }
        }
    }
    
    class func uploadImage(image: UIImage?,
                           byLink: URL,
                           withHeaders: Array<HTTPHeader>? = nil,
                           imageParameterName: String,
                           otherParameters: Dictionary<String, Any>? = nil,
                           handler: ((_ responseData: Data?, _ statusCode: Int) -> ())?) {
        //request
        var request = URLRequest(url: byLink)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpShouldHandleCookies = false
        request.timeoutInterval = 30
        
        //headers
        if let headers = withHeaders {
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.field)
            }
        }
        let boundaryString = "<<<abcdefg-----1234567890>>>"
        let contentyType = "multipart/form-data; boundary=" + boundaryString
        request.addValue(contentyType, forHTTPHeaderField: "Content-Type")
        
        //parameters (all mapameters must be strings)
        var requestBody = Data()
        if let parameters = otherParameters {
            for (parameterKey, parameterValue) in parameters {
                let headerData =
                    "--\(boundaryString)\r\n".data(using: String.Encoding.utf8)!
                requestBody.append(headerData)
                let keyString = "Content-Disposition: form-data; name=\"\(parameterKey)\"\r\n\r\n"
                let keyData = keyString.data(using: String.Encoding.utf8)!
                requestBody.append(keyData)
                let parameterData = "\(parameterValue)\r\n".data(using: String.Encoding.utf8)!
                requestBody.append(parameterData)
            }
        }
        
        //image data
        if image != nil,
            let imageData = UIImageJPEGRepresentation(image!, 1) {
            requestBody.append("--\(boundaryString)\r\n".data(using: String.Encoding.utf8)!)
            let timeStamp = String(Int(NSDate.timeIntervalSinceReferenceDate))
            let content = "Content-Disposition: form-data; " +
                "name=\"\(imageParameterName)\"; " +
            "filename=\"image\(timeStamp).jpg\"\r\n"
            requestBody.append(content.data(using: String.Encoding.utf8)!)
            requestBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: String.Encoding.utf8)!)
            requestBody.append(imageData)
            requestBody.append("\r\n".data(using: String.Encoding.utf8)!)
        }
        
        requestBody.append("--\(boundaryString)--\r\n".data(using: String.Encoding.utf8)!)
        request.httpBody = requestBody
        
        //content-length
        request.setValue(String(requestBody.count), forHTTPHeaderField: "Content-Length")
        
        runTaskWithRequest(request: request) { (responseData, statusCode) in
            if let handler = handler {
                handler(responseData, statusCode)
            }
        }
    }
    
    class func uploadImages(images: [UIImage]?,
                           byLink: URL,
                           withHeaders: Array<HTTPHeader>? = nil,
                           imageParameterNames: [String],
                           otherParameters: Dictionary<String, Any>? = nil,
                           handler: ((_ responseData: Data?, _ statusCode: Int) -> ())?) {
        
        //request
        var request = URLRequest(url: byLink)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpShouldHandleCookies = false
        request.timeoutInterval = 30
        
        //headers
        if let headers = withHeaders {
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.field)
            }
        }
        let boundaryString = "<<<abcdefg-----1234567890>>>"
        let contentyType = "multipart/form-data; boundary=" + boundaryString
        request.addValue(contentyType, forHTTPHeaderField: "Content-Type")
        //        print("request headers: \(request.allHTTPHeaderFields)")
        
        //parameters (all mapameters must be strings)
        var requestBody = Data()
        if let parameters = otherParameters {
            for (parameterKey, parameterValue) in parameters {
                let headerData =
                    "--\(boundaryString)\r\n".data(using: String.Encoding.utf8)!
                requestBody.append(headerData)
                let keyString = "Content-Disposition: form-data; name=\"\(parameterKey)\"\r\n\r\n"
                let keyData = keyString.data(using: String.Encoding.utf8)!
                requestBody.append(keyData)
                let parameterData = "\(parameterValue)\r\n".data(using: String.Encoding.utf8)!
                requestBody.append(parameterData)
            }
        }
        
        //image data
        if let images = images {
            for (index, image) in images.enumerated() {
                if let imageData = UIImageJPEGRepresentation(image, 1) {
                    requestBody.append("--\(boundaryString)\r\n".data(using: String.Encoding.utf8)!)
                    let timeStamp = String(Int(NSDate.timeIntervalSinceReferenceDate))
                    let content = "Content-Disposition: form-data; " +
                        "name=\"\(imageParameterNames[index])\"; " +
                    "filename=\"image\(timeStamp).jpg\"\r\n"
                    requestBody.append(content.data(using: String.Encoding.utf8)!)
                    requestBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: String.Encoding.utf8)!)
                    requestBody.append(imageData)
                    requestBody.append("\r\n".data(using: String.Encoding.utf8)!)
                }
            }
        }
        requestBody.append("--\(boundaryString)--\r\n".data(using: String.Encoding.utf8)!)

        request.httpBody = requestBody
        
        //content-length
        request.setValue(String(requestBody.count), forHTTPHeaderField: "Content-Length")
        
        runTaskWithRequest(request: request) { (responseData, statusCode) in
            if let handler = handler {
                handler(responseData, statusCode)
            }
        }
    }


    class func uploadArrayOfImages(images: [UIImage]?,
                                   byLink: URL,
                                   withHeaders: [HTTPHeader]? = nil,
                                   otherParameters: [String: Any]? = nil,
                                   handler: ((_ responseData: Data?, _ statusCode: Int) -> ())?) {
        
        //request
        var request = URLRequest(url: byLink)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpShouldHandleCookies = false
        request.timeoutInterval = 30
        
        //headers
        if let headers = withHeaders {
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.field)
            }
        }
        let boundaryString = "<<<abcdefg-----1234567890>>>"
        let contentyType = "multipart/form-data; boundary=" + boundaryString
        request.addValue(contentyType, forHTTPHeaderField: "Content-Type")
        
        //parameters (all mapameters must be strings)
        var requestBody = Data()
        if let parameters = otherParameters {
            for (parameterKey, parameterValue) in parameters {
                let headerData =
                    "--\(boundaryString)\r\n".data(using: String.Encoding.utf8)!
                requestBody.append(headerData)
                let keyString = "Content-Disposition: form-data; name=\"\(parameterKey)\"\r\n\r\n"
                let keyData = keyString.data(using: String.Encoding.utf8)!
                requestBody.append(keyData)
                let parameterData = "\(parameterValue)\r\n".data(using: String.Encoding.utf8)!
                requestBody.append(parameterData)
            }
        }
        
        //images data
        if let images = images {
            let parameterName = "images[][image]"
            for (index, image) in images.enumerated() {
                if let imageData = UIImageJPEGRepresentation(image, 1) {
                    requestBody.append("--\(boundaryString)\r\n".data(using: .utf8)!)
                    let content = "Content-Disposition: form-data; " +
                        "name=\"\(parameterName)\"; " +
                    "filename=\"image\(index).jpg\"\r\n"
                    requestBody.append(content.data(using: .utf8)!)
                    requestBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                    requestBody.append(imageData)
                    requestBody.append("\r\n".data(using: .utf8)!)
                }
            }
        }
        
        requestBody.append("--\(boundaryString)--\r\n".data(using: String.Encoding.utf8)!)
        request.httpBody = requestBody
        
        //content-length
        request.setValue(String(requestBody.count), forHTTPHeaderField: "Content-Length")
        
        runTaskWithRequest(request: request) { (responseData, statusCode) in
            if let handler = handler {
                handler(responseData, statusCode)
            }
        }
    }
    
    class func cancellAllTasks() {
        URLSession.shared.getTasksWithCompletionHandler { (dataTasks,
            uploadTasks, downloadTasks) in
            for task in dataTasks {
                if task.state == .running {
                    task.cancel()
                }
            }
        }
    }
    
    class func downloadFile(from fileURL: URL?,
                            completion handler: @escaping (Data?) -> ()) {
        guard let fileURL = fileURL else {
            DispatchQueue.main.async {
                handler(nil)
            }
            return
        }
        let task = URLSession.shared.dataTask(with: fileURL)
        { (responseData, response, error) in
            DispatchQueue.main.async {
                handler(responseData)
            }
        }
        task.resume()
    }
    
    class func putImage(image: UIImage?,
                           byLink: URL,
                           withHeaders: Array<HTTPHeader>? = nil,
                           imageParameterName: String,
                           otherParameters: Dictionary<String, Any>? = nil,
                           handler: ((_ responseData: Data?, _ statusCode: Int) -> ())?) {
        //request
        var request = URLRequest(url: byLink)
        request.httpMethod = HTTPMethod.PUT.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpShouldHandleCookies = false
        request.timeoutInterval = 30
        
        //headers
        if let headers = withHeaders {
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.field)
            }
        }
        let boundaryString = "<<<abcdefg-----1234567890>>>"
        let contentyType = "multipart/form-data; boundary=" + boundaryString
        request.addValue(contentyType, forHTTPHeaderField: "Content-Type")
        
        //parameters (all mapameters must be strings)
        var requestBody = Data()
        if let parameters = otherParameters {
            for (parameterKey, parameterValue) in parameters {
                let headerData =
                    "--\(boundaryString)\r\n".data(using: String.Encoding.utf8)!
                requestBody.append(headerData)
                let keyString = "Content-Disposition: form-data; name=\"\(parameterKey)\"\r\n\r\n"
                let keyData = keyString.data(using: String.Encoding.utf8)!
                requestBody.append(keyData)
                let parameterData = "\(parameterValue)\r\n".data(using: String.Encoding.utf8)!
                requestBody.append(parameterData)
            }
        }
        
        //image data
        if image != nil,
            let imageData = UIImageJPEGRepresentation(image!, 1) {
            requestBody.append("--\(boundaryString)\r\n".data(using: String.Encoding.utf8)!)
            let timeStamp = String(Int(NSDate.timeIntervalSinceReferenceDate))
            let content = "Content-Disposition: form-data; " +
                "name=\"\(imageParameterName)\"; " +
            "filename=\"image\(timeStamp).jpg\"\r\n"
            requestBody.append(content.data(using: String.Encoding.utf8)!)
            requestBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: String.Encoding.utf8)!)
            requestBody.append(imageData)
            requestBody.append("\r\n".data(using: String.Encoding.utf8)!)
        }
        
        requestBody.append("--\(boundaryString)--\r\n".data(using: String.Encoding.utf8)!)
        request.httpBody = requestBody
        
        //content-length
        request.setValue(String(requestBody.count), forHTTPHeaderField: "Content-Length")
        
        runTaskWithRequest(request: request) { (responseData, statusCode) in
            if let handler = handler {
                handler(responseData, statusCode)
            }
        }
    }
}













//
//  NetworkManager.swift
//  Test
//
//  Created by George Vu on 10/20/24.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = HTTPCookieStorage.shared
        config.httpCookieAcceptPolicy = .always

        session = URLSession(configuration: config)
    }
    
    func postRequest(url: URL, body: [String: Any], completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(nil, nil, NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to encode JSON"]))
            return
        }
        request.httpBody = jsonData

        if let cookies = HTTPCookieStorage.shared.cookies {
            print("Cookies before request: \(cookies)")
        }

        let task = session.dataTask(with: request) { data, response, error in
            if let cookies = HTTPCookieStorage.shared.cookies {
                print("Cookies after request: \(cookies)")
            }
            completion(data, response, error)
        }
        
        task.resume()
    }
    
    func getRequest(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let request = URLRequest(url: url)

        let task = session.dataTask(with: request) { data, response, error in
            completion(data, response, error)
        }
        
        task.resume()
    }
}


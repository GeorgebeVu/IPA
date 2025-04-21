//
//  Authentication.swift
//  IntelliSync
//
//  Created by George Vu on 10/8/24.
//

import Foundation

class Authentication {
    static let shared = Authentication()
    
    var sessionCookie: HTTPCookie?

    // MARK: - Register User
    func register(username: String, email: String, password: String, completion: @escaping (String?, Error?) -> Void) {
        let url = URL(string: "https://ipav1-fbbeaghfd6eyeehf.westus-01.azurewebsites.net/register/")!
        let body: [String: Any] = ["username": username, "email": email, "password": password]
        
        NetworkManager.shared.postRequest(url: url, body: body) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = data else {
                completion(nil, nil)
                return
            }
            let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: [])
            if let jsonDict = jsonResponse as? [String: Any], let message = jsonDict["message"] {
                completion(message as? String, nil)
            } else {
                completion(nil, NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"]))
            }
        }
    }

    // MARK: - Login User
    func login(username: String, password: String, completion: @escaping (String?, Error?) -> Void) {
        let url = URL(string: "https://ipav1-fbbeaghfd6eyeehf.westus-01.azurewebsites.net/login/")!
        let body: [String: Any] = ["username": username, "password": password]
        
        NetworkManager.shared.postRequest(url: url, body: body) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                completion(nil, NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                return
            }

            if let fields = httpResponse.allHeaderFields as? [String: String] {
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)
                for cookie in cookies {
                    if cookie.name == "sessionid" {
                        self.sessionCookie = cookie
                        print("Session cookie saved: \(cookie)")
                        break
                    }
                }
            }

            let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: [])
            if let jsonDict = jsonResponse as? [String: Any], let message = jsonDict["message"] {
                completion(message as? String, nil)
            } else {
                completion(nil, NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Incorrect Login"]))
            }
        }
    }

    // MARK: - Logout User
    func logout(completion: @escaping (String?, Error?) -> Void) {
        let url = URL(string: "https://ipav1-fbbeaghfd6eyeehf.westus-01.azurewebsites.net/logout/")!
        
        NetworkManager.shared.postRequest(url: url, body: [:]) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = data else {
                completion(nil, nil)
                return
            }
            let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: [])
            if let jsonDict = jsonResponse as? [String: Any], let message = jsonDict["message"] {
                completion(message as? String, nil)
            } else {
                completion(nil, NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"]))
            }
        }
    }
}

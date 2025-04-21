//
//  LocationDataManager.swift
//  Test
//
//  Created by George Vu on 10/19/24.
//

import Foundation

class LocationDataManager {
    let apiURL = "https://ipav1-fbbeaghfd6eyeehf.westus-01.azurewebsites.net/save-location/"
    
    func sendLocationData(location: LocationData, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: apiURL) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let locationData: [String] = [location.state, location.city]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: locationData, options: [])
            request.httpBody = jsonData
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Sending JSON: \(jsonString)")
            }
        } catch {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Error encoding JSON"])))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode)"])))
                return
            }
            
            if let data = data, let resultString = String(data: data, encoding: .utf8) {
                completion(.success(resultString))
            } else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
            }
        }.resume()
    }
}

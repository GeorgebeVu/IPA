//
//  TaskDataManager.swift
//  IntelliSync
//
//  Created by George Vu on 10/8/24.
//

import Foundation

class TaskDataManager {
    static let shared = TaskDataManager()
    
    // MARK: - Create Task
    func createTask(taskInfo: TaskData, completion: @escaping (String?, Error?) -> Void) {
        let url = URL(string: "https://ipav1-fbbeaghfd6eyeehf.westus-01.azurewebsites.net/create-task/")!
        var taskInfoArray: [Any] = [
            taskInfo.textInput,            taskInfo.isCompleted
        ]
        
        if let date = taskInfo.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            taskInfoArray.append(dateFormatter.string(from: date))
        } else {
            taskInfoArray.append(NSNull())
        }
        
        if let time = taskInfo.time {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            taskInfoArray.append(timeFormatter.string(from: time))
        } else {
            taskInfoArray.append(NSNull())
        }
        
        let body: [String: Any] = ["task_info": taskInfoArray]
        
        NetworkManager.shared.postRequest(url: url, body: body) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = data else {
                completion(nil, NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let message = json?["message"] as? String {
                completion(message, nil)
            } else {
                completion(nil, NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"]))
            }
        }
    }

    // MARK: - Fetch Tasks
    func fetchTasks(completion: @escaping ([TaskData]?, Error?) -> Void) {
            guard let url = URL(string: "https://ipav1-fbbeaghfd6eyeehf.westus-01.azurewebsites.net/list-task/") else {
                completion(nil, NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error fetching tasks: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }

                guard let data = data else {
                    print("No data received from API")
                    completion(nil, NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                    return
                }

                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    guard let tasksArray = json?["tasks"] as? [[String: Any]] else {
                        print("Invalid data format: \(String(describing: json))")
                        completion(nil, NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"]))
                        return
                    }

                    let tasks = tasksArray.compactMap { dict -> TaskData? in
                        guard let id = dict["id"] as? Int,
                              let description = dict["task_description"] as? String,
                              let isComplete = dict["is_complete"] as? Bool else {
                            print("Missing mandatory fields in task data")
                            return nil
                        }

                        let date: Date? = {
                            if let dateString = dict["task_date"] as? String {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "MMM dd, yyyy"
                                return dateFormatter.date(from: dateString)
                            }
                            return nil
                        }()
                        
                        let time: Date? = {
                            if let timeString = dict["task_time"] as? String {
                                let timeFormatter = DateFormatter()
                                timeFormatter.dateFormat = "h:mm a"
                                return timeFormatter.date(from: timeString)
                            }
                            return nil
                        }()

                        return TaskData(
                            id: id,
                            textInput: description,
                            isCompleted: isComplete,
                            date: date,
                            time: time
                        )
                    }
                    
                    print("Successfully fetched tasks: \(tasks)")
                    completion(tasks, nil)
                } catch {
                    print("Error parsing tasks: \(error.localizedDescription)")
                    completion(nil, error)
                }
            }
            task.resume()
        }
    
    // MARK: - Send Speech to Backend
    func sendSpeechToBackend(speechText: String, completion: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: "https://ipav1-fbbeaghfd6eyeehf.westus-01.azurewebsites.net/process-command/") else {
            completion(nil, NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var cookieHeader = ""
        if let sessionCookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == "sessionid" }) {
            cookieHeader += "sessionid=\(sessionCookie.value);"
            request.setValue(cookieHeader, forHTTPHeaderField: "Cookie")
        } else {
            print("Session cookie (sessionid) not found.")
        }

        if let csrfCookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == "csrftoken" }) {
            request.setValue(csrfCookie.value, forHTTPHeaderField: "X-CSRFToken")
        } else {
            print("CSRF token (csrftoken) not found.")
            completion(nil, NSError(domain: "", code: 403, userInfo: [NSLocalizedDescriptionKey: "CSRF token missing"]))
            return
        }

        let body: [String: Any] = ["command": speechText]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(nil, NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to encode data"]))
            return
        }
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let responseMessage = json?["response"] as? String {
                    completion(responseMessage, nil)
                } else {
                    completion(nil, NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"]))
                }
            } catch {
                completion(nil, error)
            }
        }

        task.resume()
    }
    
    // MARK: UpdateTask
    func updateTask(taskInfo: TaskData, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://ipav1-fbbeaghfd6eyeehf.westus-01.azurewebsites.net/update-task/\(taskInfo.id)/") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"

        let formattedDate = taskInfo.date != nil ? dateFormatter.string(from: taskInfo.date!) : nil
        let formattedTime = taskInfo.time != nil ? timeFormatter.string(from: taskInfo.time!) : nil

        let body: [String: Any?] = [
            "task_description": taskInfo.textInput,
            "task_date": formattedDate,
            "task_time": formattedTime
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to update task:", error)
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    completion(true)
                } else {
                    print("Server error: HTTP \(httpResponse.statusCode)")
                    if let data = data,
                       let errorResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorMessage = errorResponse["error"] as? String {
                        print("Error message from server:", errorMessage)
                    }
                    completion(false)
                }
            } else {
                print("Unexpected response format.")
                completion(false)
            }
        }.resume()
    }
    
    //MARK: markTaskComplete
    func markTaskComplete(taskID: Int, completion: @escaping (Bool) -> Void) {
            guard let url = URL(string: "https://ipav1-fbbeaghfd6eyeehf.westus-01.azurewebsites.net/mark-task/\(taskID)/") else {
                completion(false)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    print("Failed to mark task complete:", error)
                    completion(false)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    completion(true)
                } else {
                    completion(false)
                }
            }.resume()
        }
}

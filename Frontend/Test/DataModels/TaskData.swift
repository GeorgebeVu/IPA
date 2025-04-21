//
//  TaskData.swift
//  Test
//
//  Created by George Vu on 10/4/24.
//

import Foundation

struct TaskData: Identifiable {
    var id = Int()
    var textInput: String = ""
    var isCompleted: Bool
    var date: Date?
    var time: Date?
}

struct SpeechData: Identifiable {
    var id = Int()
    var speechInput: String = ""
}

struct TaskIndexWrapper: Identifiable {
    let id: Int
}

//
//  Input.swift
//  Test
//
//  Created by George Vu on 10/3/24.
//

import SwiftUI

struct Input: View {
    @State var input: String = ""
    @State var prompt: Bool = false
    @Binding var tasks: [TaskData]
    var fetchTasks: () -> Void

    @State private var selectedDate: Date? = nil
    @State private var selectedTime: Date? = nil
    @State private var dateAndTimeSelected = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            VStack {
                TextField("Enter task here...", text: $input)
                    .padding()

                Spacer()

                HStack {
                    Button {
                        prompt.toggle()
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundColor(dateAndTimeSelected ? .blue : .gray)
                            .font(.system(size: 34))
                    }

                    if dateAndTimeSelected {
                        Text("\(formattedDate(selectedDate)) \(formattedTime(selectedTime))")
                            .foregroundColor(.blue)
                        Button(action: {
                            selectedDate = nil
                            selectedTime = nil
                            dateAndTimeSelected = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }

                    Spacer()

                    Button {
                        createTask()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 36))                    }
                }
                .padding(.horizontal, 30)
            }
        }
        .sheet(isPresented: $prompt) {
            CalendarPickerView(selectedDate: $selectedDate, selectedTime: $selectedTime) {
                dateAndTimeSelected = true
            }
            .presentationDetents([.fraction(0.70)])
        }
    }

    func createTask() {
        guard !input.isEmpty else { return }
        
        let newTask = TaskData(
            textInput: input,
            isCompleted: false,
            date: selectedDate,
            time: selectedTime
        )
        
        TaskDataManager.shared.createTask(taskInfo: newTask) { message, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                print(message ?? "Task created successfully")
                fetchTasks()
            }
        }
        
        input = ""
    }

    func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "No Date Selected" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }

    func formattedTime(_ time: Date?) -> String {
        guard let time = time else { return "No Time Selected" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: time)
    }
}

struct Input_Previews: PreviewProvider {
    static var previews: some View {
        Input(
            tasks: .constant([
                TaskData(id: 1, textInput: "Sample Task 1", isCompleted: false, date: nil, time: nil),
                TaskData(id: 2, textInput: "Sample Task 2", isCompleted: false, date: Date(), time: nil)
            ]),
            fetchTasks: {}
        )
    }
}

//
//  EditTaskView.swift
//  Test
//
//  Created by George Vu on 10/31/24.
//

import SwiftUI

struct EditTaskView: View {
    @Binding var task: TaskData
    @State private var updatedText: String
    @State private var selectedDate: Date?
    @State private var selectedTime: Date?
    @State private var dateAndTimeSelected = false
    @State private var showCalendarPicker = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss

    var onSave: (TaskData) -> Void

    init(task: Binding<TaskData>, onSave: @escaping (TaskData) -> Void) {
        _task = task
        _updatedText = State(initialValue: task.wrappedValue.textInput)
        _selectedDate = State(initialValue: task.wrappedValue.date)
        _selectedTime = State(initialValue: task.wrappedValue.time)
        self.onSave = onSave
    }

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button("Cancel") {
                        dismiss()  
                    }
                    .foregroundColor(.blue)

                    Spacer()

                    Text("Edit Task")
                        .font(.headline)
                    
                    Spacer()
                }
                .padding()

                TextField("Edit task description...", text: $updatedText)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)

                Spacer()

                HStack {
                    Button {
                        showCalendarPicker.toggle()
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
                        saveChanges()
                    } label: {
                        Text("Save Changes")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 30)
            }
        }
        .sheet(isPresented: $showCalendarPicker) {
            CalendarPickerView(selectedDate: $selectedDate, selectedTime: $selectedTime) {
                dateAndTimeSelected = true
            }
            .presentationDetents([.fraction(0.70)])
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            if selectedDate != nil || selectedTime != nil {
                dateAndTimeSelected = true
            }
        }
    }

    func saveChanges() {
        task.textInput = updatedText
        task.date = selectedDate
        task.time = selectedTime
        onSave(task)
        
        TaskDataManager.shared.updateTask(taskInfo: task) { success in
            if success {
                dismiss()
            } else {
                errorMessage = "Failed to update task on backend."
                showError = true
            }
        }
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

#Preview {
    EditTaskView(task: .constant(TaskData(id: 1, textInput: "Sample Task", isCompleted: false, date: Date(), time: Date())), onSave: { _ in })
}

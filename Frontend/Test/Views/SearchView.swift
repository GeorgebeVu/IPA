//
//  SearchView.swift
//  Test
//
//  Created by George Vu on 10/30/24.
//

import SwiftUI

struct SearchView: View {
    @Binding var isPresented: Bool
    @Binding var tasks: [TaskData]
    
    @State private var searchText = ""
    @State private var selectedTask: TaskIndexWrapper?
    @State private var showEditTaskView = false
    @State private var filterDate: Date? = nil
    @State private var showDatePicker = false
    
    var fetchTasks: () -> Void
    
    var filteredTasks: [TaskData] {
        tasks.filter { task in
            let matchesText = searchText.isEmpty || task.textInput.localizedCaseInsensitiveContains(searchText)
            let matchesDate = filterDate == nil || (task.date != nil && Calendar.current.isDate(task.date!, inSameDayAs: filterDate!))
            return matchesText && matchesDate
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Search tasks", text: $searchText)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    
                    Button(action: { showDatePicker.toggle() }) {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                            .font(.system(size: 30))
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                if showDatePicker {
                    VStack {
                        DatePicker("Select Date", selection: Binding(
                            get: { filterDate ?? Date() },
                            set: { newDate in
                                filterDate = newDate
                                showDatePicker = false
                            }
                        ), displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        Button("Reset Filter") {
                            filterDate = nil
                            showDatePicker = false
                        }
                        .foregroundColor(.blue)
                        .padding(.top, 5)
                    }
                    .padding(.bottom, 8)
                }

                if filteredTasks.isEmpty {
                    Text("No tasks available for the selected date.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(filteredTasks.indices, id: \.self) { index in
                        let task = filteredTasks[index]
                        HStack {
                            Text(task.textInput)
                                .foregroundColor(.white)
                                .onTapGesture {
                                    if let globalIndex = tasks.firstIndex(where: { $0.id == task.id }) {
                                        selectedTask = TaskIndexWrapper(id: globalIndex)
                                    }
                                }
                            Spacer()
                            if let date = task.date {
                                Text(formattedDate(date))
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            if let time = task.time {
                                Text(formattedTime(time))
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                        .listRowBackground(Color.black.opacity(0.8))
                    }
                    .background(Color.black)
                }
                
                Spacer()
            }
            .navigationBarTitle("Search Tasks", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .onAppear {
                fetchTasks()
            }
            .sheet(item: $selectedTask) { wrapper in
                let index = wrapper.id
                if index < tasks.count {
                    EditTaskView(
                        task: $tasks[index],
                        onSave: { updatedTask in
                            fetchTasks()
                        }
                    )
                    .presentationDetents([.fraction(0.70)])
                }
            }
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }

    func formattedTime(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: time)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(isPresented: .constant(true), tasks: .constant([
            TaskData(id: 1, textInput: "Task 1", isCompleted: false, date: Date(), time: Date()),
            TaskData(id: 2, textInput: "Task 2", isCompleted: true, date: Date(), time: nil)
        ]), fetchTasks: {})
    }
}

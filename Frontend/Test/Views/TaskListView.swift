//
//  TaskListView.swift
//  Test
//
//  Created by George Vu on 10/3/24.
//

import SwiftUI

struct TaskListView: View {
    @Binding var tasks: [TaskData]
    @State private var taskToEditIndex: TaskIndexWrapper?
    var fetchTasks: () -> Void

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Spacer()
                    Text("Tasks List")
                        .foregroundColor(.white)
                        .font(.title3)
                        .bold()
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)

                VStack(alignment: .leading) {

                    List {
                        if !tasksWithoutDate.isEmpty {
                            Section(header: Text("No Date").foregroundColor(.white)) {
                                ForEach(tasksWithoutDate.indices, id: \.self) { index in
                                    let task = tasksWithoutDate[index]
                                    if let originalIndex = tasks.firstIndex(where: { $0.id == task.id }) {
                                        TaskRow(task: task, taskIndex: originalIndex, fetchTasks: fetchTasks, onSelect: { index in
                                            taskToEditIndex = TaskIndexWrapper(id: index)
                                        })
                                    }
                                }
                            }
                        }

                        ForEach(sortedGroupedTasksByDate.keys.sorted(), id: \.self) { date in
                            Section(header: Text(formattedDate(date)).foregroundColor(.white)) {
                                ForEach(sortedGroupedTasksByDate[date] ?? [], id: \.id) { task in
                                    if let originalIndex = tasks.firstIndex(where: { $0.id == task.id }) {
                                        TaskRow(task: task, taskIndex: originalIndex, fetchTasks: fetchTasks, onSelect: { index in
                                            taskToEditIndex = TaskIndexWrapper(id: index)
                                        })
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .background(Color.black)
                }
                .background(Color.black)
                Spacer()
            }
        }
        .sheet(item: $taskToEditIndex, onDismiss: {
            taskToEditIndex = nil
        }) { wrapper in
            let index = wrapper.id
            if index < tasks.count {
                EditTaskView(
                    task: $tasks[index],
                    onSave: { updatedTask in
                        TaskDataManager.shared.updateTask(taskInfo: updatedTask) { success in
                            if success {
                                fetchTasks()
                            } else {
                                print("Failed to update task on backend.")
                            }
                        }
                    }
                )
                .presentationDetents([.fraction(0.70)])
            }
        }
    }

    private var tasksWithoutDate: [TaskData] {
        tasks.filter { $0.date == nil }
    }

    private var sortedGroupedTasksByDate: [Date: [TaskData]] {
        let tasksWithDate = tasks.filter { $0.date != nil }
        let sortedTasks = tasksWithDate.sorted {
            if $0.date == $1.date {
                return ($0.time ?? Date.distantFuture) < ($1.time ?? Date.distantFuture)
            }
            return $0.date! < $1.date!
        }
        return Dictionary(grouping: sortedTasks, by: { $0.date! })
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
}

struct TaskRow: View {
    let task: TaskData
    let taskIndex: Int
    var fetchTasks: () -> Void
    var onSelect: (Int) -> Void
    
    @State private var isFilling = false

    var body: some View {
        HStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isFilling = true
                }
                TaskDataManager.shared.markTaskComplete(taskID: task.id) { success in
                    if success {
                        fetchTasks()
                    } else {
                        print("Failed to mark task as complete.")
                    }
                }
            }) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.green)
                    .opacity(isFilling || task.isCompleted ? 1 : 0)
                    .frame(width: 24, height: 24)
                
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold))
                    }
                }
            }

            Text(task.textInput)
                .foregroundColor(.white)
                .onTapGesture {
                    onSelect(taskIndex)
                }

            Spacer()

            if let time = task.time {
                Text(formattedTime(time))
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .listRowBackground(Color.gray.opacity(0.2))
    }

    func formattedTime(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: time)
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView(tasks: .constant([
            TaskData(id: 1, textInput: "Sample Task 1", isCompleted: false, date: nil, time: nil),
            TaskData(id: 2, textInput: "Sample Task 2", isCompleted: false, date: Date(), time: nil),
            TaskData(id: 3, textInput: "Sample Task 3", isCompleted: false, date: Date(), time: Date())
        ]), fetchTasks: {})
    }
}

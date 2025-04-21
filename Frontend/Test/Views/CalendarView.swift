//
//  CalendarView.swift
//  Test
//
//  Created by George Vu on 10/2/24.
//

import SwiftUI

struct CalendarView: View {
    @Binding var tasks: [TaskData]
    @Binding var refreshID: Int
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Spacer()
                        Text("Calendar")
                            .foregroundColor(.white)
                            .font(.title3)
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    VStack {
                        HStack {
                            Button(action: {
                                currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            
                            Spacer()
                            
                            Text(dateFormatter.string(from: currentDate))
                                .foregroundColor(.white)
                                .font(.title3)
                                .bold()
                            
                            Spacer()
                            
                            Button(action: {
                                currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                            }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                                Text(weekday)
                                    .frame(maxWidth: .infinity)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
                                let days = generateDays(for: currentDate)
                                
                                ForEach(days, id: \.self) { day in
                                    if let day = day {
                                        let hasTask = tasksForDate(day).count > 0
                                        DayView(day: day, isSelected: calendar.isDate(day, inSameDayAs: selectedDate ?? Date()), hasTask: hasTask) {
                                            selectedDate = day
                                        }
                                    } else {
                                        Color.clear.frame(width: 44, height: 44)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: geometry.size.height * 0.43)
                    }
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    Spacer()
                    
                    if let selectedDate = selectedDate {
                        VStack {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 10) {
                                    Spacer()
                                    if tasksForDate(selectedDate).isEmpty {
                                        Text("No tasks")
                                            .foregroundColor(.gray)
                                            .padding()
                                    } else {
                                        ForEach(tasksForDate(selectedDate)) { task in
                                            TaskTimelineItem(task: task)
                                                .padding(.horizontal)
                                        }
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal, 10)
                        }
                    } else {
                        Text("Select A Date")
                            .foregroundColor(Color.gray.opacity(0.6))
                    }
                    Spacer()
                }
            }
        }
    }

    func generateDays(for month: Date) -> [Date?] {
        var days: [Date?] = []
        
        let range = calendar.range(of: .day, in: .month, for: month)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        for _ in 0..<firstWeekday {
            days.append(nil)
        }
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
    
    func tasksForDate(_ date: Date) -> [TaskData] {
        return tasks.filter { task in
            guard let taskDate = task.date else { return false }
            return calendar.isDate(taskDate, inSameDayAs: date)
        }
    }
}

struct DayView: View {
    var day: Date
    var isSelected: Bool
    var hasTask: Bool
    var action: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text("\(calendar.component(.day, from: day))")
                    .font(.body)
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(isSelected ? Color.blue : Color.clear)
                    .foregroundColor(isSelected ? .white : .white)
                    .clipShape(Circle())
                
                if hasTask {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                        .padding(.top, -5)
                }
            }
        }
    }
}

struct TaskTimelineItem: View {
    var task: TaskData
    var body: some View {
        HStack {
            Circle()
                .fill(Color.green)
                .frame(width: 10, height: 10)
                .padding(.top, 10)
            
            VStack {
                Text(task.textInput)
                    .font(.headline)
                    .foregroundColor(.white)
                
                if let time = task.time {
                    Text("Time: \(formattedTime(time))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }

    func formattedTime(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: time)
    }
}


struct CalendarView_Previews: PreviewProvider {
    @State static var sampleTasks = [
        TaskData(textInput: "Meeting with team", isCompleted: false, date: Date(), time: Date().addingTimeInterval(3600)),
        TaskData(textInput: "Doctor's appointment", isCompleted: false, date: Calendar.current.date(byAdding: .day, value: 2, to: Date()),  time: Date().addingTimeInterval(7200)),
        TaskData(textInput: "Workout session", isCompleted: false, date: Calendar.current.date(byAdding: .day, value: 3, to: Date()))
    ]
    
    @State static var refreshID = 0
    
    static var previews: some View {
        CalendarView(tasks: $sampleTasks, refreshID: $refreshID)
            .preferredColorScheme(.dark)
    }
}

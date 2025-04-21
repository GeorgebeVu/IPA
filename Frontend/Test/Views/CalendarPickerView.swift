//
//  CalendarPickerView.swift
//  Test
//
//  Created by George Vu on 10/4/24.
//

import SwiftUI

struct CalendarPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date?
    @Binding var selectedTime: Date?
    @State private var isTimePickerVisible = false
    var onSave: () -> Void

    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.blue)
                }
                
                Spacer()
                
                Button {
                    if selectedDate == nil {
                        selectedDate = Date()
                    }
                    onSave()
                    dismiss()
                } label: {
                    Text("Done")
                        .foregroundStyle(.blue)
                }
            }
            .padding()

            DatePicker(
                "Select Date",
                selection: Binding(
                    get: { selectedDate ?? Date() },
                    set: { newDate in selectedDate = newDate }
                ),
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()

            if !isTimePickerVisible {
                Button {
                    withAnimation {
                        isTimePickerVisible = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "clock")
                        Text(selectedTime != nil ? "Change Time" : "Select Time")
                    }
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }

            if isTimePickerVisible {
                HStack {
                    DatePicker(
                        "Select Time",
                        selection: Binding(
                            get: { selectedTime ?? Date() },
                            set: { newTime in selectedTime = newTime }
                        ),
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .padding()

                    Spacer()

                    Button {
                        withAnimation {
                            isTimePickerVisible = false
                            selectedTime = nil
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .padding(.trailing)
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
    }
}

#Preview {
    CalendarPickerView(selectedDate: .constant(nil), selectedTime: .constant(nil), onSave: {})
}

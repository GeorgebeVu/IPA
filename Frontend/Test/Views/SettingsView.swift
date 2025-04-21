//
//  SettingsView.swift
//  Test
//
//  Created by George Vu on 10/8/24.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isLoggedIn: Bool
    @Environment(\.dismiss) var dismiss
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoggingOut = false
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.title3)
                .foregroundColor(.white)
                .bold()
            
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                }
                Spacer()
            }
            .background(Color.black)
            
            Spacer()
            
            List {
                Section(header: Text("General").foregroundColor(.white)) {
                    Button(action: {
                        LogoutUser()  
                    }) {
                        HStack {
                            Text("Logout")
                                .font(.title3)
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.2))
                }
            }
            .listStyle(InsetGroupedListStyle())
            .background(Color.black.edgesIgnoringSafeArea(.all))
            
            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showError) {
            Alert(title: Text("Logout Failed"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
        .overlay {
            if isLoggingOut {
                ProgressView("Logging out...").foregroundColor(.white)
            }
        }
    }
    
    func LogoutUser() {
        isLoggingOut = true

        Authentication.shared.logout { message, error in
            DispatchQueue.main.async {
                isLoggingOut = false

                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                } else if let message = message {
                    print("Logout successful: \(message)")
                    dismiss()
                    withAnimation {
                        isLoggedIn = false
                        print(isLoggedIn)
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isLoggedIn: .constant(true))
            .preferredColorScheme(.dark)
    }
}

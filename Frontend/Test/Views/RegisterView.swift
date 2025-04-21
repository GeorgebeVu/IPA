//
//  RegisterView.swift
//  Test
//
//  Created by George Vu on 10/15/24.
//

import SwiftUI

struct RegisterView: View {
    @Binding var isPresented: Bool
    @Binding var alertMessage: String
    @Binding var showAlert: Bool
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .foregroundColor(.blue)
                }
                .padding()
                Spacer()
            }
            
            Text("Create Account")
                .font(.largeTitle)
                .padding(.top, 40)
            
            VStack(spacing: 16) {
                TextField("Username", text: $username)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(10)
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(10)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 30)
            
            Button(action: {
                registerUser()
            }) {
                Text("Register")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .padding(.horizontal, 30)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Registration Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func registerUser() {
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            alertMessage = "All fields are required."
            showAlert = true
            return
        }

        Authentication.shared.register(username: username, email: email, password: password) { message, error in
            DispatchQueue.main.async {
                if let error = error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                } else if let message = message {
                    if message == "User registered successfully!" {
                        alertMessage = message
                        showAlert = true
                        isPresented = false
                    } else {
                        alertMessage = message
                        showAlert = true
                    }
                } else {
                    alertMessage = "Unexpected error occurred."
                    showAlert = true
                }
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(isPresented: .constant(false), alertMessage: .constant(""), showAlert: .constant(false))
    }
}

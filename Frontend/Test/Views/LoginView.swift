//
//  LoginView.swift
//  Test
//
//  Created by George Vu on 10/1/24.
//

import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var usertextfield = ""
    @State private var passtextfield = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showRegisterView = false
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            Circle()
                .fill(Color.blue.opacity(0.8))
                .frame(width: 300, height: 300)
                .offset(x: -150, y: -250)
            
            Circle()
                .fill(Color.green.opacity(0.7))
                .frame(width: 300, height: 300)
                .offset(x: 100, y: 200)
            
            Circle()
                .fill(Color.red.opacity(0.6))
                .frame(width: 200, height: 200)
                .offset(x: -150, y: 400)
            
            VStack(spacing: 20) {
                Image(systemName: "rectangle.split.3x3.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                Text("Hello!")
                    .font(.largeTitle)
                Text("Welcome Back")
                    .font(.title3)
                
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "person.fill")
                        TextField("Username", text: $usertextfield)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(10)
                    
                    HStack {
                        Image(systemName: "lock.fill")
                        SecureField("Password", text: $passtextfield)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button(action: {
                    loginUser(username: usertextfield, password: passtextfield)
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Log In")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(isLoading)
                .padding(.top, 10)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Login Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                Button(action: {
                    showRegisterView.toggle()
                }) {
                    Text("Don't have an account? Register")
                        .foregroundColor(.white)
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 30)
            .fullScreenCover(isPresented: $showRegisterView) {
                RegisterView(isPresented: $showRegisterView, alertMessage: $alertMessage, showAlert: $showAlert)
            }
        }
    }
    
    func loginUser(username: String, password: String) {
        isLoading = true
        Authentication.shared.login(username: username, password: password) { message, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                } else if let message = message {
                    if message == "Login successful!" {
                        if let sessionCookie = Authentication.shared.sessionCookie {
                            UserDefaults.standard.set(sessionCookie.value, forKey: "sessionCookie")
                            withAnimation {
                                isLoggedIn = true
                            }
                        }
                    } else {
                        alertMessage = message
                        showAlert = true
                    }
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoggedIn: .constant(false))
    }
}

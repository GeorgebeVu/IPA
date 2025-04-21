//
//  MainView.swift
//  Test
//
//  Created by George Vu on 10/3/24.
//

import SwiftUI
import Combine

struct MainView: View {
    @Binding var isLoggedIn: Bool

    @State var prompt: Bool = false
    @State var view: Int = 0
    @State var taskmanager: [TaskData] = []
    @State var isLoading: Bool = true
    @State var showError = false
    @State var errorMessage = ""
    @State var isMenuOpen = false
    @State var showSettings = false
    @State var showMicOverlay = false
    @State private var recognizedSpeech = ""
    
    @State private var refreshID: Int = 0
    @State private var showSearchView = false

    @StateObject private var speechRecognizerManager = SpeechRecognizerManager()
    @StateObject private var locationManager = LocationManager()
    
    private let locationDataManager = LocationDataManager()
    @State private var cancellable: AnyCancellable?

    var body: some View {
        ZStack {
            VStack {
                if isLoading {
                    ProgressView("Loading tasks...")
                        .foregroundColor(.white)
                        .onAppear {
                            fetchTasks()
                            locationManager.requestLocationAccess()
                        }
                } else {
                    VStack {
                        if view == 0 {
                            TaskListView(tasks: $taskmanager, fetchTasks: fetchTasks)
                        } else if view == 1 {
                            CalendarView(tasks: $taskmanager, refreshID: $refreshID)
                        }

                        Spacer()

                        ZStack {
                            Circle()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .top, endPoint: .bottom))
                                .frame(width: 70, height: 70)

                            Image(systemName: "plus")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                        .padding(.bottom, 10)
                        .gesture(
                            LongPressGesture(minimumDuration: 0.5)
                                .onEnded { _ in
                                    withAnimation {
                                        showMicOverlay = true
                                        speechRecognizerManager.startRecording()
                                    }
                                }
                        )
                        .onTapGesture {
                            prompt.toggle()
                        }

                        HStack {
                            BottomNavButton(imageName: "list.bullet.rectangle", color: (view == 0) ? .purple : .white) {
                                view = 0
                            }
                            Spacer()
                            BottomNavButton(imageName: "calendar", color: (view == 1) ? .purple : .white) {
                                view = 1
                            }
                        }
                        .padding(.horizontal)
                        .frame(height: 50)
                        .background(Color.black)
                    }
                }
            }
            .disabled(isMenuOpen)

            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            isMenuOpen.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showSearchView = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }

            if isMenuOpen {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                withAnimation {
                                    isMenuOpen = false
                                }
                            }

                        HamburgerMenuView(showSettings: $showSettings)
                            .frame(width: geometry.size.width * 0.75, alignment: .leading)
                            .background(Color.black)
                            .transition(.move(edge: .leading))
                            .zIndex(1)
                    }
                }
            }

            if showMicOverlay {
                MicOverlayView(
                    showMicOverlay: $showMicOverlay,
                    speechRecognizerManager: speechRecognizerManager,
                    recognizedSpeech: $recognizedSpeech,
                    onBackendResponse: { fetchTasks() }
                )
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .sheet(isPresented: $prompt) {
            Input(tasks: $taskmanager, fetchTasks: fetchTasks)
                .presentationDetents([.fraction(0.70)])
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView(isLoggedIn: $isLoggedIn)
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $showSearchView) {
            SearchView(isPresented: $showSearchView, tasks: $taskmanager, fetchTasks: fetchTasks)
        }
        .onAppear {
            locationManager.requestLocationAccess()
            setupLocationCancellable()
        }
        .onDisappear {
            cancellable?.cancel()
        }
    }

    private func fetchTasks() {
        TaskDataManager.shared.fetchTasks { tasks, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                } else if let tasks = tasks {
                    self.taskmanager = tasks
                    refreshID += 1
                }
            }
        }
    }

    private func sendLocationToBackend() {
        let location = locationManager.userLocation
        print("Sending location: city = \(location.city), state = \(location.state)")
        locationDataManager.sendLocationData(location: location) { result in
            switch result {
            case .success(let response):
                print("Location sent successfully: \(response)")
            case .failure(let error):
                print("Failed to send location: \(error.localizedDescription)")
            }
        }
    }

    private func setupLocationCancellable() {
        cancellable = locationManager.$userLocation
            .receive(on: DispatchQueue.main)
            .sink { newLocation in
                if !newLocation.city.isEmpty && !newLocation.state.isEmpty {
                    sendLocationToBackend()
                }
            }
    }
}

struct BottomNavButton: View {
    let imageName: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(color)
                .padding()
        }
    }
}

#Preview {
    MainView(isLoggedIn: .constant(true))
}

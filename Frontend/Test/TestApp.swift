//
//  TestApp.swift
//  Test
//
//  Created by George Vu on 9/26/24.
//

import SwiftUI
import AVFoundation

@main
struct TestApp: App {
    @StateObject private var speechRecognizerManager = SpeechRecognizerManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .onAppear {
                    speechRecognizerManager.requestSpeechAuthorization()
                }
                .environmentObject(speechRecognizerManager)
        }
    }
}

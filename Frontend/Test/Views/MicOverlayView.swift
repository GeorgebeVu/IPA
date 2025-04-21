//
//  MicOverlayView.swift
//  Test
//
//  Created by George Vu on 10/15/24.
//

import SwiftUI

struct MicOverlayView: View {
    @Binding var showMicOverlay: Bool
    @ObservedObject var speechRecognizerManager: SpeechRecognizerManager
    @Binding var recognizedSpeech: String
    @State private var backendResponse: String = ""
    @State private var isSendingRequest = false
    
    var onBackendResponse: (() -> Void)?

    var body: some View {
        if showMicOverlay {
            ZStack {
                Color.black.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                showMicOverlay = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(.trailing, 20)
                                .padding(.top, 10)
                        }
                    }

                    Spacer()

                    Text("Speak Now")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)

                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.2))
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                        Text(speechRecognizerManager.recognizedText.isEmpty ? "Listening..." : speechRecognizerManager.recognizedText)
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .padding(.horizontal, 20)

                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.2))
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                        Text(backendResponse.isEmpty ? "Waiting for response..." : backendResponse)
                            .font(.body)
                            .foregroundColor(backendResponse.starts(with: "Error") ? .red : .white)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .padding(.horizontal, 20)

                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.blue]),
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                            .frame(width: 120, height: 120)

                        Image(systemName: "mic.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 20)

                    Button(action: {
                        withAnimation {
                            speechRecognizerManager.stopRecording()
                            recognizedSpeech = speechRecognizerManager.recognizedText
                            
                            isSendingRequest = true
                            backendResponse = "Sending..."
                            
                            TaskDataManager.shared.sendSpeechToBackend(speechText: recognizedSpeech) { message, error in
                                DispatchQueue.main.async {
                                    isSendingRequest = false
                                    if let message = message {
                                        backendResponse = message
                                        onBackendResponse?()
                                    } else if let error = error {
                                        backendResponse = "Error: \(error.localizedDescription)"
                                    }
                                }
                            }
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text(isSendingRequest ? "Sending..." : "Stop Recording")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(isSendingRequest ? Color.gray : Color.red)
                        .cornerRadius(15)
                        .padding(.horizontal, 40)
                    }
                    .disabled(isSendingRequest)

                    Spacer()
                }
                .padding(.top, 40)
            }
        }
    }
}

#Preview {
    MicOverlayView(showMicOverlay: .constant(true), speechRecognizerManager: SpeechRecognizerManager(), recognizedSpeech: .constant(""))
}

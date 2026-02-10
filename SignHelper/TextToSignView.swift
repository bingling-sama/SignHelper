//
//  TextToSignView.swift
//  SignHelper
//
//  Created by Lucas Liu on 2026/1/20.
//

import SwiftUI

struct TextToSignView: View {
    @State private var inputText = ""
    @State private var showResult = false
    @State private var signImages: [String] = [] // Stores system image names for demo

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Text to Sign")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            
            // Input Area
            VStack(spacing: 15) {
                HStack {
                    TextField("Enter text (e.g., Hello)", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                        .padding(.leading, 5)
                    
                    if !inputText.isEmpty {
                        Button(action: {
                            inputText = ""
                            showResult = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal)
                
                Button(action: {
                    // Simulate voice input
                    inputText = "Hello World"
                    translateToSign()
                }) {
                    HStack {
                        Image(systemName: "mic.fill")
                        Text("Voice Input")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            
            Button(action: {
                translateToSign()
                // Dismiss keyboard
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }) {
                Text("Translate")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(inputText.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .disabled(inputText.isEmpty)
            
            Divider()
                .padding(.vertical, 10)
            
            // Output Area
            ScrollView {
                if showResult {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Result:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        // Display sign language visualization (using symbols for demo)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                            ForEach(Array(inputText.uppercased().enumerated()), id: \.offset) { index, char in
                                if char.isLetter {
                                    VStack {
                                        // In a real app, use actual sign language images here
                                        // E.g., Image("sign_\(char)")
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.orange.opacity(0.15))
                                                .frame(width: 70, height: 70)
                                            
                                            Image(systemName: "hand.raised.fill") // Placeholder
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.orange)
                                        }
                                        
                                        Text(String(char))
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    .transition(.opacity)
                } else {
                    // Empty State
                    VStack(spacing: 15) {
                        Image(systemName: "hand.wave")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("Enter text to see sign language spelling")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                }
            }
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    private func translateToSign() {
        guard !inputText.isEmpty else { return }
        withAnimation {
            showResult = true
        }
    }
}
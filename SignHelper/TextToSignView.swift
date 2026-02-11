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
    @State private var matchedSigns: [SignItem] = []
    
    private let demoPhrases: [String] = [
        "hello",
        "thank you",
        "help",
        "dog",
        "tree",
        "happy",
        "hospital"
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Compact header: title + input + translate
            VStack(spacing: 12) {
                HStack {
                    Text("Text to Sign")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                HStack(spacing: 10) {
                    HStack(spacing: 8) {
                        TextField("Enter text...", text: $inputText)
                            .textFieldStyle(.plain)
                            .font(.body)
                        
                        if !inputText.isEmpty {
                            Button(action: {
                                inputText = ""
                                matchedSigns = []
                                showResult = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    
                    Button(action: {
                        translateToSign()
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }) {
                        Text("Translate")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(inputText.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(inputText.isEmpty)
                }
                
                // Compact demo chips - single row, no label
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(demoPhrases, id: \.self) { phrase in
                            Button(action: {
                                inputText = phrase
                                translateToSign()
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }) {
                                Text(phrase)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(UIColor.tertiarySystemFill))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            // Output Area
            ScrollView {
                if showResult {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Result")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        if matchedSigns.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 44))
                                    .foregroundColor(.secondary.opacity(0.6))
                                Text("No matching signs found")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 20) {
                                ForEach(matchedSigns) { sign in
                                    SignResultCard(sign: sign)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .transition(.opacity)
                } else {
                    // Empty State
                    VStack(spacing: 16) {
                        Image(systemName: "hand.wave.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.6), Color.orange.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("Enter text to see sign language")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        Text("Try: hello, help, dog, thank you")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 56)
                }
            }
            
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - Sign Result Card
private struct SignResultCard: View {
    let sign: SignItem
    
    private let fallbackIconSize: CGFloat = 56
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Demo image - large and prominent
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.tertiarySystemFill))
                    .frame(height: 200)
                
                if let demoName = sign.demoImageName,
                   UIImage(named: demoName) != nil {
                    Image(demoName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 260, maxHeight: 180)
                } else {
                    Image(systemName: sign.imageName)
                        .font(.system(size: fallbackIconSize))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .orange.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(sign.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(sign.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Private
private extension TextToSignView {
    func translateToSign() {
        guard !inputText.isEmpty else { return }
        
        let allSigns = SignDataManager.shared.getAllSigns()
        let trimmedText = inputText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        var collected: [SignItem] = []
        if let phraseMatch = allSigns.first(where: { sign in
            sign.title.lowercased() == trimmedText || sign.id.lowercased() == trimmedText.replacingOccurrences(of: " ", with: "_")
        }) {
            collected.append(phraseMatch)
        }
        
        let words = inputText
            .lowercased()
            .split { $0.isWhitespace || $0.isPunctuation }
            .map(String.init)
        
        let wordMatches = words.compactMap { word in
            allSigns.first { sign in
                sign.title.lowercased() == word || sign.id.lowercased() == word
            }
        }
        
        var seen = Set<String>()
        matchedSigns = (collected + wordMatches).filter { sign in
            if seen.contains(sign.id) { return false }
            seen.insert(sign.id)
            return true
        }
        
        withAnimation { showResult = true }
    }
}
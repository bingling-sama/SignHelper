import SwiftUI

struct TranslationView: View {
    @StateObject private var recognizer = SignLanguageRecognizer()
    @State private var isRecording = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Real-time Translation")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                if isRecording && !recognizer.translatedSentence.isEmpty {
                    Button(action: {
                        recognizer.clearSentence()
                    }) {
                        Image(systemName: "trash.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            // Camera Preview
            ZStack {
                CameraView(recognizer: recognizer)
                    .frame(width: 280, height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isRecording ? Color.green.opacity(0.6) : Color.secondary.opacity(0.4),
                                lineWidth: isRecording ? 3 : 2
                            )
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 12)
                
                if !isRecording {
                    VStack(spacing: 8) {
                        Image(systemName: "hand.wave.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.9))
                        Text("Tap Start to translate sign language")
                            .font(.caption)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(16)
                } else {
                    // Live indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Live")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(16)
                }
            }
            
            // Real-time Translation Output
            if isRecording {
                VStack(alignment: .leading, spacing: 12) {
                    // Current gesture being detected
                    HStack {
                        Text("Detecting:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(recognizer.currentGesture)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Divider()
                    
                    // Accumulated translation
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Translation:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(recognizer.translatedSentence.isEmpty ? "Sign in front of camera — recognized words will appear here" : recognizer.translatedSentence)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(recognizer.translatedSentence.isEmpty ? .secondary : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    if !recognizer.translatedSentence.isEmpty {
                        Text("Supported: Hello, Thank You, Help, Dog, Tree, Happy, Hospital")
                            .font(.caption2)
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                }
                .padding(16)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 20)
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                // Hint when not recording
                Text("Start recording to translate sign language in real time")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .frame(height: 60)
            }
            
            Spacer()
            
            // Recording Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isRecording.toggle()
                    recognizer.isActive = isRecording
                    if !isRecording {
                        recognizer.clearSentence()
                    }
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title2)
                    Text(isRecording ? "Stop" : "Start Translation")
                        .font(.headline)
                }
                .foregroundColor(isRecording ? .white : .primary)
                .padding(.vertical, 16)
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
                .background {
                    if isRecording {
                        Color.red
                    } else {
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
                .cornerRadius(16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

#Preview {
    TranslationView()
}

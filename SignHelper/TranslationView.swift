import SwiftUI

struct TranslationView: View {
    @StateObject private var recognizer = SignLanguageRecognizer()
    @State private var isRecording = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Translation")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            
            Spacer()
            
            // Camera Preview
            ZStack {
                CameraView(recognizer: recognizer)
                    .frame(width: 300, height: 300)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                    )
                    .shadow(radius: 10)
                
                if !isRecording {
                    Text("Tap Start to Translate")
                        .font(.caption)
                        .padding(6)
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top, 240) // Position near bottom of circle
                }
            }
            
            // Translation Output
            if isRecording {
                VStack(alignment: .leading) {
                    Text(recognizer.recognizedText.isEmpty ? "Listening for gestures..." : recognizer.recognizedText)
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 5)
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Spacer().frame(height: 80) // Placeholder to keep layout stable
            }
            
            Spacer()
            
            // Recording Button
            Button(action: {
                withAnimation {
                    isRecording.toggle()
                }
            }) {
                Text(isRecording ? "End Recording" : "Start Recording")
                    .font(.headline)
                    .foregroundColor(isRecording ? .white : .black)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 40)
                    .background(isRecording ? Color.red.opacity(0.8) : Color.gray.opacity(0.2))
                    .cornerRadius(30)
            }
            .padding(.bottom, 30)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

#Preview {
    TranslationView()
}

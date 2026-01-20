import SwiftUI

struct TextToSignView: View {
    @State private var inputText = ""
    @State private var showResult = false
    
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
                TextField("Type here...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    // Simulate voice input
                    inputText = "Thank you"
                }) {
                    Label("Voice Input", systemImage: "mic.fill")
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            
            Button("Translate to Sign") {
                withAnimation {
                    showResult = true
                }
                // Dismiss keyboard
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .disabled(inputText.isEmpty)
            .buttonStyle(.borderedProminent)
            
            Divider().padding()
            
            // Output Area
            if showResult {
                VStack {
                    Text("Sign Language Representation for:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\"\(inputText)\"")
                        .font(.headline)
                        .padding(.bottom)
                    
                    // Placeholder for Sign Image/Video
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            VStack {
                                Image(systemName: "hand.wave.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.orange)
                                Text("Sign Language Animation")
                                    .font(.caption)
                            }
                        )
                }
                .padding()
                .transition(.opacity)
            }
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    TextToSignView()
}

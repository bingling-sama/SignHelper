import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TranslationView()
                .tabItem {
                    Label("Translate", systemImage: "camera.fill")
                }
            
            TextToSignView()
                .tabItem {
                    Label("Dictionary", systemImage: "text.book.closed.fill")
                }
            
            LearningView()
                .tabItem {
                    Label("Learn", systemImage: "graduationcap.fill")
                }
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}

import SwiftUI

struct LearningView: View {
    let categories = [
        "Greetings",
        "Numbers",
        "Family",
        "Emergency",
        "Common Phrases"
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Basic Vocabulary")) {
                    ForEach(categories, id: \.self) { category in
                        NavigationLink(destination: Text("\(category) Lesson Placeholder")) {
                            HStack {
                                Image(systemName: "book.fill")
                                    .foregroundColor(.blue)
                                Text(category)
                            }
                        }
                    }
                }
                
                Section(header: Text("Daily Challenge")) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        VStack(alignment: .leading) {
                            Text("Learn 'Good Morning'")
                                .font(.headline)
                            Text("Progress: 0/1")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Sign Learning")
        }
    }
}

#Preview {
    LearningView()
}
